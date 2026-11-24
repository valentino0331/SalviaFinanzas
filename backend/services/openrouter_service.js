/**
 * Servicio de IA con OpenRouter + RAG para Salvia Finanzas.
 *
 * Consume la API compatible con OpenAI de OpenRouter:
 *   POST https://openrouter.ai/api/v1/chat/completions
 * Inyecta los fragmentos recuperados por el motor RAG sobre finanzas y buenos hábitos,
 * y ofrece un fallback determinista enriquecido con RAG si no hay API key configurada.
 */

const { retrieveRelevantKnowledge } = require('../rag/retriever');

const OPENROUTER_API_URL = 'https://openrouter.ai/api/v1/chat/completions';
const DEFAULT_OPENROUTER_MODEL = 'meta-llama/llama-3.3-70b-instruct:free';

function stripMarkdownJsonFences(rawText = '') {
  return String(rawText)
    .trim()
    .replace(/^```(?:json)?\s*/i, '')
    .replace(/\s*```$/i, '')
    .trim();
}

function buildRagPrompt({ question, profile, ragChunks }) {
  const ragContextText = ragChunks
    .map((chunk, i) => `[${i + 1}] (${chunk.category.toUpperCase()}) ${chunk.title}: ${chunk.content}`)
    .join('\n\n');

  const systemPrompt = `Eres Salvia, una asesora financiera amigable, clara y gamificada para jóvenes y estudiantes en Perú (moneda: S/).
Basas tus respuestas EXCLUSIVAMENTE en los datos reales del usuario y en el conocimiento recuperado (RAG) sobre educación financiera y buenos hábitos.
Responde SIEMPRE en formato JSON válido plano con exactamente estas 4 claves:
{
  "diagnosis": "Diagnóstico breve y personalizado (máx 2-3 oraciones, citando cifras si aplica)",
  "daily_tip": "Un micropaso financiero accionable para hoy basado en el conocimiento RAG",
  "habit_tip": "Un consejo práctico de buen hábito financiero diario o semanal",
  "motivation": "Un mensaje corto motivacional con temática botánica (semilla/brote/florecer)"
}`;

  const userPrompt = `PERFIL DEL USUARIO:
- Ingreso mensual: S/ ${profile.monthlyIncome}
- Gastos recientes (últimos 30 días): S/ ${profile.totalSpent}
- Categoría de mayor gasto: ${profile.topExpenseCategory || 'Sin registros'}
- Metas de ahorro activas: ${JSON.stringify(profile.activeMissions)}
- Hábitos actuales y rachas: ${JSON.stringify(profile.habits)}
${question ? `\nPREGUNTA ESPECÍFICA DEL USUARIO:\n"${question}"` : ''}

CONOCIMIENTO RECUPERADO (RAG - Finanzas y Buenos Hábitos):
${ragContextText}

Genera el JSON solicitado.`;

  return { systemPrompt, userPrompt };
}

function buildRagFallbackAdvice({ question, profile, ragChunks }) {
  const financeDoc = ragChunks.find(c => c.category === 'finanzas') || ragChunks[0];
  const habitDoc = ragChunks.find(c => c.category === 'habitos') || ragChunks[ragChunks.length - 1];
  const priorityMission = profile.activeMissions?.[0];

  let diagnosis;
  if (question) {
    diagnosis = `${financeDoc.title}: ${financeDoc.summary}`;
  } else if (priorityMission) {
    const remaining = Math.max(0, Number(priorityMission.meta || 0) - Number(priorityMission.actual || 0));
    const suggestedDaily = remaining > 0 ? (remaining / 30).toFixed(2) : '5.00';
    diagnosis = `Para tu meta '${priorityMission.title}', apartando S/ ${suggestedDaily} al día avanzarás constante. Aplica "${financeDoc.title}": ${financeDoc.summary}`;
  } else {
    diagnosis = `Tu gasto reciente es S/ ${Number(profile.totalSpent || 0).toFixed(2)} frente a un ingreso de S/ ${Number(profile.monthlyIncome || 1500).toFixed(2)}. Te recomiendo aplicar "${financeDoc.title}": ${financeDoc.summary}`;
  }

  return {
    source: 'salvia_rag_algorithmic_engine',
    model: 'rag-local-v1',
    diagnosis,
    daily_tip: financeDoc.content,
    habit_tip: `${habitDoc.title}: ${habitDoc.summary}`,
    motivation: '¡Tu jardín financiero florece con cada pequeño hábito que mantienes hoy! 🌱✨',
    rag_sources: ragChunks.map(c => ({
      id: c.id,
      title: c.title,
      category: c.category,
      summary: c.summary,
      score: c.score,
    })),
  };
}

/**
 * Genera asesoría financiera personalizada combinando RAG + OpenRouter.
 */
async function generateOpenRouterAdvice({
  question = '',
  profile = {},
  fetchImpl = globalThis.fetch,
  apiKey = process.env.OPENROUTER_API_KEY,
  model = process.env.OPENROUTER_MODEL || DEFAULT_OPENROUTER_MODEL,
} = {}) {
  const ragChunks = retrieveRelevantKnowledge({
    query: question,
    userContext: {
      monthlyIncome: profile.monthlyIncome,
      totalSpent: profile.totalSpent,
      activeMissionsCount: profile.activeMissions?.length || 0,
      habitsStreakAvg: profile.habitsStreakAvg ?? 0,
      topExpenseCategory: profile.topExpenseCategory || '',
    },
    topK: 3,
  });

  if (apiKey && typeof fetchImpl === 'function') {
    try {
      const { systemPrompt, userPrompt } = buildRagPrompt({ question, profile, ragChunks });

      const response = await fetchImpl(OPENROUTER_API_URL, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${apiKey}`,
          'Content-Type': 'application/json',
          'HTTP-Referer': process.env.OPENROUTER_SITE_URL || 'https://salvia-finanzas.onrender.com',
          'X-Title': 'Salvia Finanzas AI Advisor',
        },
        body: JSON.stringify({
          model,
          temperature: 0.4,
          messages: [
            { role: 'system', content: systemPrompt },
            { role: 'user', content: userPrompt },
          ],
        }),
      });

      if (response.ok) {
        const data = await response.json();
        const rawContent = data?.choices?.[0]?.message?.content;
        if (rawContent) {
          const cleaned = stripMarkdownJsonFences(rawContent);
          const parsed = JSON.parse(cleaned);
          return {
            source: 'openrouter_rag_ai',
            model: data?.model || model,
            diagnosis: parsed.diagnosis || '',
            daily_tip: parsed.daily_tip || '',
            habit_tip: parsed.habit_tip || `${ragChunks.find(c => c.category === 'habitos')?.summary || ''}`,
            motivation: parsed.motivation || '¡Sigue cultivando tus metas! 🌱',
            rag_sources: ragChunks.map(c => ({
              id: c.id,
              title: c.title,
              category: c.category,
              summary: c.summary,
              score: c.score,
            })),
          };
        }
      } else {
        const errBody = await response.text().catch(() => '');
        console.warn(`⚠️ OpenRouter respondió con HTTP ${response.status}: ${errBody}`);
      }
    } catch (err) {
      console.warn('⚠️ Fallback a motor RAG local por error en OpenRouter:', err.message);
    }
  }

  return buildRagFallbackAdvice({ question, profile, ragChunks });
}

module.exports = {
  OPENROUTER_API_URL,
  DEFAULT_OPENROUTER_MODEL,
  stripMarkdownJsonFences,
  buildRagPrompt,
  generateOpenRouterAdvice,
};
