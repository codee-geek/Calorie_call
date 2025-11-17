#!/bin/bash
# Quick script to check database status

export PATH="/opt/homebrew/opt/postgresql@14/bin:$PATH"

echo "=== Database Status ==="
echo ""
echo "Database Name: healthyfy_db"
echo "Database Location: /opt/homebrew/var/postgresql@14"
echo ""
echo "=== Table Counts ==="
psql -d healthyfy_db -c "SELECT 'Users' as table_name, COUNT(*) as count FROM users UNION ALL SELECT 'Food Items', COUNT(*) FROM food_items UNION ALL SELECT 'Food Logs', COUNT(*) FROM food_logs;"

echo ""
echo "=== Recent Users ==="
psql -d healthyfy_db -c "SELECT id, name, phone, diet_type, created_at FROM users ORDER BY created_at DESC LIMIT 5;"

echo ""
echo "=== Recent Food Logs ==="
psql -d healthyfy_db -c "SELECT id, user_id, food_id, quantity_grams, calories, timestamp FROM food_logs ORDER BY timestamp DESC LIMIT 5;"

echo ""
echo "=== Sample Food Items ==="
psql -d healthyfy_db -c "SELECT id, name, default_quantity_grams, calories_per_100g FROM food_items LIMIT 10;"

