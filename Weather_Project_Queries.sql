





SELECT current_database();

SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_type = 'BASE TABLE';

ALTER TABLE public.weather_data
ADD CONSTRAINT unique_weather_record
UNIQUE (timestamp, city);

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'weather_data'
ORDER BY ordinal_position;

Select * from weather_data order by id desc

delete from weather_data where city='Chennai ';

/*Data Validation*/

select count(*) as total_records from weather_data;

select * from weather_data limit 5;

select city, count(*) as total_records from weather_data group by city order by city;

select timestamp, city, count(*) as duplicate_count 
from weather_data 
group by timestamp, city having count(*)>1;

/* Data Analysis */
/* Which city had highest avg temperature during observation period?*/
select city, round(avg(temperature),2) as avg_temperature, 
max(temperature) as max_temperature, 
min(temperature) as min_temperature 
from weather_data 
group by city order by avg_temperature desc;

/* Which city has the highest avg humidity?*/
select city, round(avg(humidity),2) as avg_humidity, 
max(humidity) as max_humidity, 
min(humidity) as min_humidity 
from weather_data 
group by city order by avg_humidity desc;

/* Which city has the highest average wind speed?*/
select city, round(avg(wind_speed),2) as avg_wind_speed, 
max(wind_speed) as max_wind_speed, 
min(wind_speed) as min_wind_speed 
from weather_data 
group by city order by avg_wind_speed desc;

/* 
Which city has the highest average precipitation?
Which city recorded the highest single precipitation value?
Which city has the lowest precipitation?
Which city has the highest total precipitation during our collection period
*/
select city,round(avg(precipitation),2) as avg_precipitation,
max(precipitation) as max_precipitation,
min(precipitation) as min_precipitation,
sum(precipitation) as total_precipitation
from weather_data
group by city order by avg_precipitation desc;

/* Latest data for all 5 cities*/
select * from weather_data order by timestamp desc limit 10;

/* Created a view as weather summary*/
create view weather_city_summary as
select 
city, count(*) as total_records,
round(avg(temperature),2) as avg_temperature,
round(avg(humidity),2) as avg_humidity,
round(avg(precipitation),2) as avg_precipitation,
round(avg(wind_speed),2) as avg_wind_speed,
round(avg(cloud_cover),2) as avg_cloud_cover
from weather_data 
group by city

select * from weather_city_summary;

/* Inspecting the collection timeline */
select
city,
timestamp,
temperature,
humidity,
wind_speed,
precipitation
from weather_data
order by timestamp asc limit 20;

/* how many times or cycles for data collected till now? */
select count(distinct timestamp) as collection_times from weather_data;

/* completeness of each collection cycle */
select timestamp, count(*) as cities_collected from weather_data group by timestamp order by timestamp desc limit 10;

/* Missing City at various timestamps */
WITH expected_cities AS (
    SELECT unnest(ARRAY[
        'Mumbai',
        'Pune',
        'Hyderabad',
        'Chennai',
        'Delhi'
    ]) AS city
),
timestamps AS (
    SELECT DISTINCT timestamp
    FROM public.weather_data
)
SELECT
    t.timestamp,
    e.city AS missing_city
FROM timestamps t
CROSS JOIN expected_cities e
LEFT JOIN public.weather_data w
    ON w.timestamp = t.timestamp
    AND w.city = e.city
WHERE w.city IS NULL
ORDER BY t.timestamp, e.city;

/* Data Collection Cycle Completeness percentage*/
SELECT
    COUNT(*) AS actual_records,
    COUNT(DISTINCT timestamp) AS collection_cycles,
    COUNT(DISTINCT city) AS cities,

    COUNT(DISTINCT timestamp) * COUNT(DISTINCT city)
        AS expected_records,

    (COUNT(DISTINCT timestamp) * COUNT(DISTINCT city))
        - COUNT(*) AS missing_records,

    ROUND(
        COUNT(*)::numeric /
        (COUNT(DISTINCT timestamp) * COUNT(DISTINCT city)) * 100,
        2
    ) AS completeness_percentage

FROM public.weather_data;

/* Collected cities VS Missing cities at timestamp */
SELECT
    timestamp,
    COUNT(*) AS cities_collected,
    5 - COUNT(*) AS missing_cities
FROM public.weather_data
GROUP BY timestamp
HAVING COUNT(*) < 5
ORDER BY timestamp;

/* Data Collection at particular timestamp */
select city, 
timestamp, 
temperature, 
humidity, 
precipitation, 
wind_speed 
from weather_data 
where timestamp = '2026-09-10 11:15:00' 
order by city;

/* Time Series Analysis */
/* How does the average temperature of each city change over time?*/
/* Temperature trend over time*/
select timestamp, city, temperature from weather_data order by timestamp asc, city;

/* Temperature trend query*/
/* Is the overall temperature increasing or decreasing as time passes? */
select timestamp,
round(avg(temperature),2) as avg_temperature
from weather_data
group by timestamp
order by timestamp;

/* Average temperature at each collection timestamp for each city */
select timestamp, 
city, temperature 
from weather_data 
order by city, timestamp;

/* How much the temperature changed compared with the previous observation for the same city. */
/* LAG() concept in SQL - It will allow us to look into row (comparison of current observation and previous observation */
select city, 
timestamp, 
temperature, 
lag(temperature) 
over (partition by city order by timestamp) as previous_temperature
from weather_data
order by city, timestamp;

/* Calculate actual temperature change between each city */
select city, 
timestamp,
temperature,
lag(temperature) over (
partition by city 
order by timestamp
)
as previous_temperature,
round(
		(
			temperature - lag(temperature) over (
			partition by city
			order by timestamp
			)
		),2
)
as temperature_change
from weather_data
order by city, timestamp;

/* Find the biggest temperature increase and decrease for each city. */
with temperature_changes as (
	select city, 
	timestamp, 
	temperature,
	lag (temperature) over (
		partition by city
		order by timestamp
	) as previous_temperature
	from weather_data
),
ranked_changes as (
	select city,
	timestamp,
	previous_temperature,
	temperature,
	round(
		(temperature - previous_temperature),2
	) as temperature_change,

	row_number() over (
		partition by city
		order by temperature - previous_temperature desc
	) as increase_rank,

	row_number() over (
		partition by city
		order by temperature - previous_temperature asc
	) as decrease_rank

	from temperature_changes
	where previous_temperature is not null
)

select city,
timestamp,
previous_temperature,
temperature,
temperature_change,
case
	when increase_rank = 1 then 'Largest Increase'
	when decrease_rank = 1 then 'Largest Decrease'
end as change_type
from ranked_changes
where increase_rank = 1
or decrease_rank = 1
order by city, change_type;

/* calculate average, minimum, maximum temperature and range of temperature for every city */
select city,
round(avg(temperature),2) as avg_temperature,
min(temperature) as min_temperature,
max(temperature) as max_temperature,
round(
	(
		max(temperature) - min(temperature)
	),2
	
	)as temperature_range
	
from weather_data
group by city
order by avg_temperature desc;

/* Add Humidity, Wind and Precipitation in above Query*/
select city,
round(avg(temperature),2) as avg_temperature,
min(temperature) as min_temperature,
max(temperature) as max_temperature,

round(avg(humidity),2) as avg_humidity,
min(humidity) as min_humidity,
max(humidity) as max_humidity,

round(avg(wind_speed),2) as avg_wind_speed,
max(wind_speed) as max_wind_speed,

round(sum(precipitation),2) as total_precipitation

from weather_data
group by city
order by city;

/* Is there a relationship between temperature and humidity in our collected data? (Temperature Vs Humidity Correlation) */
select city,
round(
	corr(temperature,humidity)::numeric,
	3
) as temperature_humidity_correlation
from weather_data
group by city
order by temperature_humidity_correlation;

/* How does temperature vary by hour of the day for each city? */
select city,
extract(hour from timestamp) as hour,
round(avg(temperature),2) as avg_temperature
from weather_data
group by city,
extract(hour from timestamp)
order by city, hour;

/* Which city experienced the largest temperature variation during the collected period? */
select city,
round(min(temperature),2) as min_temperature,
round(max(temperature),2) as max_temperature,
round(
	(max(temperature) - min(temperature)),2
) as temperature_variation
from weather_data
group by city
order by temperature_variation desc;

/* What weather conditions were most frequently observed in each city? */
select city,
weather_code,
count(*) as observation_count
from weather_data
group by city, weather_code
order by city, observation_count desc;

/* Which weather observations had temperatures higher than the overall average temperature of all collected observations? */
select city,
timestamp,
temperature
from weather_data
where temperature > (
select avg(temperature) from weather_data
)
order by temperature desc;

/* Find the 2nd highest temperature among all collected temperature values */
select city,
temperature
from weather_data
where temperature <(
select max(temperature) from weather_data
)
order by temperature desc limit 1;

/* Which city has the second-highest average temperature among the five monitored */
select city,
round(avg(temperature),2) as avg_temperature
from weather_data
group by city
having avg(temperature) = (
	select max(avg_temperature)
	from (
		select city,
		avg(temperature) as avg_temperature
		from weather_data
		group by city
		order by avg_temperature desc
		offset 1
		limit 1
	) as second_highest
);

/* Which city has the second-highest temperature among the five monitored */
select city,
max(temperature) as max_temperature
from weather_data
group by city
having max(temperature) = (
	select max(max_temperature)
	from (
		select city,
		max(temperature) as max_temperature
		from weather_data
		group by city
		order by max_temperature desc
		offset 1
		limit 1
	) as second_highest
);

/* Second and third hottest cities */
select city,
		max(temperature) as max_temperature
		from weather_data
		group by city
		order by max_temperature desc
		offset 1
		limit 2;

/* Latest data check for live update */
select city,
count(*) as total_records,
round(avg(temperature),2) as avg_temperature,
round(avg(humidity),2) as avg_humidity,
max(timestamp) as latest_record
from weather_data
group by city
order by city;