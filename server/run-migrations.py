#!/usr/bin/env python3
"""
Run database migrations using Python (alternative to Node.js)
"""
import os
import sys
import psycopg2
from psycopg2 import sql

# Get DATABASE_URL from environment
database_url = os.environ.get('DATABASE_URL') or os.environ.get('POSTGRES_URL')

if not database_url:
    print('❌ DATABASE_URL or POSTGRES_URL environment variable is not set')
    print('')
    print('Set it first:')
    print('  export DATABASE_URL="your-connection-string"')
    print('  python3 run-migrations.py')
    sys.exit(1)

# Read the migration file (try without vector first, fallback to full version)
migration_file = os.path.join(os.path.dirname(__file__), 'migrations', '001_init_no_vector.sql')
if not os.path.exists(migration_file):
    migration_file = os.path.join(os.path.dirname(__file__), 'migrations', '001_init.sql')

if not os.path.exists(migration_file):
    print(f'❌ Migration file not found: {migration_file}')
    sys.exit(1)

print('🔧 Running Database Migrations')
print('===============================')
print('')

try:
    print('📋 Connecting to database...')
    conn = psycopg2.connect(database_url)
    cur = conn.cursor()
    print('✅ Connected!')
    print('')
    
    print('🚀 Running migrations...')
    
    # Read and execute the SQL
    with open(migration_file, 'r') as f:
        sql_content = f.read()
    
    # Execute the SQL (split by semicolons for multiple statements)
    # Note: psycopg2 doesn't support multiple statements in one execute
    # So we'll use execute with the full content
    cur.execute(sql_content)
    conn.commit()
    
    print('✅ Migrations completed successfully!')
    print('')
    
    # Verify tables were created
    cur.execute("""
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_type = 'BASE TABLE'
        ORDER BY table_name;
    """)
    
    tables = cur.fetchall()
    print('📊 Created tables:')
    for table in tables:
        print(f'   ✅ {table[0]}')
    
    cur.close()
    conn.close()
    
    print('')
    print('🎉 All done! Your database is ready.')
    print('')
    print('🧪 Test your backend:')
    print('   curl https://voxanote-production.up.railway.app/recordings')
    
except Exception as error:
    print('')
    print('❌ Migration failed:')
    print(str(error))
    print('')
    sys.exit(1)
