
WITH cte as(
SELECT *
FROM  bike_share_yr_0
union all
SELECT *
FROM  bike_share_yr_0)
SELECT dteday , season , a.yr ,weekday , hr , rider_type , riders , price , COGS , riders*price as revenue , riders*price-COGS as profit
FROM cte a
left join cost_table b
on a.yr = b.yr
;
