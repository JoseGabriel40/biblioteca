// database.js: Camada de acesso ao PostgreSQL (Neon) com compatibilidade MySQL-like.

const { Pool } = require('pg');

if (!process.env.DATABASE_URL) {
  throw new Error('DATABASE_URL não definido. Configure no arquivo .env');
}

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false },
});

function toPgPlaceholders(sql) {
  let index = 0;
  return sql.replace(/\?/g, () => {
    index += 1;
    return `$${index}`;
  });
}

function isSelect(sql) {
  return /^\s*SELECT\b/i.test(sql);
}

function toResultObject(result) {
  return {
    affectedRows: result.rowCount || 0,
    insertId: result.rows && result.rows[0] && result.rows[0].id ? result.rows[0].id : undefined,
  };
}

async function execute(client, sql, params = []) {
  const pgSql = toPgPlaceholders(sql);
  const result = await client.query(pgSql, params);

  if (isSelect(sql)) {
    return result.rows;
  }

  return toResultObject(result);
}

module.exports = {
  query: async (sql, params = []) => {
    try {
      return await execute(pool, sql, params);
    } catch (error) {
      console.error('ERRO DE QUERY PostgreSQL:', error.message);
      throw error;
    }
  },

  getConnection: async () => {
    const client = await pool.connect();
    return {
      query: async (sql, params = []) => {
        const data = await execute(client, sql, params);
        return [data];
      },
      beginTransaction: async () => {
        await client.query('BEGIN');
      },
      commit: async () => {
        await client.query('COMMIT');
      },
      rollback: async () => {
        await client.query('ROLLBACK');
      },
      release: () => {
        client.release();
      },
    };
  },
};
