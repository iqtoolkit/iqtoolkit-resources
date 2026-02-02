-- ============================================================
-- IQ Toolkit - PostgreSQL Architecture Series
-- Video 1: Process Model & Memory
-- 
-- PART 2: MEMORY TUNING REALITY DEMO
-- Follow this step-by-step to demonstrate the risks
-- ============================================================

-- ============================================================
-- STEP A: The Baseline Check
-- ============================================================
-- Show the audience the current state

SHOW shared_buffers;
SHOW work_mem;

-- Commentary: "We see shared_buffers is fixed (usually 128MB on 
-- small CloudSQL instances). work_mem defaults to 4MB. Let's see 
-- if 4MB is enough to sort our million-row sales table."


-- ============================================================
-- STEP B: The "Disk Spill" (Safe but Slow)
-- ============================================================
-- Force a query that sorts by amount. Since we just populated 
-- the data randomly, the database *must* sort it at runtime.

-- Force a constrained memory environment for the demo
SET work_mem = '2MB'; 

EXPLAIN (ANALYZE, BUFFERS) 
SELECT * FROM demo_sales 
ORDER BY amount DESC, notes ASC 
LIMIT 10000;

-- ⚠️ LOOK FOR THIS IN THE OUTPUT:
-- Sort Method: external merge  Disk: 38450kB
--
-- Commentary: "Look at the Sort Method. It says external merge Disk. 
-- This means the 2MB of work_mem wasn't enough. Postgres had to write 
-- ~38MB of data to the temporary disk, sort it there, and read it back. 
-- This causes I/O latency."


-- ============================================================
-- STEP C: The "Memory Tuning" (Fast but Risky)
-- ============================================================
-- Let's "fix" the slowness by giving the query more RAM.

-- Increase memory to accommodate the ~38MB sort
SET work_mem = '64MB';

EXPLAIN (ANALYZE, BUFFERS) 
SELECT * FROM demo_sales 
ORDER BY amount DESC, notes ASC 
LIMIT 10000;

-- ✅ LOOK FOR THIS IN THE OUTPUT:
-- Sort Method: quicksort  Memory: 38450kB
--
-- Commentary: "Now it says quicksort Memory. The entire operation 
-- happened in RAM. It was much faster! So, we should just leave 
-- work_mem at 64MB for everyone, right? WRONG."


-- ============================================================
-- STEP D: The Reality Check (The Math)
-- ============================================================
-- This is where you explain the invisible danger.
--
-- "We just saw that this single query used ~38MB of RAM.
-- But work_mem is not a limit per *connection*; it is a 
-- limit per *sort/hash operation*."
--
-- If you write a complex report query that joins tables 
-- and sorts them, it might trigger 3 separate sort/hash operations.
--
-- THE DANGER FORMULA:
-- ┌─────────────────────────────────────────────────────────────┐
-- │  64MB work_mem × 3 operations × 50 concurrent users         │
-- │  = 9,600 MB = 9.6 GB of RAM                                 │
-- └─────────────────────────────────────────────────────────────┘
--
-- If your instance only has 4GB of RAM, setting work_mem 
-- to 64MB just crashed your database.
--
-- CONCLUSION:
-- "High work_mem speeds up single queries but risks crashing 
-- the entire server under load. We must tune this conservatively 
-- or set it purely for specific sessions."
