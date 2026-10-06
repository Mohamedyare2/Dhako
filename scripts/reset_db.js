const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

// Since .env.local might not have the postgres connection string explicitly as PG_URI,
// I'll reuse the one from run_migrations.js which works.
const connectionString = 'postgresql://postgres:Naqiyoroob4@db.kvmvuoluqzzgfocatzao.supabase.co:5432/postgres';

async function resetDB() {
  const client = new Client({ connectionString });

  try {
    console.log('Connecting to Supabase...');
    await client.connect();
    console.log('Connected successfully.');

    console.log('Truncating tables...');
    // Cascade will take care of related tables like sale_items and stock_movements
    await client.query(`
      TRUNCATE TABLE 
        sale_items, 
        sales, 
        business_debts, 
        suppliers, 
        credit_accounts, 
        stock_movements, 
        products, 
        customers, 
        categories 
      CASCADE;
    `);
    console.log('Tables truncated successfully.');

    const migrationsDir = path.join(__dirname, '../supabase/migrations');
    
    // We run categories and the seed data that matches the Excel file
    const files = [
      '003_seed_categories.sql',
      '006_seed_new_data.sql' // This contains the inventory and the other sheets from the Excel file
    ];

    for (const file of files) {
      console.log(`Running ${file}...`);
      const sql = fs.readFileSync(path.join(migrationsDir, file), 'utf8');
      await client.query(sql);
      console.log(`Successfully executed ${file}`);
    }

    console.log('Database successfully reset to the original Excel state!');
  } catch (error) {
    console.error('Error resetting database:', error);
  } finally {
    await client.end();
  }
}

resetDB();
