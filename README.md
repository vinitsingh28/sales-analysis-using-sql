# sales-analysis-using-sql
Amazon Brazil sales data analyzed using SQL to extract trends and insights for strategic use in the Indian market.

# Amazon Brazil Sales Analysis Using SQL

## Overview

This project presents a structured sales analysis of Amazon Brazil’s e-commerce data using SQL. The objective is to extract meaningful insights from customer behavior, payment patterns, and product performance to inform Amazon India's market strategy. Brazil and India share similar market characteristics, making this analysis relevant for identifying growth opportunities in the Indian context.

## Objectives

- Identify key product categories driving revenue
- Analyze customer purchase behavior and order frequency
- Understand payment method preferences and consistency
- Track seasonal and monthly sales trends
- Segment customers based on loyalty and order volume

## Data Sources

The analysis is based on structured tables including:

- `customers`: Demographics and location data
- `orders`: Order lifecycle timestamps and status
- `order_items`: Item-level price and seller information
- `products`: Product categories and specifications
- `sellers`: Seller IDs and locations
- `payments`: Transaction types and values

*Note: The dataset is not included in this repository.*

## Methodology

All analysis is performed using SQL in PostgreSQL, covering:

- Aggregate functions
- Joins between multiple tables
- Common Table Expressions (CTEs)
- Window functions
- Subqueries and conditional logic

## Deliverables

- `sql/amazon_analysis_queries.sql`: SQL scripts for all analyses
- `presentation.pdf`: Final report with query results and business recommendations

## Key Insights

- Credit cards are the most preferred payment method
- Certain product categories exhibit large price variations and high revenue potential
- Spring and summer months show higher sales performance
- Majority of customers place only one or two orders, highlighting potential for retention programs

## Conclusion

This SQL-based analysis of Amazon Brazil’s sales data provides actionable insights that can help Amazon India optimize marketing, product strategy, and customer engagement. The structured approach demonstrates the power of SQL in driving data-informed business decisions.
