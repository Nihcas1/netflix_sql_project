CREATE TABLE netflix
(
	show_id	VARCHAR(10),
	type VARCHAR(10),
	title VARCHAR(150),
	director VARCHAR(250),	
	castS VARCHAR(1000),
	country	VARCHAR(150),
	date_added	VARCHAR(50),
	release_year INT,
	rating	VARCHAR(10),
	duration VARCHAR(15),
	listed_in VARCHAR(100),
	description VARCHAR(250)
	)
;

SELECT count(*) FROM netflix;

--15 use cases:
--1) count the number of movies vs tv shows 

select type, count(*) as total_count
from netflix
group by type;


--2)find the most common rating for movies and tv shows

select type ,rating
from 
(
	select type, rating , count(*),
	rank() over(partition by type order by count(*) desc)
	as ranking
	from netflix
	group by 1,2
	
	
) as t1
where ranking = 1;


--3 list all the movies released in the year 2020

select * 
from 
netflix 
where type = 'Movie' and 
	release_year = 2020;

--4 find the top 5 countries with the most content on netflix

select unnest(string_to_array(country , ',')) as new_country, count(show_id) as total_count
from netflix 
	group by 1
	order by 2 desc
	limit 5
	;

--5 identify the longest movie

select * 
	from 
netflix
where type = 'Movie' and duration = (
	select max(duration) from netflix
) ;

--6 find the content added in the last 5 years

select *  
from 
netflix 
where 
to_date(date_added , 'month dd , YYYY') >= current_date - interval '5 years';


--7. find all the movies/tv shows by director 'Rajiv Chilaka'?

select *
from netflix
where director ilike '%rajiv Chilaka%';

--8. List all the tc shows with more than 5 seasons


select * 
	from netflix
where 
	type = 'TV Show' AND 
	SPLIT_PART(duration, ' ' ,1)::numeric >5;


--9 COUNT THE NUMBER OF CONTENT ITEMS IN EACH GENRE

SELECT
	UNNEST(STRING_TO_ARRAY(LISTED_IN ,',')) AS GENRE,
	COUNT(SHOW_ID) AS TOTAL_COUNT
FROM NETFLIX
GROUP BY 1;

--10. FIND EACH YEAR AND THE AVERAGE NUMBER OF CONTETN RELEASE BY INDIA ON NETFLIX.
-- RETURN TOP 5 YEAR WITH HIGHEST AVG CONTENT RELEASE  


SELECT EXTRACT(YEAR FROM TO_DATE(date_added, 'MONTH DD ,YYYY')) AS YEAR,
COUNT(*) as yearly_content,
	ROUND(
	count(*)::numeric
	/(select count(*) from netflix where country = 'India')::numeric *100,2)
	as avg_content_per_year
FROM NETFLIX 
WHERE COUNTRY = 'India'
	group by 1;


--11. LIST ALL THE MOVIES THAT ARE DOCUMENTARIES

select *from netflix
	where 
listed_in Ilike '%documentaries%'

--12. find all the content without the director

select * from netflix
where 
director is null;

13-- find how many movies actor 'salman khan' appeared in last 10 years?

select * from netflix
where casts Ilike '%salman khan%'
and release_year > extract(year from current_date)-10;


--14 find the top 10 actors who have appeared in the highest number of movies produced in india?

select 
	unnest(string_to_array(casts, ',')),
	count(*) as total_count
from netflix
	where country Ilike 'India'
group by 1
	order by 2 desc;

--15 categorize the content based on the presence of the keyords 'kill' and 'violence' in 
--the description feild. label content containing these keywords as 'bad' and all other 
--content as 'good'. count how many items fall into each category.
with cte as (
select *,
	case 
	when description Ilike '%kill%' or  
	description Ilike '%violence%' then 'bad_film'
	else 'film'
	end as category
from
netflix
	)
	select category , 
	count(*) as total_count
from cte 
group by 1;








	