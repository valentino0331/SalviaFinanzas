-- Creación de la base de datos para App de Gastos (Estilo Rústico/Gamificado)
-- Compatible con Neon Serverless PostgreSQL y Vercel Cloud

-- 0. Tabla de Cuentas Compartidas (Soporte Multi-Usuario / Grupal / Pareja)
CREATE TABLE IF NOT EXISTS accounts (
    id VARCHAR(255) PRIMARY KEY, -- UUID o código de cuenta compartida
    name VARCHAR(255) NOT NULL, -- ej. "Familia Marca", "Ahorro Pareja", "Personal"
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 1. Tabla de Usuarios
CREATE TABLE IF NOT EXISTS users (
    id VARCHAR(255) PRIMARY KEY, -- ID de Google o UUID
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    avatar_url TEXT,
    points INT DEFAULT 0,
    streak INT DEFAULT 0,
    monthly_income DECIMAL(12, 2) DEFAULT 1500.00,
    account_id VARCHAR(255) REFERENCES accounts(id) ON DELETE SET NULL,
    role VARCHAR(50) DEFAULT 'owner', -- 'owner', 'member', 'contributor'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. Tabla de Gastos
CREATE TABLE IF NOT EXISTS expenses (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) REFERENCES users(id) ON DELETE CASCADE,
    amount DECIMAL(12, 2) NOT NULL,
    category VARCHAR(100) NOT NULL, -- Comida, Universidad, Gym, Transporte, Ocio, etc.
    subcategory VARCHAR(100) NOT NULL, -- almuerzo, pollo, libros, etc.
    description TEXT,
    date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    recurrence VARCHAR(50) DEFAULT 'once' -- once, daily, monthly, yearly
);

-- 3. Tabla de Misiones de Ahorro
CREATE TABLE IF NOT EXISTS savings_missions (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL, -- Pagar la universidad, Gym, etc.
    target_amount DECIMAL(12, 2) NOT NULL,
    current_amount DECIMAL(12, 2) DEFAULT 0.00,
    deadline DATE,
    icon_name VARCHAR(100) DEFAULT 'savings',
    is_completed BOOLEAN DEFAULT FALSE,
    is_shared BOOLEAN DEFAULT FALSE,
    category VARCHAR(100) DEFAULT 'General',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3.1. Tabla de Colaboradores de Metas Compartidas
CREATE TABLE IF NOT EXISTS shared_mission_contributors (
    id SERIAL PRIMARY KEY,
    mission_id INT REFERENCES savings_missions(id) ON DELETE CASCADE,
    user_id VARCHAR(255) REFERENCES users(id) ON DELETE CASCADE,
    contributed_amount DECIMAL(12, 2) DEFAULT 0.00,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(mission_id, user_id)
);

-- 4. Tabla de Hábitos
CREATE TABLE IF NOT EXISTS habits (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL, -- Levantarme temprano, Ahorro diario, etc.
    description TEXT,
    points_reward INT DEFAULT 10,
    streak INT DEFAULT 0,
    last_completed_at DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 5. Historial de Puntos (Para auditoría y gráficas de experiencia)
CREATE TABLE IF NOT EXISTS user_points_history (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) REFERENCES users(id) ON DELETE CASCADE,
    points INT NOT NULL,
    reason VARCHAR(255) NOT NULL, -- "Completó hábito: Levantarme temprano"
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Índices recomendados para optimización de consultas en PostgreSQL Neon
CREATE INDEX IF NOT EXISTS idx_expenses_user_date ON expenses(user_id, date);
CREATE INDEX IF NOT EXISTS idx_savings_user ON savings_missions(user_id);
CREATE INDEX IF NOT EXISTS idx_users_account ON users(account_id);
