// Run database migrations directly using Node.js
const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');

// Get database URL from environment (check both POSTGRES_URL and DATABASE_URL)
const postgresUrl = process.env.POSTGRES_URL || process.env.DATABASE_URL;

if (!postgresUrl) {
  console.error('❌ POSTGRES_URL or DATABASE_URL environment variable is not set');
  console.error('');
  console.error('Get it from Railway:');
  console.error('  railway variables --service postgres');
  console.error('');
  console.error('Or set it manually:');
  console.error('  export DATABASE_URL="your-connection-string"');
  console.error('  node run-migrations.js');
  process.exit(1);
}

const pool = new Pool({
  connectionString: postgresUrl
});

async function runMigrations() {
  console.log('🔧 Running Database Migrations');
  console.log('==============================');
  console.log('');

  try {
    // Read the migration file
    const migrationPath = path.join(__dirname, 'migrations', '001_init.sql');
    const sql = fs.readFileSync(migrationPath, 'utf8');

    console.log('📋 Connecting to database...');
    const client = await pool.connect();
    console.log('✅ Connected!');
    console.log('');

    console.log('🚀 Running migrations...');
    
    // Execute the SQL
    await client.query(sql);
    
    console.log('✅ Migrations completed successfully!');
    console.log('');
    
    // Verify tables were created
    const tablesResult = await client.query(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public' 
      AND table_type = 'BASE TABLE'
      ORDER BY table_name;
    `);
    
    console.log('📊 Created tables:');
    tablesResult.rows.forEach(row => {
      console.log(`   ✅ ${row.table_name}`);
    });
    
    client.release();
    await pool.end();
    
    console.log('');
    console.log('🎉 All done! Your database is ready.');
    console.log('');
    console.log('🧪 Test your backend:');
    console.log('   curl https://voxanote-production.up.railway.app/recordings');
    
  } catch (error) {
    console.error('');
    console.error('❌ Migration failed:');
    console.error(error.message);
    console.error('');
    process.exit(1);
  }
}

runMigrations();
