/**
 * Base de Conocimiento Curada para RAG (Retrieval-Augmented Generation)
 * de Salvia Finanzas.
 *
 * Cubre dos pilares fundamentales:
 *  - `finanzas`: Educación financiera práctica, presupuestos y ahorro.
 *  - `habitos`: Construcción de buenos hábitos financieros diarios y conductuales.
 */

const FINANCIAL_KNOWLEDGE_BASE = [
  // === PILAR 1: TEMAS FINANCIEROS ===
  {
    id: 'fin_50_30_20',
    title: 'Regla 50/30/20 de Presupuesto Personal',
    category: 'finanzas',
    tags: ['presupuesto', '50/30/20', 'distribucion', 'ingreso', 'necesidades', 'ahorro', 'ocio'],
    summary: 'Divide tus ingresos mensuales en 50% necesidades básicas, 30% deseos/ocio y 20% ahorro o pago de deudas.',
    content:
      'La regla 50/30/20 organiza tu ingreso mensual neto en tres bloques claros: 50% para necesidades esenciales (alimentación, vivienda, transporte, estudios y servicios), 30% para estilo de vida y deseos (salidas, streaming, gustos) y un mínimo de 20% destinado a metas de ahorro, fondo de emergencia o reducción de deudas. Si tus necesidades superan el 50%, ajusta primero la categoría de deseos antes de sacrificar tu 20% de ahorro.',
  },
  {
    id: 'fin_fondo_emergencia',
    title: 'Fondo de Emergencia (Colchón de Tranquilidad)',
    category: 'finanzas',
    tags: ['emergencia', 'fondo', 'seguridad', 'colchon', 'imprevistos', 'ahorro', 'boveda'],
    summary: 'Reserva líquida equivalente a 3 a 6 meses de gastos esenciales para imprevistos.',
    content:
      'Un fondo de emergencia evita que un imprevisto médico, académico o laboral te obligue a endeudarte. Empieza con una meta inicial rápida de S/ 500 a S/ 1,000 como micro-colchón, y luego escala progresivamente hasta cubrir entre 3 y 6 meses de tus gastos básicos mensuales. Mantén este dinero separado de tu cuenta de gastos diarios para no gastarlo por impulso.',
  },
  {
    id: 'fin_gastos_hormiga',
    title: 'Detección y Recorte de Gastos Hormiga',
    category: 'finanzas',
    tags: ['hormiga', 'cafe', 'delivery', 'snacks', 'suscripciones', 'pequeños', 'fuga'],
    summary: 'Pequeños gastos diarios aparentemente inofensivos que acumulan un impacto mensual alto.',
    content:
      'Los gastos hormiga son compras pequeñas y frecuentes (cafés, snacks, comisiones, delivery por pereza o suscripciones que casi no usas). Un gasto de S/ 8 diarios parece menor, pero representa S/ 240 al mes y S/ 2,880 al año. La estrategia efectiva no es prohibirte todo, sino elegir 1 o 2 fugas concretas y redirigir ese monto exacto hacia una meta de ahorro activa.',
  },
  {
    id: 'fin_deudas_bola_nieve',
    title: 'Método Bola de Nieve vs. Avalancha para Deudas',
    category: 'finanzas',
    tags: ['deuda', 'tarjeta', 'credito', 'interes', 'bola de nieve', 'avalancha', 'cuotas'],
    summary: 'Dos estrategias ordenadas para salir de deudas sin perder motivación ni pagar de más.',
    content:
      'Si tienes varias deudas, paga el mínimo en todas y concentra cualquier excedente en una sola. Con el método Bola de Nieve atacas primero la deuda más pequeña para ganar impulso psicológico rápido al liquidarla. Con el método Avalancha atacas primero la deuda con mayor tasa de interés (TEA/TCEA) para ahorrar más dinero a largo plazo. Evita pagar solo el mínimo de tarjetas de crédito.',
  },
  {
    id: 'fin_regla_72_horas',
    title: 'Regla de las 72 Horas Anti-Compras Impulsivas',
    category: 'finanzas',
    tags: ['impulso', 'compra', 'espera', '72 horas', 'emocional', 'ofertas', 'deseo'],
    summary: 'Espera 72 horas antes de comprar cualquier artículo no esencial para filtrar impulsos.',
    content:
      'El marketing digital y las ofertas relámpago activan decisiones emocionales rápidas. Antes de hacer una compra no planificada, anótala y espera 72 horas (3 días). Si pasado ese tiempo sigues considerándola útil y cabe dentro de tu presupuesto de deseos del mes, cómprala sin culpa; en la mayoría de casos notarás que el impulso desapareció y conservarás ese dinero.',
  },
  {
    id: 'fin_pagate_primero',
    title: 'Págate a Ti Primero (Automatización del Ahorro)',
    category: 'finanzas',
    tags: ['pagate primero', 'automatizar', 'meta', 'principio de mes', 'ahorro', 'sueldo'],
    summary: 'Aparta tu ahorro apenas recibas ingresos, en lugar de ahorrar solo lo que sobra.',
    content:
      'El error más común es gastar primero y ahorrar lo que sobra al final del mes, porque casi nunca sobra nada. Aplicar "Págate a ti primero" significa transferir tu porcentaje de ahorro (por ejemplo 10% o 20%) el mismo día que recibes tu ingreso o mesada, tratándolo como un pago fijo obligatorio hacia tu futuro yo.',
  },

  // === PILAR 2: BUENOS HÁBITOS FINANCIEROS ===
  {
    id: 'hab_atomicos_apilamiento',
    title: 'Hábitos Atómicos y Apilamiento de Hábitos (Habit Stacking)',
    category: 'habitos',
    tags: ['habito', 'atomico', 'apilamiento', 'rutina', 'racha', 'constancia', 'diario'],
    summary: 'Asocia un nuevo micro-hábito financiero a una rutina diaria que ya haces sin esfuerzo.',
    content:
      'La constancia financiera no depende de fuerza de voluntad extrema, sino de diseño de rutinas. Usa la fórmula del apilamiento: "Después de [hábito actual], haré [micro-hábito financiero]". Por ejemplo: después de cenar o antes de poner a cargar tu celular, abre Salvia durante 60 segundos y registra los gastos del día. Empieza tan pequeño que sea imposible fallar y protege tu racha.',
  },
  {
    id: 'hab_registro_2_minutos',
    title: 'Registro Diario en 2 Minutos (Visibilidad Real)',
    category: 'habitos',
    tags: ['registrar', 'gastos', 'diario', '2 minutos', 'control', 'conciencia', 'tracking'],
    summary: 'Anotar cada gasto en menos de 2 minutos crea conciencia inmediata sobre adónde va tu dinero.',
    content:
      'Lo que no se mide no se puede mejorar. Registrar tus gastos cada noche en menos de 2 minutos elimina la "ceguera financiera" y reduce automáticamente entre un 10% y 15% el gasto impulsivo durante el primer mes, simplemente porque eres consciente de cada movimiento antes de volver a gastar.',
  },
  {
    id: 'hab_reto_redondeo',
    title: 'Reto del Redondeo y Micro-Aportes Diarios',
    category: 'habitos',
    tags: ['redondeo', 'microahorro', 'monedas', 'vuelto', 'diario', 'alcancia', 'meta'],
    summary: 'Redondea tus gastos hacia arriba y envía el vuelto virtual directo a tu meta de ahorro.',
    content:
      'Cada vez que compres algo (por ejemplo, pagaste S/ 13.50), redondea mentalmente a S/ 15.00 o S/ 20.00 y transfiere esos S/ 1.50 o S/ 6.50 de diferencia a una de tus metas de ahorro en Salvia. Al ser montos pequeños, no generan fricción ni dolor al gastar, pero mantienen tu racha activa y alimentan tus metas constantemente.',
  },
  {
    id: 'hab_dias_gasto_cero',
    title: 'Días de Gasto Cero (Zero-Spend Days)',
    category: 'habitos',
    tags: ['gasto cero', 'zero spend', 'reto', 'semana', 'comida casera', 'autocontrol'],
    summary: 'Elige 1 o 2 días a la semana para no realizar ningún gasto discrecional.',
    content:
      'Planifica al menos un día a la semana como "Día de Gasto Cero": lleva comida preparada de casa, usa transporte ya cubierto o camina, y evita compras online o snacks. Convertir el ahorro en un reto puntual de 24 horas entrena tu autocontrol y libera dinero directo para tus metas.',
  },
  {
    id: 'hab_revision_semanal',
    title: 'Revisión Financiera Semanal (Domingo de Cuentas)',
    category: 'habitos',
    tags: ['semanal', 'domingo', 'revision', 'evaluar', 'categoria', 'planificar', 'habito'],
    summary: 'Dedica 10 minutos cada fin de semana a revisar tus categorías y planificar la semana siguiente.',
    content:
      'Una vez por semana (por ejemplo, el domingo por la tarde), revisa tu resumen de categorías en Salvia durante 10 minutos: identifica en qué categoría gastaste más de lo previsto, celebra tus rachas de hábitos cumplidos y define un presupuesto tope para la semana entrante. Las correcciones semanales evitan sorpresas a fin de mes.',
  },
  {
    id: 'hab_deseo_vs_necesidad',
    title: 'Filtro Consciente: Deseo vs. Necesidad y Costo en Horas de Vida',
    category: 'habitos',
    tags: ['deseo', 'necesidad', 'horas', 'trabajo', 'valor', 'prioridad', 'consciente'],
    summary: 'Traduce el precio de una compra a horas de tu trabajo o estudio para evaluar si vale la pena.',
    content:
      'Antes de pagar por un capricho, divide su precio entre lo que ganas por hora. Si ganas S/ 15 la hora y unos audífonos cuestan S/ 150, pregúntate: "¿Vale 10 horas de mi esfuerzo?". Este cambio de perspectiva fortalece el hábito de priorizar compras que realmente aportan valor a tu bienestar o metas.',
  },
];

module.exports = { FINANCIAL_KNOWLEDGE_BASE };
