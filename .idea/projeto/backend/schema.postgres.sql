BEGIN;

CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  year INTEGER NOT NULL DEFAULT 0,
  class TEXT NOT NULL,
  course TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS credentials (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  email TEXT NOT NULL UNIQUE,
  password TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('admin', 'common'))
);

CREATE TABLE IF NOT EXISTS books (
  id SERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  author TEXT NOT NULL,
  publisher TEXT,
  year INTEGER,
  isbn TEXT UNIQUE,
  category TEXT,
  quantity INTEGER NOT NULL DEFAULT 0,
  available BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS settings (
  id INTEGER PRIMARY KEY,
  days_for_return INTEGER NOT NULL DEFAULT 14,
  fine_per_day NUMERIC(10, 2) NOT NULL DEFAULT 2.00,
  notification_days INTEGER NOT NULL DEFAULT 2
);

CREATE TABLE IF NOT EXISTS loans (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  book_id INTEGER NOT NULL REFERENCES books(id) ON DELETE RESTRICT,
  loan_date DATE NOT NULL DEFAULT CURRENT_DATE,
  return_date DATE,
  status TEXT NOT NULL CHECK (status IN ('Em andamento', 'Atrasado', 'Devolvido'))
);

INSERT INTO settings (id, days_for_return, fine_per_day, notification_days)
VALUES (1, 14, 2.00, 2)
ON CONFLICT (id) DO NOTHING;

COMMIT;
