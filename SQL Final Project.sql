use datamart_data;

select * from weekly_sales limit 10;

# Data Cleaning

create table clean_weekly_sales as

select week_date,
week(week_date) as week_number,
month(week_date) as month_number,
year(week_date) as calendar_year,
region,platform,case when segment=null then "Unknown" else segment end as segment, 
case when right(segment,1) = "1" then "Young Adults"
     when right(segment,1) = "2" then "Middle Aged"
     when right(segment,1) in ("3","4") then "Retirees"
     else "Unknown "
     end as age_band,
case when left(segment,1) = "C" then "Couples"
     when left(segment,1) = "F" then "Families"
     else "Unknown"
     end as Demographic, customer_type,transactions,sales, round(sales/transactions,2) as "avg_transaction" from weekly_sales; 
     

select * from clean_weekly_sales ;

# Data Exploration

-- 1. Which week numbers are missing from the dataset?

create table seq100
(x int not null auto_increment primary key);
insert into seq100 values (),(),(),(),(),(),(),(),(),();
insert into seq100 values (),(),(),(),(),(),(),(),(),();
insert into seq100 values (),(),(),(),(),(),(),(),(),();
insert into seq100 values (),(),(),(),(),(),(),(),(),();
insert into seq100 values (),(),(),(),(),(),(),(),(),();
insert into seq100 select x + 50 from seq100;
select * from seq100;
create table seq52 as (select x from seq100 limit 52);
select distinct x as week_day from seq52 where x not in(select distinct week_number from clean_weekly_sales); 

select distinct week_number from clean_weekly_sales;


-- 2. How many total transactions were there for each year in the dataset ? 

select calendar_year,sum(transactions) as "Total Transaction Amount (in Rs)" from clean_weekly_sales group by calendar_year;

-- 3. What are the total sales for each region for each month ?

select region, sum(sales) as total_sales from clean_weekly_sales group by region;

-- 4. What is the total count of transactions for each platform ?

select platform,count(transactions) as total_transaction_count from clean_weekly_sales group by platform;

-- 5. What is the percentage of sales for Retail vs Shopify for each month?

WITH cte_platform_sales AS (
  SELECT
    platform,
    SUM(sales) AS platform_sales
  FROM clean_weekly_sales
  GROUP BY platform
) SELECT
  ROUND(
    100 * MAX(CASE WHEN platform = 'Retail' THEN platform_sales ELSE NULL END) /
      SUM(platform_sales),
    2
  ) AS retail_percentage,
  ROUND(
    100 * MAX(CASE WHEN platform = 'Shopify' THEN platform_sales ELSE NULL END) /
      SUM(platform_sales),
    2
  ) AS shopify_percentage
FROM cte_platform_sales;


-- 6. What is the percentage of sales by demographic for each year in the dataset?

select calendar_year,demographic,sum(SALES) as yearly_sales,round((100 * sum(sales)/sum(sum(SALES)) OVER (partition by demographic)),2) 
as percentage
from clean_weekly_sales group by calendar_year,demographic order by calendar_year,demographic;


-- 7. Which age_band and demographic values contribute the most to Retail sales?

select age_band, demographic, sum(sales) as total_sales from clean_weekly_sales
where platform = 'Retail'
group by age_band, demographic
order by total_sales desc;