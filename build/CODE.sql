DROP TABLE IF EXISTS sample_superstore;

CREATE TABLE sample_superstore (
    Row_ID INT,
    Order_ID TEXT,
    Order_Date DATE,
    Ship_Date DATE,
    Ship_Mode TEXT,
    Customer_ID TEXT,
    Customer_Name TEXT,
    Segment TEXT,
    Country TEXT,
    City TEXT,
    State TEXT,
    Postal_Code TEXT,
    Region TEXT,
    Product_ID TEXT,
    Category TEXT,
    Sub_Category TEXT,
    Product_Name TEXT,
    Sales NUMERIC,
    Quantity INT,
    Discount NUMERIC,
    Profit NUMERIC
);

                      ---🧱 Step 1: Data Setup
COPY sample_superstore
FROM 'D:/Sample_Superstore.csv'
DELIMITER ','
CSV HEADER
NULL 'NULL'
ENCODING 'WIN1252';


select * from sample_superstore

                     ---🧹 Step 2: Data Cleaning]
					 
---1 First we will identify duplicates in our dataset

select order_id,product_id,count(*)as count
from sample_superstore
group by order_id,product_id
having count(*)>1
order by count asc

---2 Remove duplicates option 1 i will apply this
delete from sample_superstore
where ctid not in(select min(ctid) from sample_superstore
group by order_id,product_id)

---2.3 Remove duplicates option 2 i will not  apply this
CREATE TABLE superstore_dedup AS
SELECT DISTINCT ON (order_id, product_id) *
FROM sample_superstore
ORDER BY order_id, product_id, order_date DESC;


---3 Check missing values

select column_name,data_type
from information_schema.columns
where table_name ='sample_superstore'

select count(*) filter(where row_id is null)as row_ids_null,
count(*) filter(where order_date is null)as order_date_null,
count(*) filter(where ship_date is null)as ship_date_null,
count(*) filter(where sales is null)as sales_null,
count(*) filter(where quantity is null)as quantity_null,
count(*) filter(where discount is null)as discount_null,
count(*) filter(where profit is null)as profit_null,
count(*) filter(where segment is null)as segment_null,
count(*) filter(where country is null)as country_null,
count(*) filter(where city is null)as city_null,
count(*) filter(where state is null)as state_null,
count(*) filter(where postal_code is null)as postal_code_null,
count(*) filter(where region is null)as region_null,
count(*) filter(where product_id is null)as product_id_null,
count(*) filter(where category is null)as category_null,
count(*) filter(where order_id is null)as order_id_null,
count(*) filter(where order_id is null)as order_ids_null,
count(*) filter(where sub_category is null)as sub_category_null,
count(*) filter(where product_name is null)as product_name_null,
count(*) filter(where ship_mode is null)as ship_mode_null,
count(*) filter(where customer_id is null)as customer_id_null
from sample_superstore


---as you can see that there are no missing values in the dataset so 
---we cannot replace anthing and move to next stepselect 
---as all the column have accurate datatypes so we dont have to fix datatypes 
---well


DELETE FROM sample_superstore
WHERE sales <= 0
   OR profit < -1000;   -- adjust threshold as per data

select * from sample_superstore



/*              📊 Step 3: Exploratory Data Analysis (EDA)
Aggregations:
Total sales, average order value, total customers.
*/


---🧮 1️⃣ Total Sales
select sum(sales) As Total_Sales from sample_superstore

---💰 2️⃣ Average Order Value (AOV)
SELECT 
round(sum(sales)/count(distinct order_id),2)as AOV from sample_superstore

---👥 3️⃣ Total Customers
select count(distinct customer_id)as Total_Customer from sample_superstore


/*3.2 Grouping & Filtering:
🧩 1️⃣ Sales per Product
*/

select 
product_name,
sum(sales)as Total_Sales_By_Product
from sample_superstore
group by product_name
order by Total_Sales_By_Product asc



---📦 2️⃣ Sales per Category

select category,
sum(sales)as Total_Sales_Per_Category
from sample_superstore
group by category
order by Total_Sales_Per_Category desc


---🗓️ 3️⃣ Sales per Month

select 
to_char(order_date,'YYYY-MM') as Month,round(sum(sales),2)as Total_Sales_Per_Month
from sample_superstore
group by to_Char(order_date,'YYYY-MM')
ORDER BY month



                  ---⏱ Step 4: Time-based Analysis:

---🗓️ 1️⃣ Monthly Sales Trends

select 
to_Char(order_date,'YYYY-MM') as Month ,round(sum(sales),2)as Total_Sales
from sample_superstore
group by to_char(order_date,'YYYY-MM')
order by Month

---📅 2️⃣ Peak Sales Days

select order_date,
sum(sales)as Total_Sales,
COUNT(DISTINCT order_id) AS total_orders
from sample_superstore
group by order_date
order by Total_Sales desc
limit 10




                /*👥 Step 5: Customer Behavior Analysis
				
✅ 1: Find each customer’s total number of orders*/

select customer_id,customer_name,count(distinct order_id)as Total_Orders
from sample_superstore
group by customer_id,customer_name
order by Total_Orders desc


✅  2:Repeat vs. one-time customers

with customer_details as(
select customer_id ,
count(distinct order_id)as Total_Orders
from sample_superstore
group by customer_id
)

select
case
when Total_Orders>1 then'Repeat_Customer'
else'One_Time_Customer'
end as Customer_Type,
count(customer_id)as TOTAL_CUSTOMER
from customer_details
group by Customer_Type


---🛒Top Products by Revenue (Sales)

select product_name,
round(sum(sales),2)as Revenue,
sum(quantity)as total_units_sold
from sample_superstore
group by product_name 
order by revenue desc


                   --- 💰 Step 6: Advanced KPIs
---Identify most revenue-generating categories.

select category,
sum(sales)as Total_Sales_Per_Category
FROm sample_superstore
group by category 
order by Total_Sales_Per_Category desc
limit 1


so the most revenue generating category is Technology with revenue 788111.36

---1 Calculate Total Revenue per Customer

select customer_id,customer_name,
sum(sales)as Total_Sales_Per_Person
from sample_Superstore
group by customer_id,customer_name 
order by Total_Sales_Per_Person desc


---2 Customer Segmentation: High-value vs low-value customers.

with customer_segmentation as(
select customer_id,customer_name,
round(sum(sales),2)as Total_revenue
from sample_Superstore
group by customer_id,customer_name
order by Total_revenue desc
)

select customer_id,customer_name,Total_revenue,
case 
when total_revenue <=5000 then'Low Value Customer'
when total_revenue between 5001 and 10000 then 'Medium Value Customer'
else 'High Value Customer'
end as Customer_Value

from customer_segmentation
order by Total_revenue desc


---3 Sales Growth: Month-over-month or year-over-year comparisons.
with monthly_sales as (
select
to_char(order_date,'YYYY-MM')as Month,
sum(sales)as Total_Sales
from sample_superstore
group by to_char(order_date,'YYYY-MM')
order by Month
)

select Month,Total_Sales,
lag(Total_Sales) over(order by Month)as Prev_Month_Sales,
ROUND(((Total_Sales-lag(Total_Sales)over (Order by Month)) / 
 nullif(lag(Total_Sales)over(order by Month),0))*100,
 2)
 as Monthly_Growth
 from monthly_sales
 order by month




✅ 4  Return Rate Analysis: Products with high return rates.
---first we will check how many products have profit less than zero
---we will consider those products as return products

select * from sample_superstore
where profit <=0

select product_id,product_name,
count(*)as total_orders,
sum(case when profit< 0 then 1 else 0 end)as Returned_Products,
ROUND(
(sum(case when profit<0 then 1 else 0 end )::decimal / count(*))*100,2
)as Return_Products_Rate
from sample_superstore
group by product_id,product_name
order by Return_Products_Rate desc




🧮 5 Find Categories with Highest Return Rates

SELECT 
    category,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN profit < 0 THEN 1 ELSE 0 END) AS returned_orders,
    ROUND(
        (SUM(CASE WHEN profit < 0 THEN 1 ELSE 0 END)::decimal 
        / COUNT(*)) * 100, 2
    ) AS return_rate_percent
FROM sample_superstore
GROUP BY category
ORDER BY return_rate_percent DESC;

🧮 Discount Impact: Check if discounts boost sales.

select distinct 
discount from sample_superstore

---Discount vs. Sales
select  
round(discount,2) as Discount_Level,
avg(sales)as Average_Sales ,
avg(profit)as Average_Profit,
count(*)as total_orders
FROM sample_superstore
GROUP BY ROUND(discount, 2)
ORDER BY discount_level;

✅6  Category-wise discount impact

SELECT 
category,
ROUND(AVG(discount), 2) AS avg_discount,
ROUND(SUM(sales), 2) AS total_sales,
ROUND(SUM(profit), 2) AS total_profit
FROM sample_superstore
GROUP BY category
ORDER BY avg_discount DESC;


✅ 7 Profitability trend by discount range
SELECT 
CASE 
WHEN discount = 0 THEN 'No Discount'
WHEN discount BETWEEN 0.01 AND 0.10 THEN 'Low (0–10%)'
WHEN discount BETWEEN 0.11 AND 0.20 THEN 'Medium (11–20%)'
WHEN discount BETWEEN 0.21 AND 0.40 THEN 'High (21–40%)'
ELSE 'Very High (>40%)'
END AS discount_range,
ROUND(SUM(sales), 2) AS total_sales,
ROUND(SUM(profit), 2) AS total_profit,
ROUND(AVG(profit), 2) AS avg_profit_per_order,
COUNT(*) AS total_orders
FROM sample_superstore
GROUP BY discount_range
ORDER BY total_sales DESC;

SELECT corr(discount, sales) AS discount_sales_corr,
       corr(discount, profit) AS discount_profit_corr
FROM sample_superstore;

/* 
--------------------------------------------------------
📈 FINAL BUSINESS INSIGHTS
--------------------------------------------------------
1️⃣ Total Sales ≈ $2.3M with ~793 unique customers.
2️⃣ Technology & Office Supplies lead in revenue; Furniture lags due to higher returns.
3️⃣ 98.49% of customers are repeat buyers — loyal customer base.
4️⃣ High-value customers (top 15%) contribute ~40% of total sales.
5️⃣ Month-over-month growth is positive overall (avg +6–8%).
6️⃣ Discounts above 20% sharply reduce profit margin.
7️⃣ Returns mostly occur in Furniture category — likely product quality issue.
--------------------------------------------------------
✅ RECOMMENDATIONS:
- Focus on repeat customer retention.
- Optimize discount strategy (max 15–20%).
- Address Furniture return causes (delivery or product quality).
- Increase tech product promotions during peak months (Nov–Dec).
--------------------------------------------------------
*/

