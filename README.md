# Pagila Business & Sales Analysis using PostgreSQL

## Project Overview

This project analyzes the Pagila sample database using PostgreSQL and SQL to explore customer behavior, rental activity, film performance, category revenue, store performance, and business trends.

The project contains 50 SQL analysis questions covering database exploration, joins, aggregations, subqueries, Common Table Expressions (CTEs), window functions, date-based analysis, and business reporting.

## Project Objectives

- Analyze customer activity and spending patterns.
- Identify popular films and high-performing categories.
- Measure revenue and payment trends.
- Compare store and staff performance.
- Explore rental behavior and customer engagement.
- Translate SQL query results into actionable business observations.

## Tools & Technologies

- PostgreSQL
- pgAdmin
- SQL
- Git and GitHub

## Dataset Overview

The project uses the Pagila sample database.

| Metric              | Result |
| ------------------- | -----: |
| Customers           |    599 |
| Films               |  1,000 |
| Rental transactions | 16,044 |
| Payment records     | 16,044 |
| Inventory copies    |  4,581 |
| Film categories     |     16 |
| Countries           |    109 |

The `datasets/` directory contains the database schema and sample data files.

## SQL Skills Demonstrated

- SELECT, WHERE, ORDER BY, GROUP BY, and HAVING
- Aggregate functions: SUM, AVG, COUNT, MIN, and MAX
- INNER JOIN and other join operations
- Subqueries and Common Table Expressions (CTEs)
- Window functions, including RANK, DENSE_RANK, LAG, and LEAD
- CASE expressions and conditional analysis
- Date and interval calculations
- Revenue analysis and cumulative totals
- Ranking and comparative business analysis

## Key Business Insights

### 1. Overall Revenue Performance

- Total recorded payment revenue was **$67,406.56**.
- The average payment amount was approximately **$4.20**.
- The highest individual payment was **$11.99**.
- The minimum recorded payment amount was **$0.00**.

These figures summarize recorded payments and should not be interpreted as profit.

### 2. Category Performance

- **Sports** generated the highest category revenue at **$5,314.21**, with 1,179 rentals.
- **Music** recorded the lowest category revenue at **$3,417.72**.
- **Comedy** had the highest average revenue per rental at approximately **$4.66**.
- **Family** had the lowest average revenue per rental at approximately **$3.86**.

This shows that the category with the highest total revenue is not necessarily the category with the highest revenue per rental.

### 3. Film Performance

The most frequently rented films included:

| Film                | Rental Count |
| ------------------- | -----------: |
| BUCKET BROTHERHOOD  |           34 |
| ROCKETEER MOTHER    |           33 |
| GRIT CLOCKWORK      |           32 |
| RIDGEMONT SUBMARINE |           32 |
| FORWARD TEMPLE      |           32 |

These results identify popular titles based on rental frequency.

### 4. Revenue by Film Rating

- PG-13 films generated the highest recorded revenue at **$15,259.16**.
- NC-17 films generated **$13,875.07**.
- G-rated films generated the lowest recorded revenue among the rating groups at **$11,664.23**.

These are revenue totals from this dataset; they do not establish that film rating caused higher or lower revenue.

### 5. Store Performance

| Metric              |    Store 1 |    Store 2 |
| ------------------- | ---------: | ---------: |
| Revenue             | $33,679.79 | $33,726.77 |
| Rental transactions |      7,923 |      8,121 |
| Inventory copies    |      2,270 |      2,311 |
| Customers           |        326 |        273 |

Store 2 generated slightly higher revenue, with a difference of **$46.98**. It also recorded more rentals and held more inventory copies, while Store 1 served more customers.

The revenue difference between the two stores was small, so revenue alone does not indicate a major performance gap.

### 6. Staff Performance

- Staff member 2 generated **$33,924.06** in recorded payment revenue.
- Staff member 1 generated **$33,482.50**.
- Staff member 1 handled 8,054 payment records, compared with 7,990 for staff member 2.

Staff member 2 generated more revenue despite handling fewer payment records. These results describe the recorded data and do not, by themselves, measure overall employee productivity.

### 7. Monthly Revenue Trends

- **March 2007** was the highest-revenue month in the monthly payment analysis, with **$17,546.10**.
- February 2007 recorded $12,866.83.
- April 2007 recorded $14,890.30.

Monthly aggregation and cumulative revenue calculations were used to examine how recorded payments changed over time.

### 8. Country-Level Revenue

The countries with the highest recorded revenue in the country analysis included:

| Country |   Revenue |
| ------- | --------: |
| India   | $6,628.28 |
| China   | $5,798.74 |
| USA     | $4,110.32 |

These results can help identify where customer payment activity is concentrated in the dataset. They should be interpreted as sample-database results rather than real-world market estimates.

## Project Structure

```text
pagila-business-sales-analysis/
│
├── datasets/
│   ├── README.md
│   ├── pagila-schema.sql
│   └── pagila-data.sql
│
├── Pagila_Business_and_Sales_Analysis.sql
└── README.md
```

## How to Run the Project

1. Install PostgreSQL and open pgAdmin or the PostgreSQL command-line tool.
2. Create a database for the Pagila project.
3. Execute `datasets/pagila-schema.sql` first to create the database objects.
4. Execute `datasets/pagila-data.sql` to load the sample records.
5. Open `Pagila_Business_and_Sales_Analysis.sql`.
6. Run the queries in the appropriate database and review the results.

Run the schema and data files according to their intended import format and database requirements.

## Conclusion

This project demonstrates how PostgreSQL can be used to explore relational data, analyze customer behavior, measure recorded revenue, compare store and staff results, and identify popular films and categories.

The analysis provided hands-on practice with SQL techniques used in data analysis and business reporting. The findings are based on the Pagila sample database and are intended for learning and portfolio demonstration.
