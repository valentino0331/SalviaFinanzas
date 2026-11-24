/**
 * Motor de Recuperación (RAG Retriever) ligero y determinista para Salvia Finanzas.
 *
 * Combina coincidencia léxica normalizada (sin tildes, sin stopwords en español),
 * ponderación por título/tags/contenido y boosting contextual según la situación
 * financiera y de hábitos del usuario.
 */

const { FINANCIAL_KNOWLEDGE_BASE } = require('./knowledge_base');

const SPANISH_STOPWORDS = new Set([
  'el', 'la', 'los', 'las', 'un', 'una', 'unos', 'unas', 'de', 'del', 'al', 'a',
  'en', 'con', 'por', 'para', 'sin', 'sobre', 'entre', 'y', 'o', 'pero', 'que',
  'como', 'cuando', 'donde', 'quien', 'cual', 'es', 'son', 'ser', 'estar', 'soy',
  'mi', 'mis', 'tu', 'tus', 'su', 'sus', 'me', 'te', 'se', 'nos', 'lo', 'le',
  'les', 'ya', 'muy', 'mas', 'menos', 'si', 'no', 'hacer', 'tengo', 'puedo',
  'quiero', 'necesito', 'ayuda', 'dame', 'consejo', 'hola', 'salvia',
]);

function normalizeText(text = '') {
  return String(text)
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9/\s]/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

function tokenize(text = '') {
  const normalized = normalizeText(text);
  if (!normalized) return [];
  return normalized
    .split(' ')
    .filter(token => token.length >= 2 && !SPANISH_STOPWORDS.has(token));
}

/**
 * Calcula las señales contextuales del usuario para enriquecer la búsqueda RAG
 * incluso cuando no hay una pregunta explícita.
 */
function buildContextualBoosts(userContext = {}) {
  const boosts = new Map();
  const addBoost = (docId, amount) => {
    boosts.set(docId, (boosts.get(docId) || 0) + amount);
  };

  const income = Number(userContext.monthlyIncome || 0);
  const totalSpent = Number(userContext.totalSpent || 0);
  const activeMissionsCount = Number(userContext.activeMissionsCount || 0);
  const habitsStreakAvg = Number(userContext.habitsStreakAvg ?? 0);
  const topCategory = normalizeText(userContext.topExpenseCategory || '');

  // Si gasta más del 70% de su ingreso, priorizar presupuesto y gastos hormiga
  if (income > 0 && totalSpent / income >= 0.7) {
    addBoost('fin_50_30_20', 2.2);
    addBoost('fin_gastos_hormiga', 2.0);
    addBoost('hab_dias_gasto_cero', 1.4);
  }

  // Si la categoría principal es ocio/comida/entretenimiento, reforzar filtro y gastos hormiga
  if (/ocio|comida|restaurante|entretenimiento|cafe|compras/.test(topCategory)) {
    addBoost('fin_gastos_hormiga', 1.8);
    addBoost('fin_regla_72_horas', 1.5);
    addBoost('hab_deseo_vs_necesidad', 1.3);
  }

  // Si tiene metas de ahorro activas, priorizar automatización y micro-ahorro
  if (activeMissionsCount > 0) {
    addBoost('fin_pagate_primero', 1.7);
    addBoost('hab_reto_redondeo', 1.6);
  } else {
    addBoost('fin_fondo_emergencia', 1.8);
  }

  // Si su racha de hábitos es baja, priorizar hábitos atómicos y registro de 2 minutos
  if (habitsStreakAvg < 3) {
    addBoost('hab_atomicos_apilamiento', 2.0);
    addBoost('hab_registro_2_minutos', 1.6);
  } else {
    addBoost('hab_revision_semanal', 1.4);
  }

  return boosts;
}

/**
 * Recupera los `topK` fragmentos más relevantes de la base de conocimiento.
 */
function retrieveRelevantKnowledge({ query = '', userContext = {}, topK = 3, category = null } = {}) {
  const queryTokens = tokenize(query);
  const normalizedQuery = normalizeText(query);
  const contextBoosts = buildContextualBoosts(userContext);

  const candidates = category
    ? FINANCIAL_KNOWLEDGE_BASE.filter(doc => doc.category === category)
    : FINANCIAL_KNOWLEDGE_BASE;

  const scored = candidates.map(doc => {
    const titleNorm = normalizeText(doc.title);
    const summaryNorm = normalizeText(doc.summary);
    const contentNorm = normalizeText(doc.content);
    const tagsNorm = doc.tags.map(t => normalizeText(t));

    let score = contextBoosts.get(doc.id) || 0;

    // Coincidencia exacta de frase en título o tags
    if (normalizedQuery && titleNorm.includes(normalizedQuery)) {
      score += 5.0;
    }

    for (const token of queryTokens) {
      if (tagsNorm.some(tag => tag.includes(token) || token.includes(tag))) {
        score += 3.0;
      }
      if (titleNorm.includes(token)) {
        score += 2.5;
      }
      if (summaryNorm.includes(token)) {
        score += 1.5;
      }
      if (contentNorm.includes(token)) {
        score += 1.0;
      }
    }

    // Garantizar diversidad entre finanzas y hábitos si no hay query específica
    if (queryTokens.length === 0) {
      score += 0.2;
    }

    return {
      id: doc.id,
      title: doc.title,
      category: doc.category,
      summary: doc.summary,
      content: doc.content,
      tags: doc.tags,
      score: Number(score.toFixed(2)),
    };
  });

  scored.sort((a, b) => b.score - a.score);

  // Asegurar que si topK >= 2 y hay documentos de ambas categorías, se incluya al menos 1 de hábitos y 1 de finanzas cuando no se filtró categoría
  if (!category && topK >= 2 && scored.length >= 2) {
    const top = scored.slice(0, topK);
    const hasFin = top.some(d => d.category === 'finanzas');
    const hasHab = top.some(d => d.category === 'habitos');

    if (!hasHab) {
      const bestHab = scored.find(d => d.category === 'habitos');
      if (bestHab) top[top.length - 1] = bestHab;
    } else if (!hasFin) {
      const bestFin = scored.find(d => d.category === 'finanzas');
      if (bestFin) top[top.length - 1] = bestFin;
    }
    return top;
  }

  return scored.slice(0, topK);
}

module.exports = {
  normalizeText,
  tokenize,
  retrieveRelevantKnowledge,
};
