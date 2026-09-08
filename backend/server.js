require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 3000;

// Configuración de PostgreSQL en Neon
let pool = null;
let useMockDb = false;

if (process.env.DATABASE_URL) {
  try {
    pool = new Pool({
      connectionString: process.env.DATABASE_URL,
      ssl: { rejectUnauthorized: false }
    });
    console.log("🌱 Conexión configurada para Neon PostgreSQL");
    pool.query('ALTER TABLE users ADD COLUMN IF NOT EXISTS monthly_income DECIMAL(12, 2) DEFAULT 1500.00;')
      .then(() => console.log("✅ Columna monthly_income verificada/creada en PostgreSQL"))
      .catch(e => console.error("⚠️ Error agregando columna monthly_income:", e.message));
  } catch (err) {
    console.error("❌ Error inicializando pool de Postgres:", err.message);
    useMockDb = true;
  }
} else {
  console.log("⚠️ DATABASE_URL no encontrada en .env. Se usará base de datos en memoria para pruebas locales.");
  useMockDb = true;
}

// === BASE DE DATOS EN MEMORIA (FALLBACK) ===
const mockDb = {
  users: [
    { id: "google_mock_123", email: "marca@example.com", name: "Marcio A.", avatar_url: "https://api.dicebear.com/7.x/bottts/png?seed=Marcio", points: 120, streak: 3, monthly_income: 2000.00, created_at: new Date() }
  ],
  expenses: [
    { id: 1, user_id: "google_mock_123", amount: 12.50, category: "Comida", subcategory: "Pollo con Arroz", description: "Almuerzo ejecutivo", date: new Date(Date.now() - 3600000 * 2).toISOString(), recurrence: "once" },
    { id: 2, user_id: "google_mock_123", amount: 45.00, category: "Comida", subcategory: "Mercado semanal", description: "Verduras y pollo en el súper", date: new Date(Date.now() - 3600000 * 24).toISOString(), recurrence: "once" },
    { id: 3, user_id: "google_mock_123", amount: 150.00, category: "Universidad", subcategory: "Pensión mensual", description: "Pago cuota universidad", date: new Date(Date.now() - 3600000 * 48).toISOString(), recurrence: "monthly" },
    { id: 4, user_id: "google_mock_123", amount: 15.00, category: "Transporte", subcategory: "Taxi", description: "Regreso a casa tarde", date: new Date(Date.now() - 3600000 * 12).toISOString(), recurrence: "once" },
    { id: 5, user_id: "google_mock_123", amount: 30.00, category: "Gym", subcategory: "Suplementos", description: "Proteína", date: new Date().toISOString(), recurrence: "once" }
  ],
  savings_missions: [
    { id: 1, user_id: "google_mock_123", title: "Pagar Semestre Universidad", target_amount: 1500.00, current_amount: 350.00, deadline: "2026-12-15", icon_name: "school", is_completed: false },
    { id: 2, user_id: "google_mock_123", title: "Membresía Anual Gym", target_amount: 200.00, current_amount: 90.00, deadline: "2026-10-01", icon_name: "fitness_center", is_completed: false },
    { id: 3, user_id: "google_mock_123", title: "Fondo de Ahorro para Viaje", target_amount: 600.00, current_amount: 600.00, deadline: "2026-07-20", icon_name: "flight", is_completed: true }
  ],
  habits: [
    { id: 1, user_id: "google_mock_123", title: "Levantarme a las 6:00 AM", description: "Aprovechar las primeras horas del día.", points_reward: 15, streak: 3, last_completed_at: new Date(Date.now() - 3600000 * 24).toISOString().split('T')[0] },
    { id: 2, user_id: "google_mock_123", title: "Comer en casa (No Restaurante)", description: "Cocinar almuerzo o cena para ahorrar.", points_reward: 10, streak: 1, last_completed_at: null },
    { id: 3, user_id: "google_mock_123", title: "Registrar gastos diarios", description: "Ingresar todo lo gastado antes de dormir.", points_reward: 10, streak: 5, last_completed_at: new Date().toISOString().split('T')[0] },
    { id: 4, user_id: "google_mock_123", title: "Ahorrar S/. 10 diarios", description: "Pasar S/. 10 directamente a tu alcancía.", points_reward: 20, streak: 0, last_completed_at: null }
  ],
  user_points_history: []
};

// === MIDDLEWARE DE AUTENTICACIÓN SIMPLIFICADO ===
// Para fines de desarrollo rápido, si viene el header 'Authorization', tomamos el token.
// Si el token es 'mock_user' o similar, usamos el ID de prueba.
async function getUserId(req) {
  const authHeader = req.headers.authorization;
  if (!authHeader) return "google_mock_123"; // ID por defecto de desarrollo
  
  const token = authHeader.replace("Bearer ", "");
  if (token === "null" || token === "undefined" || token.startsWith("mock_")) {
    return "google_mock_123";
  }
  
  // Aquí iría la verificación real con google-auth-library:
  // const ticket = await client.verifyIdToken({ idToken: token, audience: CLIENT_ID });
  // const payload = ticket.getPayload();
  // return payload['sub']; // Google user ID
  return token; 
}

// === ENDPOINTS DE USUARIO Y LOGIN ===
app.post('/api/auth/google', async (req, res) => {
  const { id, email, name, avatar_url, monthly_income } = req.body;
  if (!id || !email) {
    return res.status(400).json({ error: "Faltan datos de usuario necesarios." });
  }

  const incomeVal = monthly_income ? parseFloat(monthly_income) : 1500.00;

  if (useMockDb) {
    let user = mockDb.users.find(u => u.id === id);
    if (!user) {
      user = { 
        id, 
        email, 
        name, 
        avatar_url: avatar_url || `https://api.dicebear.com/7.x/bottts/png?seed=${name}`, 
        points: 0, 
        streak: 0, 
        monthly_income: incomeVal,
        created_at: new Date() 
      };
      mockDb.users.push(user);
    }
    return res.json(user);
  } else {
    try {
      const selectRes = await pool.query('SELECT * FROM users WHERE id = $1', [id]);
      if (selectRes.rows.length > 0) {
        return res.json(selectRes.rows[0]);
      }
      
      const insertRes = await pool.query(
        'INSERT INTO users (id, email, name, avatar_url, monthly_income) VALUES ($1, $2, $3, $4, $5) RETURNING *',
        [id, email, name, avatar_url || `https://api.dicebear.com/7.x/bottts/png?seed=${name}`, incomeVal]
      );
      
      // Crear algunos hábitos por defecto
      const defaultHabits = [
        ["Levantarme a las 6:00 AM", "Aprovechar las primeras horas del día.", 15],
        ["Comer en casa (No Restaurante)", "Cocinar almuerzo o cena para ahorrar.", 10],
        ["Registrar gastos diarios", "Ingresar todo lo gastado antes de dormir.", 10],
        ["Ahorrar $5 dólares diarios", "Pasar $5 directamente a tu alcancía.", 20]
      ];
      for (const h of defaultHabits) {
        await pool.query('INSERT INTO habits (user_id, title, description, points_reward) VALUES ($1, $2, $3, $4)', [id, h[0], h[1], h[2]]);
      }

      return res.json(insertRes.rows[0]);
    } catch (err) {
      console.error(err);
      return res.status(500).json({ error: "Error en el servidor al autenticar con Google" });
    }
  }
});

// === ENDPOINT PARA ACTUALIZAR INGRESOS MENSUALES ===
app.put('/api/user/income', async (req, res) => {
  const userId = await getUserId(req);
  const { monthly_income } = req.body;
  if (monthly_income === undefined || isNaN(parseFloat(monthly_income))) {
    return res.status(400).json({ error: "Monto de ingresos inválido." });
  }

  const incomeVal = parseFloat(monthly_income);

  if (useMockDb) {
    const user = mockDb.users.find(u => u.id === userId);
    if (!user) return res.status(404).json({ error: "Usuario no encontrado" });
    user.monthly_income = incomeVal;
    return res.json(user);
  } else {
    try {
      const updateRes = await pool.query(
        'UPDATE users SET monthly_income = $1 WHERE id = $2 RETURNING *',
        [incomeVal, userId]
      );
      if (updateRes.rows.length === 0) return res.status(404).json({ error: "Usuario no encontrado" });
      return res.json(updateRes.rows[0]);
    } catch (err) {
      return res.status(500).json({ error: err.message });
    }
  }
});

// Obtener perfil del usuario
app.get('/api/user/profile', async (req, res) => {
  const userId = await getUserId(req);
  if (useMockDb) {
    const user = mockDb.users.find(u => u.id === userId);
    return user ? res.json(user) : res.status(404).json({ error: "Usuario no encontrado" });
  } else {
    try {
      const userRes = await pool.query('SELECT * FROM users WHERE id = $1', [userId]);
      return userRes.rows.length > 0 ? res.json(userRes.rows[0]) : res.status(404).json({ error: "Usuario no encontrado" });
    } catch (err) {
      return res.status(500).json({ error: err.message });
    }
  }
});

// === ENDPOINTS DE GASTOS ===
app.get('/api/expenses', async (req, res) => {
  const userId = await getUserId(req);
  if (useMockDb) {
    const userExpenses = mockDb.expenses.filter(e => e.user_id === userId);
    return res.json(userExpenses.sort((a, b) => new Date(b.date) - new Date(a.date)));
  } else {
    try {
      const expRes = await pool.query('SELECT * FROM expenses WHERE user_id = $1 ORDER BY date DESC', [userId]);
      return res.json(expRes.rows);
    } catch (err) {
      return res.status(500).json({ error: err.message });
    }
  }
});

app.post('/api/expenses', async (req, res) => {
  const userId = await getUserId(req);
  const { amount, category, subcategory, description, date, recurrence } = req.body;
  
  if (!amount || !category || !subcategory) {
    return res.status(400).json({ error: "Monto, categoría y subcategoría son obligatorios" });
  }

  const newExpense = {
    amount: parseFloat(amount),
    category,
    subcategory,
    description: description || "",
    date: date || new Date().toISOString(),
    recurrence: recurrence || "once"
  };

  if (useMockDb) {
    newExpense.id = mockDb.expenses.length + 1;
    newExpense.user_id = userId;
    mockDb.expenses.push(newExpense);
    return res.status(201).json(newExpense);
  } else {
    try {
      const insertRes = await pool.query(
        'INSERT INTO expenses (user_id, amount, category, subcategory, description, date, recurrence) VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *',
        [userId, newExpense.amount, newExpense.category, newExpense.subcategory, newExpense.description, newExpense.date, newExpense.recurrence]
      );
      return res.status(201).json(insertRes.rows[0]);
    } catch (err) {
      return res.status(500).json({ error: err.message });
    }
  }
});

app.delete('/api/expenses/:id', async (req, res) => {
  const expenseId = parseInt(req.params.id);
  const userId = await getUserId(req);

  if (useMockDb) {
    const idx = mockDb.expenses.findIndex(e => e.id === expenseId && e.user_id === userId);
    if (idx === -1) return res.status(404).json({ error: "Gasto no encontrado" });
    mockDb.expenses.splice(idx, 1);
    return res.json({ success: true });
  } else {
    try {
      const deleteRes = await pool.query('DELETE FROM expenses WHERE id = $1 AND user_id = $2', [expenseId, userId]);
      if (deleteRes.rowCount === 0) return res.status(404).json({ error: "Gasto no encontrado" });
      return res.json({ success: true });
    } catch (err) {
      return res.status(500).json({ error: err.message });
    }
  }
});

// === ENDPOINTS DE MISIONES DE AHORRO ===
app.get('/api/savings-missions', async (req, res) => {
  const userId = await getUserId(req);
  if (useMockDb) {
    const userMissions = mockDb.savings_missions.filter(m => m.user_id === userId);
    return res.json(userMissions);
  } else {
    try {
      const missionsRes = await pool.query('SELECT * FROM savings_missions WHERE user_id = $1 ORDER BY is_completed ASC, created_at DESC', [userId]);
      return res.json(missionsRes.rows);
    } catch (err) {
      return res.status(500).json({ error: err.message });
    }
  }
});

app.post('/api/savings-missions', async (req, res) => {
  const userId = await getUserId(req);
  const { title, target_amount, deadline, icon_name } = req.body;

  if (!title || !target_amount) {
    return res.status(400).json({ error: "Título y monto objetivo son requeridos" });
  }

  const newMission = {
    title,
    target_amount: parseFloat(target_amount),
    current_amount: 0.0,
    deadline: deadline || null,
    icon_name: icon_name || 'savings',
    is_completed: false
  };

  if (useMockDb) {
    newMission.id = mockDb.savings_missions.length + 1;
    newMission.user_id = userId;
    mockDb.savings_missions.push(newMission);
    return res.status(201).json(newMission);
  } else {
    try {
      const insertRes = await pool.query(
        'INSERT INTO savings_missions (user_id, title, target_amount, deadline, icon_name) VALUES ($1, $2, $3, $4, $5) RETURNING *',
        [userId, newMission.title, newMission.target_amount, newMission.deadline, newMission.icon_name]
      );
      return res.status(201).json(insertRes.rows[0]);
    } catch (err) {
      return res.status(500).json({ error: err.message });
    }
  }
});

// Aportar ahorro a una misión
app.post('/api/savings-missions/:id/save', async (req, res) => {
  const missionId = parseInt(req.params.id);
  const userId = await getUserId(req);
  const { amount } = req.body;

  if (!amount || parseFloat(amount) <= 0) {
    return res.status(400).json({ error: "Monto de ahorro inválido" });
  }

  const saveVal = parseFloat(amount);

  if (useMockDb) {
    const mission = mockDb.savings_missions.find(m => m.id === missionId && m.user_id === userId);
    if (!mission) return res.status(404).json({ error: "Misión no encontrada" });
    
    mission.current_amount = parseFloat(mission.current_amount) + saveVal;
    if (mission.current_amount >= mission.target_amount) {
      mission.current_amount = mission.target_amount;
      if (!mission.is_completed) {
        mission.is_completed = true;
        // Bonificación por completar misión: 100 puntos
        const user = mockDb.users.find(u => u.id === userId);
        if (user) user.points += 100;
        mockDb.user_points_history.push({
          user_id: userId,
          points: 100,
          reason: `Completó misión: ${mission.title}`,
          created_at: new Date().toISOString()
        });
      }
    }
    return res.json({ mission, points_awarded: mission.is_completed ? 100 : 0 });
  } else {
    try {
      // 1. Obtener la misión
      const mRes = await pool.query('SELECT * FROM savings_missions WHERE id = $1 AND user_id = $2', [missionId, userId]);
      if (mRes.rows.length === 0) return res.status(404).json({ error: "Misión no encontrada" });
      
      const mission = mRes.rows[0];
      const newAmount = Math.min(parseFloat(mission.current_amount) + saveVal, parseFloat(mission.target_amount));
      const justCompleted = !mission.is_completed && newAmount >= parseFloat(mission.target_amount);
      
      // 2. Actualizar misión
      const updateRes = await pool.query(
        'UPDATE savings_missions SET current_amount = $1, is_completed = $2 WHERE id = $3 RETURNING *',
        [newAmount, mission.is_completed || justCompleted, missionId]
      );

      let pointsAwarded = 0;
      if (justCompleted) {
        pointsAwarded = 100;
        await pool.query('UPDATE users SET points = points + $1 WHERE id = $2', [pointsAwarded, userId]);
        await pool.query('INSERT INTO user_points_history (user_id, points, reason) VALUES ($1, $2, $3)', [userId, pointsAwarded, `Completó misión: ${mission.title}`]);
      }

      return res.json({ mission: updateRes.rows[0], points_awarded: pointsAwarded });
    } catch (err) {
      return res.status(500).json({ error: err.message });
    }
  }
});

// === ENDPOINTS DE HÁBITOS ===
app.get('/api/habits', async (req, res) => {
  const userId = await getUserId(req);
  if (useMockDb) {
    const userHabits = mockDb.habits.filter(h => h.user_id === userId);
    return res.json(userHabits);
  } else {
    try {
      const habitsRes = await pool.query('SELECT * FROM habits WHERE user_id = $1 ORDER BY created_at ASC', [userId]);
      return res.json(habitsRes.rows);
    } catch (err) {
      return res.status(500).json({ error: err.message });
    }
  }
});

// Crear nuevo hábito personalizado
app.post('/api/habits', async (req, res) => {
  const userId = await getUserId(req);
  const { title, description, points_reward } = req.body;

  if (!title) return res.status(400).json({ error: "El título es obligatorio" });

  const newHabit = {
    title,
    description: description || "",
    points_reward: points_reward ? parseInt(points_reward) : 10,
    streak: 0,
    last_completed_at: null
  };

  if (useMockDb) {
    newHabit.id = mockDb.habits.length + 1;
    newHabit.user_id = userId;
    mockDb.habits.push(newHabit);
    return res.status(201).json(newHabit);
  } else {
    try {
      const insertRes = await pool.query(
        'INSERT INTO habits (user_id, title, description, points_reward) VALUES ($1, $2, $3, $4) RETURNING *',
        [userId, newHabit.title, newHabit.description, newHabit.points_reward]
      );
      return res.status(201).json(insertRes.rows[0]);
    } catch (err) {
      return res.status(500).json({ error: err.message });
    }
  }
});

// Marcar hábito como completado (Suma puntos y maneja rachas)
app.post('/api/habits/:id/complete', async (req, res) => {
  const habitId = parseInt(req.params.id);
  const userId = await getUserId(req);
  const todayStr = new Date().toISOString().split('T')[0];

  if (useMockDb) {
    const habit = mockDb.habits.find(h => h.id === habitId && h.user_id === userId);
    if (!habit) return res.status(404).json({ error: "Hábito no encontrado" });

    if (habit.last_completed_at === todayStr) {
      return res.status(400).json({ error: "Este hábito ya se completó el día de hoy" });
    }

    // Calcular racha
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    const yesterdayStr = yesterday.toISOString().split('T')[0];

    if (habit.last_completed_at === yesterdayStr) {
      habit.streak += 1;
    } else {
      habit.streak = 1;
    }

    habit.last_completed_at = todayStr;

    // Sumar puntos
    const user = mockDb.users.find(u => u.id === userId);
    let pts = habit.points_reward;
    // Multiplicador por racha cada 5 días
    if (habit.streak % 5 === 0) {
      pts += 15; // Bono de racha
    }
    
    if (user) {
      user.points += pts;
      user.streak = Math.max(user.streak, habit.streak); // Racha general de la cuenta
    }

    mockDb.user_points_history.push({
      user_id: userId,
      points: pts,
      reason: `Completó hábito: ${habit.title} (Racha ${habit.streak})`,
      created_at: new Date().toISOString()
    });

    return res.json({ habit, points_awarded: pts, current_user_points: user ? user.points : 0 });
  } else {
    try {
      const hRes = await pool.query('SELECT * FROM habits WHERE id = $1 AND user_id = $2', [habitId, userId]);
      if (hRes.rows.length === 0) return res.status(404).json({ error: "Hábito no encontrado" });

      const habit = hRes.rows[0];
      if (habit.last_completed_at && new Date(habit.last_completed_at).toISOString().split('T')[0] === todayStr) {
        return res.status(400).json({ error: "Este hábito ya se completó hoy" });
      }

      // Evaluar racha
      const yesterday = new Date();
      yesterday.setDate(yesterday.getDate() - 1);
      const yesterdayStr = yesterday.toISOString().split('T')[0];
      const lastCompletedStr = habit.last_completed_at ? new Date(habit.last_completed_at).toISOString().split('T')[0] : null;

      let newStreak = 1;
      if (lastCompletedStr === yesterdayStr) {
        newStreak = parseInt(habit.streak) + 1;
      }

      let pts = habit.points_reward;
      if (newStreak % 5 === 0) pts += 15; // Bono racha

      // Actualizar hábito
      const updateHabitRes = await pool.query(
        'UPDATE habits SET streak = $1, last_completed_at = $2 WHERE id = $3 RETURNING *',
        [newStreak, todayStr, habitId]
      );

      // Actualizar usuario
      const updateUserRes = await pool.query(
        'UPDATE users SET points = points + $1, streak = GREATEST(streak, $2) WHERE id = $3 RETURNING *',
        [pts, newStreak, userId]
      );

      // Insertar historial de puntos
      await pool.query(
        'INSERT INTO user_points_history (user_id, points, reason) VALUES ($1, $2, $3)',
        [userId, pts, `Completó hábito: ${habit.title} (Racha ${newStreak})`]
      );

      return res.json({
        habit: updateHabitRes.rows[0],
        points_awarded: pts,
        current_user_points: updateUserRes.rows[0].points
      });
    } catch (err) {
      return res.status(500).json({ error: err.message });
    }
  }
});

// === ENDPOINT DE TABLA DE CLASIFICACIÓN ===
app.get('/api/leaderboard', async (req, res) => {
  if (useMockDb) {
    // Retornamos la lista ordenada de usuarios (incluyendo bots para hacerlo llamativo)
    const bots = [
      { id: "bot1", name: "Sofía Financiera (Bot)", avatar_url: "https://api.dicebear.com/7.x/bottts/png?seed=Sofia", points: 340, streak: 8 },
      { id: "bot2", name: "Mateo Ahorrador (Bot)", avatar_url: "https://api.dicebear.com/7.x/bottts/png?seed=Mateo", points: 210, streak: 5 },
      { id: "bot3", name: "Valeria Inversora (Bot)", avatar_url: "https://api.dicebear.com/7.x/bottts/png?seed=Valeria", points: 95, streak: 2 }
    ];
    const allUsers = [...mockDb.users, ...bots];
    allUsers.sort((a, b) => b.points - a.points);
    return res.json(allUsers);
  } else {
    try {
      // Tomamos los usuarios reales ordenados por puntos
      const leadRes = await pool.query('SELECT id, name, avatar_url, points, streak FROM users ORDER BY points DESC LIMIT 15');
      
      // Si hay pocos usuarios, agregamos bots divertidos para motivar al usuario
      let list = leadRes.rows;
      if (list.length < 4) {
        const bots = [
          { id: "bot1", name: "Sofía Financiera (Bot)", avatar_url: "https://api.dicebear.com/7.x/bottts/png?seed=Sofia", points: 340, streak: 8 },
          { id: "bot2", name: "Mateo Ahorrador (Bot)", avatar_url: "https://api.dicebear.com/7.x/bottts/png?seed=Mateo", points: 210, streak: 5 },
          { id: "bot3", name: "Valeria Inversora (Bot)", avatar_url: "https://api.dicebear.com/7.x/bottts/png?seed=Valeria", points: 95, streak: 2 }
        ];
        list = [...list, ...bots].sort((a, b) => b.points - a.points);
      }
      return res.json(list);
    } catch (err) {
      return res.status(500).json({ error: err.message });
    }
  }
});

// === ENDPOINT DEL ASESOR FINANCIERO (CONSEJERO) ===
app.get('/api/financial-advisor', async (req, res) => {
  const userId = await getUserId(req);
  let userExpenses = [];
  let userMissions = [];
  let userScore = 100;
  let tips = [];
  let status = "Excelente";

  if (useMockDb) {
    userExpenses = mockDb.expenses.filter(e => e.user_id === userId);
    userMissions = mockDb.savings_missions.filter(m => m.user_id === userId && !m.is_completed);
  } else {
    try {
      const exp = await pool.query('SELECT * FROM expenses WHERE user_id = $1', [userId]);
      const mis = await pool.query('SELECT * FROM savings_missions WHERE user_id = $1 AND is_completed = false', [userId]);
      userExpenses = exp.rows;
      userMissions = mis.rows;
    } catch (err) {
      return res.status(500).json({ error: err.message });
    }
  }

  let monthlyBudget = 1500.0;
  if (useMockDb) {
    const userObj = mockDb.users.find(u => u.id === userId);
    if (userObj && userObj.monthly_income) {
      monthlyBudget = parseFloat(userObj.monthly_income);
    }
  } else {
    try {
      const userRes = await pool.query('SELECT monthly_income FROM users WHERE id = $1', [userId]);
      if (userRes.rows.length > 0 && userRes.rows[0].monthly_income) {
        monthlyBudget = parseFloat(userRes.rows[0].monthly_income);
      }
    } catch (_) {}
  }

  // Lógica de diagnóstico financiero:
  // Tomamos los gastos de los últimos 30 días
  const oneMonthAgo = Date.now() - 3600000 * 24 * 30;
  const recentExpenses = userExpenses.filter(e => new Date(e.date).getTime() >= oneMonthAgo);
  
  const totalSpent = recentExpenses.reduce((acc, e) => acc + parseFloat(e.amount), 0);
  
  // Categorizar gastos
  const catSummary = {};
  recentExpenses.forEach(e => {
    catSummary[e.category] = (catSummary[e.category] || 0) + parseFloat(e.amount);
  });

  // Calculamos el perfil
  const foodSpent = catSummary["Comida"] || 0;
  const uniSpent = catSummary["Universidad"] || 0;
  const leisureSpent = catSummary["Ocio"] || 0;

  if (totalSpent > monthlyBudget) {
    userScore -= 30;
    tips.push(`Has superado tu presupuesto mensual de S/. ${monthlyBudget.toFixed(2)}. Intenta posponer compras no esenciales.`);
  } else if (totalSpent > monthlyBudget * 0.75) {
    userScore -= 15;
    tips.push(`Estás cerca de alcanzar el límite de tu presupuesto de S/. ${monthlyBudget.toFixed(2)}. Revisa tus gastos diarios.`);
  }

  // Analizar gastos en ocio
  if (leisureSpent > monthlyBudget * 0.20) {
    userScore -= 15;
    tips.push(`Tus gastos en Ocio (S/. ${leisureSpent.toFixed(2)}) superan el 20% de tu presupuesto. Aquí hay una gran oportunidad para recortar y ahorrar.`);
  }

  // Analizar comida fuera vs almuerzos
  if (foodSpent > monthlyBudget * 0.35) {
    userScore -= 10;
    tips.push(`Has gastado bastante en Comida (S/. ${foodSpent.toFixed(2)}). Si preparas almuerzos rápidos o pollo en casa en lugar de comer fuera, podrías ahorrar unos S/. 120 al mes.`);
  }

  // Dar consejos basados en misiones activas
  if (userMissions.length > 0) {
    const mainMission = userMissions[0];
    const missing = parseFloat(mainMission.target_amount) - parseFloat(mainMission.current_amount);
    
    if (leisureSpent > 0) {
      const redirectPotential = Math.min(leisureSpent * 0.5, missing);
      tips.push(`💡 Consejo del Asesor Rústico: Si desvías la mitad de tus gastos de Ocio hacia la misión "${mainMission.title}", juntarás S/. ${redirectPotential.toFixed(2)} adicionales este mes.`);
    }
  } else {
    tips.push("¡No tienes misiones de ahorro activas! Configura una misión (ej. 'Comprar Laptop' o 'Pagar Gimnasio') para tener un propósito claro.");
  }

  // Evaluar estado general
  if (userScore >= 85) {
    status = "Excelente";
  } else if (userScore >= 60) {
    status = "Moderado";
  } else {
    status = "Crítico";
  }

  if (tips.length === 0) {
    tips.push("Tus finanzas lucen sanas y balanceadas. ¡Sigue con este excelente ritmo y no olvides completar tus hábitos!");
  }

  return res.json({
    score: userScore,
    status,
    total_spent_30_days: totalSpent,
    category_summary: catSummary,
    tips
  });
});

app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', database: useMockDb ? 'mock_in_memory' : 'postgres_neon' });
});

app.listen(PORT, () => {
  console.log(`🍁 Servidor rústico de finanzas corriendo en http://localhost:${PORT}`);
});
