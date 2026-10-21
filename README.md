# Bookstore Sales & Customer Analysis | PostgreSQL

## Project Overview

This project uses PostgreSQL to analyze bookstore sales, customer purchasing behavior, book popularity, revenue, and inventory. It uses three related tables — Books, Customers, and Orders — to answer business questions through SQL queries.

## Business Objectives

- Analyze total revenue and book sales.
- Identify popular books, genres, and authors.
- Understand customer purchasing behavior and repeat orders.
- Identify high-value customers and customer locations.
- Analyze monthly revenue trends.
- Evaluate book stock and estimated remaining inventory.

## Tools & Technologies

- **PostgreSQL** — Database creation and SQL analysis
- **SQL** — Data retrieval, filtering, joins, aggregation, and business analysis
- **CSV** — Sample data import

## Database Schema

The project contains three relational tables:

| Table | Description |
|---|---|
| `Books` | Book titles, authors, genres, publication years, prices, and stock |
| `Customers` | Customer details, cities, and countries |
| `Orders` | Order dates, customers, books, quantities, and order amounts |

**Relationships:**
- `Orders.Customer_ID` references `Customers.Customer_ID`.
- `Orders.Book_ID` references
