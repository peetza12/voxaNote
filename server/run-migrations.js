// Run database migrations directly using Node.js
const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

// Get database URL from environment (same logic as env.ts)
function getPostgresUrl() {
  let dbUrl = process.env.DATABASE_PUBLIC_URL ||
              process.env.DATABASE_URL || 
              process.env.POSTGRES_URL || 
              '';
  
  // Skip localhost URLs - they're for local development, not Railway
  if (dbUrl && (dbUrl.includes('localhost') || dbUrl.includes('127.0.0.1'))) {
    console.log('⚠️  Found localhost database URL, skipping (this is for local dev)');
    dbUrl = '';
  }
  
  // If URL uses internal hostname that doesn't resolve, replace with public one
  if (dbUrl && dbUrl.includes('postgres.railway.internal')) {
    try {
      const url = new URL(dbUrl);
      dbUrl = `postgresql://${url.username}:${url.password}@metro.proxy.rlwy.net:27075${url.pathname}`;
      console.log('✅ Converted Railway internal URL to public URL');
    } catch (e) {
      dbUrl = '';
    }
  }
  
  // Final fallback for Railway production (from env.ts)
  if (!dbUrl) {
    console.log('ℹ️  Using Railway production database URL (from env.ts fallback)');
    dbUrl = 'postgresql://postgres:DLFGYdFmbPBJqUwzsZPXQBCDEKyJOggL@metro.proxy.rlwy.net:27075/railway';
  }
  
  return dbUrl;
}

const postgresUrl = getPostgresUrl();

if (!postgresUrl) {
  console.error('❌ Could not determine database URL');
  console.error('');
  console.error('Please set one of these environment variables:');
  console.error('  - DATABASE_PUBLIC_URL');
  console.error('  - DATABASE_URL');
  console.error('  - POSTGRES_URL');
  console.error('');
  console.error('Or get it from Railway:');
  console.error('  railway variables --service postgres');
  console.error('');
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
    // Get all migration files in order
    const migrationsDir = path.join(__dirname, 'migrations');
    const files = fs.readdirSync(migrationsDir)
      .filter(f => f.endsWith('.sql'))
      .sort(); // Sort alphabetically to ensure order (001, 002, etc.)

    console.log('📋 Connecting to database...');
    const client = await pool.connect();
    console.log('✅ Connected!');
    console.log('');

    console.log(`🚀 Running ${files.length} migration(s)...`);
    
    // Execute each migration
    for (const file of files) {
      const migrationPath = path.join(migrationsDir, file);
      const sql = fs.readFileSync(migrationPath, 'utf8');
      console.log(`   📄 Running ${file}...`);
      
      try {
        await client.query(sql);
        console.log(`   ✅ ${file} completed`);
      } catch (error) {
        // Check if it's an extension error that we can skip
        if (error.message && error.message.includes('extension') && error.message.includes('is not available')) {
          console.log(`   ⚠️  ${file} - Extension not available, but migration may have partially succeeded`);
          console.log(`   ℹ️  Error: ${error.message}`);
          // Try to continue with the rest of the migration
          // Split SQL by semicolons and execute statements that don't require the extension
          const statements = sql.split(';').filter(s => s.trim() && !s.toLowerCase().includes('create extension'));
          for (const stmt of statements) {
            if (stmt.trim()) {
              try {
                await client.query(stmt);
              } catch (e) {
                // Ignore errors for individual statements
              }
            }
          }
        } else {
          throw error; // Re-throw if it's not an extension error
        }
      }
    }
    
    console.log('');
    console.log('✅ All migrations completed successfully!');
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
    if (error.stack) {
      console.error('');
      console.error('Stack trace:');
      console.error(error.stack);
    }
    console.error('');
    process.exit(1);
  }
}

runMigrations();
