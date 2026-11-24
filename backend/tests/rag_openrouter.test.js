const test = require('node:test');
const assert = require('node:assert/strict');

const { FINANCIAL_KNOWLEDGE_BASE } = require('../rag/knowledge_base');
const { retrieveRelevantKnowledge, normalizeText } = require('../rag/retriever');
const {
  stripMarkdownJsonFences,
  generateOpenRouterAdvice,
} = require('../services/openrouter_service');

test('Base de conocimiento RAG incluye temas financieros y buenos hábitos', () => {
  const finanzas = FINANCIAL_KNOWLEDGE_BASE.filter(d => d.category === 'finanzas');
  const habitos = FINANCIAL_KNOWLEDGE_BASE.filter(d => d.category === 'habitos');

  assert.ok(finanzas.length >= 5, 'Debe incluir al menos 5 documentos de finanzas');
  assert.ok(habitos.length >= 5, 'Debe incluir al menos 5 documentos de buenos hábitos');
});

test('normalizeText elimina tildes y signos manteniendo palabras clave', () => {
  assert.equal(normalizeText('¿Cómo reducir Gastos Hormiga y Hábitos?'), 'como reducir gastos hormiga y habitos');
});

test('Retriever RAG recupera documentos relevantes para consultas financieras', () => {
  const results = retrieveRelevantKnowledge({
    query: 'como recortar gastos hormiga de cafe y delivery',
    topK: 3,
  });

  assert.equal(results.length, 3);
  assert.equal(results[0].id, 'fin_gastos_hormiga');
  assert.ok(results.some(r => r.category === 'habitos'), 'Debe mantener diversidad incluyendo hábitos');
});

test('Retriever RAG recupera documentos relevantes para consultas de buenos hábitos', () => {
  const results = retrieveRelevantKnowledge({
    query: 'como mantener mi racha de registro diario y habitos atomicos',
    topK: 3,
  });

  assert.equal(results.length, 3);
  assert.ok(
    results.some(r => r.id === 'hab_atomicos_apilamiento' || r.id === 'hab_registro_2_minutos'),
    'Debe recuperar hábitos atómicos o registro diario'
  );
});

test('Fallback RAG local funciona sin API key y devuelve fuentes citadas', async () => {
  const advice = await generateOpenRouterAdvice({
    question: 'Como aplico la regla 50/30/20',
    apiKey: '',
    profile: {
      monthlyIncome: 2000,
      totalSpent: 1600,
      topExpenseCategory: 'Ocio',
      activeMissions: [{ title: 'Laptop', meta: 1500, actual: 300 }],
      habits: [],
      habitsStreakAvg: 1,
    },
  });

  assert.equal(advice.source, 'salvia_rag_algorithmic_engine');
  assert.ok(advice.diagnosis.length > 10);
  assert.ok(advice.daily_tip.length > 10);
  assert.ok(advice.habit_tip.length > 10);
  assert.ok(Array.isArray(advice.rag_sources) && advice.rag_sources.length === 3);
  assert.equal(advice.rag_sources[0].id, 'fin_50_30_20');
});

test('OpenRouter service envía prompt con RAG y parsea JSON envuelto en markdown', async () => {
  let capturedUrl = null;
  let capturedOptions = null;

  const mockFetch = async (url, options) => {
    capturedUrl = url;
    capturedOptions = options;
    return {
      ok: true,
      json: async () => ({
        model: 'meta-llama/llama-3.3-70b-instruct:free',
        choices: [
          {
            message: {
              content: '```json\n{"diagnosis":"Estás gastando 80% de tu ingreso.","daily_tip":"Evita compras por 72 horas.","habit_tip":"Registra tus gastos cada noche en 2 minutos.","motivation":"¡Tu semilla financiera crecerá fuerte! 🌱"}\n```',
            },
          },
        ],
      }),
    };
  };

  const advice = await generateOpenRouterAdvice({
    question: '¿Cómo dejo de gastar por impulso?',
    apiKey: 'sk-or-test-key',
    fetchImpl: mockFetch,
    profile: {
      monthlyIncome: 1500,
      totalSpent: 1200,
      topExpenseCategory: 'Compras',
      activeMissions: [{ title: 'Fondo', meta: 500, actual: 100 }],
      habits: [{ title: 'Registrar gastos', streak: 2 }],
      habitsStreakAvg: 2,
    },
  });

  assert.equal(capturedUrl, 'https://openrouter.ai/api/v1/chat/completions');
  assert.equal(capturedOptions.headers.Authorization, 'Bearer sk-or-test-key');

  const body = JSON.parse(capturedOptions.body);
  assert.ok(body.messages[1].content.includes('CONOCIMIENTO RECUPERADO (RAG'));
  assert.equal(advice.source, 'openrouter_rag_ai');
  assert.equal(advice.habit_tip, 'Registra tus gastos cada noche en 2 minutos.');
  assert.ok(advice.rag_sources.length === 3);
});

test('stripMarkdownJsonFences limpia bloques de código markdown', () => {
  const cleaned = stripMarkdownJsonFences('```json\n{"ok":true}\n```');
  assert.equal(cleaned, '{"ok":true}');
});
