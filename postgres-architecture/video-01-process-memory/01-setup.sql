-- ============================================================
-- IQ Toolkit - PostgreSQL Architecture Series
-- Video 1: Process Model & Memory
-- 
-- PART 1: SETUP SCRIPT (Run Once)
-- Creates a sandbox environment with 1M rows to force
-- PostgreSQL to make hard decisions about memory.
-- ============================================================

-- 1. Create a dummy users table
CREATE TABLE demo_users (
    id SERIAL PRIMARY KEY,
    username TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 2. Create a dummy sales table (The heavy table)
CREATE TABLE demo_sales (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES demo_users(id),
    amount NUMERIC(10, 2),
    transaction_date TIMESTAMP,
    notes TEXT -- Added to increase row width and memory usage
);

-- 3. Populate Users (10,000 rows)
INSERT INTO demo_users (username, created_at)
SELECT 
    'user_' || i, 
    NOW() - (random() * interval '365 days')
FROM generate_series(1, 10000) AS i;

-- 4. Populate Sales (1,000,000 rows) - This might take 10-20 seconds
INSERT INTO demo_sales (user_id, amount, transaction_date, notes)
SELECT 
    (random() * 9999 + 1)::INT, 
    (random() * 1000)::NUMERIC, 
    NOW() - (random() * interval '365 days'),
    md5(random()::text) || md5(random()::text) -- Heavy padding to force memory usage
FROM generate_series(1, 1000000) AS i;

-- 5. Update statistics so the planner knows row counts
VACUUM ANALYZE demo_users;
VACUUM ANALYZE demo_sales;
