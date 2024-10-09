-- Netflix Analysis Project

DROP TABLE IF EXISTS netflix;

CREATE TABLE netflix( 
	show_id VARCHAR(6),
	type VARCHAR(10),
	title VARCHAR(150),
	director VARCHAR(208),
	casts VARCHAR(1000),
	country VARCHAR(150),
	date_added VARCHAR(50),
	release_year INT,
	rating VARCHAR(10),
	duration VARCHAR(15),
	listed_in VARCHAR(100),
	description VARCHAR(250)
)

SELECT 
	* 
FROM 
	netflix;

-- 1/ Look at the number of Movies and TV Shows
SELECT
	type,
	COUNT(show_id) AS total_content
FROM 
	netflix
GROUP BY
	type;

-- 2/ Look at the most common rating for movies and TV Shows
WITH RatingCount AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM 
		netflix
    GROUP BY 
		type, 
		rating
),
RankedRating AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCount
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM 
	RankedRating
WHERE 
	rank = 1;

-- 3/ Look at all movies released in 2020
SELECT
	*
FROM
	netflix
WHERE 
	type = 'Movie' AND
	release_year = 2020;

-- 4/ Look at the Top 5 Countries with the Most Content on Netflix
SELECT
	UNNEST(STRING_TO_ARRAY(country,',')) AS new_country,
	COUNT(show_id) AS total_content
FROM
	netflix
GROUP BY
	1
ORDER BY
	2 DESC
LIMIT 5; 

-- 5/ Look at the longest movie
SELECT 
    *
FROM 
	netflix
WHERE 
	type = 'Movie'
ORDER BY 
	SPLIT_PART(duration, ' ', 1)::INT DESC;

-- 6/ Look at the content added in the last 5 years
SELECT 
	*
FROM 
	netflix
WHERE 
	TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';

-- 7/ Look at all the movies/TV shows by director 'Rajiv Chilaka'
SELECT 
	*
FROM 
	netflix
WHERE 
	director ILIKE '%Rajiv Chilaka%';

-- 8/ Look at all TV Shows with more than 5 seasons
SELECT
	*
FROM 
	netflix
WHERE 
	type = 'TV Show'
	AND SPLIT_PART(duration, ' ', 1)::numeric > 5;

-- 9/ Look at the number of content items in each genre
SELECT 
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
    COUNT(show_id) AS total_content
FROM
	netflix
GROUP BY 1;

-- 10/ Look at each year and the average numbers of content release in India on netflix, returning 
-- top 5 year with highest avg content release
SELECT 
    country,
    release_year,
    COUNT(show_id) AS yearly_content,
    ROUND(
        COUNT(show_id)::numeric /
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100, 2
    ) AS avg_content_per_year
FROM 
	netflix
WHERE 
	country = 'India'
GROUP BY 
	country, release_year
ORDER BY 
	avg_content_per_year DESC
LIMIT 5;

-- 11/ Look at all movies that are documentaries
SELECT 
	* 
FROM 
	netflix
WHERE 
	listed_in ILIKE '%Documentaries';

-- 12/ Look at all content without a director
SELECT 
	* 
FROM 
	netflix
WHERE 
	director IS NULL;

-- 13/ Look at Number of Movies Actor 'Salman Khan' Appeared in the Last 10 Years
SELECT 
	* 
FROM 
	netflix
WHERE 
	casts ILIKE '%Salman Khan%'
	AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;

-- 14/ Look at the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
    COUNT(*)
FROM 
	netflix
WHERE 
	country ILIKE '%India'
GROUP BY 
	actor
ORDER BY 2 DESC
LIMIT 10;

-- 15/ Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY 
	category;