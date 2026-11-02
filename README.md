# Northwind Sales & Operations Dashboard

This project is an analysis of the Northwind sample database. The goal was to analyze sales, customers, discounts, and shipping performance, and build an interactive 2-page dashboard in Power BI.

##  Tools & Skills
*   **SQL Server (T-SQL):** Data exploration, JOIN, GROUP BY, and creating reusable Views.
*   **Power BI:** Data modeling, simple DAX, interactive dashboards, slicers, and filters.
*   **Dataset:** Northwind database (1996 to 1998).

##  Key Metrics
*   **Net Sales:** `Quantity * UnitPrice * (1 - Discount)`
*   **Total Orders:** Distinct count of orders
*   **Average Order Value:** Net Sales / Total Orders
*   **Shipping Days:** Days between order date and shipped date
*   **On-Time Rate:** On-time shipped orders / all shipped orders

##  Key Findings
*   **Total Sales:** $1.27M across 830 orders.
*   **Average Order Value:** About $1.53K.
*   **Customer Concentration:** The top 3 customers generate about 25% of net sales.
*   **Product Concentration:** The top 10 products generate about 44% of net sales.
*   **Shipping Performance:** 95% of shipped orders arrive on time. Average dispatch time is 8.49 days.
*   **Discounts:** About 59% of net sales come from non-discounted items.

##  Project Files
All project files are organized inside the **`[NorthwindProject](https://github.com/maryamahmadi-analytics/northwind-sql-analysis/tree/main/NorthwindProject)`** folder:
*   `/sql`: Contains the SQL scripts (Data cleaning & Views).
*   `/dashboard`: Contains the Power BI file and PDF export.

##  Dashboard Pages
**Page 1: Sales Overview**
*   **KPI Cards:** Total Net Sales, Total Orders, Average Order Value, Units Sold.
*   **Visuals:** Monthly sales trend (with a year filter) and Top 10 customers by net sales.

**Page 2: Operations & Discounts Impact**
*   **Visuals:** Shipping status distribution, Average shipping days, Net sales by discount percentage, and Top 10 products.

##  Notes & Assumptions
*   Gross sales represent sales before discounts, while net sales are calculated after discounts.
*   Since product cost data is not available in the dataset, net sales should **not** be interpreted as profit.

##  Project Status
*   **SQL analysis completed.**
*   **Power BI reporting completed.**

##  Dashboard Preview
You can view the PDF export of the Power BI dashboard here:
*   [Northwind_Dashboard.pdf]([./NorthwindProject/dashboard/Northwind_Dashboard.pdf](https://github.com/maryamahmadi-analytics/northwind-sql-analysis/blob/main/NorthwindProject/Northwind_Dashboard.pdf)) 
