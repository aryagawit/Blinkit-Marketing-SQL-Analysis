/*PROJECT: Blinkit Marketing Performance ANalysis
AUTHOR: ARYA GAWIT
PURPOSE: Cleaning and Analyzing 5,000+ marketing campaigns to optimize budget.
*/

drop table if exists blinkit;

create table blinkit(
campaign_id integer PRIMARY KEY,
campaign_name varchar(120) not null,
"date" date,
target_audience varchar(200),
channel varchar(120),
impressions integer,
clicks integer,
conversions integer,
spend numeric(10,2),
revenue_generated numeric(10,2),
roas numeric (8,2) 
);


--SECTION 1
-- 1. Check total row count
select COUNT(*) from blinkit;

select * from blinkit limit 10;

-- 2. Null Value Check (Data Hygiene)
select * from blinkit
where campaign_id is null
or
campaign_name is null
or
"date" is null
or
channel is null
or
impressions is null
or
clicks is null
or
conversions is null
or
spend is null
or
revenue_generated is null
or
roas is null;

-- 3. Data logic check:(Ensuring Clicks < Impressions)
--Cannot have more clicks than views.
select * from blinkit
where clicks > impressions;


-- 4. To see if we have any duplicates caused by typos
SELECT DISTINCT channel FROM blinkit;
SELECT DISTINCT target_audience FROM blinkit;


-- 4.1. campaign names present multiple times
SELECT campaign_name, count(campaign_id) as duplicate_count
FROM blinkit
GROUP BY campaign_name
HAVING count(campaign_id)>1
ORDER BY duplicate_count DESC;



-- SECTION 2
-- 5. Performance by Channel: Which channel is the best at getting people to click on ads? (CTR Analysis)
select channel,
sum(clicks) as total_clicks,
sum(impressions) as total_views,
round((sum(clicks)::numeric/sum(impressions))*100,2) as ctr_percentage
from blinkit
group by channel
order by ctr_percentage desc;


-- 6. We want to compare just 'App' and 'SMS' channels. Which one has a higher total number of conversions? (Filtering)
select channel,
round(sum(conversions),2) as total_conversions
from blinkit
where channel = 'App' or channel = 'SMS'
group by channel
order by total_conversions desc;


-- 7.Time-Based Analysis: Does revenue peak on the weekends? (Date Functions)
select TO_CHAR("date", 'Day') AS day_of_week, 
round(sum(revenue_generated),2) as total_revenue
from blinkit
group by TO_CHAR("date", 'Day')
order by total_revenue desc;


--SECTION 3
-- 8.Efficiency Metric:(Calculated Aggregates)
--Which target audience generates the most revenue per single conversion? 
select target_audience,
round(avg(revenue_generated/nullif(conversions,0)),2) as avg_revenue_per_sale
from blinkit
group by target_audience
order by avg_revenue_per_sale desc;


-- 9. High-Spend Underperformers:(Subqueries)
--Which campaigns are spending a lot of money (over $4,000) but have a ROAS lower than the average?
select campaign_name, roas, spend
from blinkit
where spend>4000
and roas < (select avg(roas) from blinkit)
order by spend desc;


--10. Show me the Top 10 most profitable campaigns based on the gap between Revenue and Spend
select campaign_name,
(revenue_generated - spend) as net_profit
from blinkit
order by net_profit desc
limit 10;


-- 11. Which target audience provides the best "Return on Investment" (Revenue vs. Spend)?
select target_audience,
round(sum(revenue_generated),2) as total_revenue,
round(sum(spend),2) as total_spend,
round((sum(revenue_generated) - sum(spend)),2) as total_profit
from blinkit
group by target_audience
order by total_profit desc;

-- 12. Performance Labeling (CASE Statements)
--Create a report that labels each campaign as 'High ROI' or 'Low ROI'.
select campaign_name, roas,
case
when roas> 3.0 then 'High ROI'
else 'Low ROI'
end as performance
from blinkit;
