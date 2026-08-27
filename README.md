# MRP Scheduler

A Python-based MRP (Material Requirements Planning) system for production scheduling and resource capacity planning, developed as a university project.

The project calculates a production plan for customer orders based on production routes, resource capacity, product yield, order priorities and delivery requirements. The resulting plan is stored in PostgreSQL and visualized as a production load calendar.

## Features

- Customer order prioritization
- Production route processing
- Backward scheduling from the required delivery date
- Resource capacity constraints
- Daily workload limits
- Product yield consideration
- Delivery weight calculation with tolerance
- Automatic distribution of operations across production days
- PostgreSQL integration
- Production load visualization
- Color-coded production calendar

## How It Works
```text
Customer Orders + Production Data
↓
Order Prioritization
↓
Production Route Processing
↓
Delivery Weight Calculation
↓
Backward Scheduling
↓
Resource Capacity Check
↓
MRP Plan
↓
Production Load Calendar
```
## Architecture

PostgreSQL → MRP Scheduler → MRP Plan → Visualization

## Tech Stack

- Python
- PostgreSQL
- SQL
- psycopg2
- pandas
- Matplotlib

## Installation

Clone the repository:
```bash
git clone https://github.com/julllyum/mrp-scheduler.git
cd mrp-scheduler
```
Create a virtual environment:
```bash
python -m venv .venv
source .venv/bin/activate
```
Install dependencies:
```bash 
pip install -r requirements.txt
```

### Database Setup

Create the database schema using:
```text  
sql/schema.sql
```
Populate the database with sample data:
```text 
sql/seed.sql
```
The SQL scripts can be executed using DBeaver or another PostgreSQL client.

Create a .env file based on .env.example:
```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=postgres
DB_USER=postgres
DB_PASSWORD=your_password
```

### Running the MRP Scheduler
Run the production planning algorithm:
```bash 
python src/mrp_scheduler.py
```
The scheduler loads orders and production routes from PostgreSQL, calculates the production schedule and saves the resulting plan to the MRP_Plan table.

### Running the Visualization
Generate the production load calendar:
```bash 
python src/visualization.py
```

The resulting visualization is saved as:
```text 
calendar_heatmap.png
```
