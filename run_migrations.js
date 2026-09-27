const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

const connectionString = 'postgresql://postgres:Naqiyoroob4@db.kvmvuoluqzzgfocatzao.supabase.co:5432/postgres';

async function runMigrations() {
  const client = new Client({
    connectionString,
  });

  try {
    console.log('Connecting to Supabase...');
    await client.connect();
    console.log('Connected successfully.');

    const migrationsDir = path.join(__dirname, 'supabase', 'migrations');
    const files = [
      '001_schema.sql',
      '002_rls.sql',
      '003_seed_categories.sql',
      '004_seed_inventory.sql'
    ];

    for (const file of files) {
      console.log(`Running ${file}...`);
      const sql = fs.readFileSync(path.join(migrationsDir, file), 'utf8');
      await client.query(sql);
      console.log(`Successfully executed ${file}`);
    }

    console.log('All migrations applied successfully!');
  } catch (error) {
    console.error('Error running migrations:', error);
  } finally {
    await client.end();
  }
}

runMigrations();
