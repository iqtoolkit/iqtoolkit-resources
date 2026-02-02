# 🧠 PostgreSQL Architecture: Process Model & Memory

> **Video 1** in the PostgreSQL Architecture Series from [IQ Toolkit](https://www.youtube.com/@iqtoolkit)

## 📋 Overview

This demo shows the **Memory Tuning Reality** — how `work_mem` affects query performance and the hidden dangers of tuning it too high.

## 📁 Files

| File | Description |
|------|-------------|
| `01-setup.sql` | Creates demo tables with 1M rows |
| `02-demo-memory-tuning.sql` | Step-by-step demo with commentary |
| `03-cleanup.sql` | Drops demo tables when finished |

## 🚀 Quick Start

1. Run `01-setup.sql` (takes 10-20 seconds to populate 1M rows)
2. Follow the steps in `02-demo-memory-tuning.sql`
3. Run `03-cleanup.sql` when done

## ⚠️ The Danger Formula

```
64MB work_mem × 3 operations × 50 concurrent users = 9.6 GB RAM
```

High `work_mem` speeds up single queries but risks crashing the entire server under load!

## 🔗 Watch the Video

📺 [Watch on YouTube](https://www.youtube.com/@iqtoolkit)
