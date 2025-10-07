-- sql advacnce project

-- create table
DROP TABLE IF EXISTS db_spotify;
CREATE TABLE d_spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);

-- EDA 
SELECT COUNT(*) FROM d_spotify;

SELECT COUNT(DISTINCT artist) FROM d_spotify;

SELECT COUNT(DISTINCT album) FROM d_spotify;

SELECT DISTINCT album FROM d_spotify;
-- check whether if the songs have any 0 seconds 

SELECT duration_min from d_spotify;

SELECT MAX(duration_min) from d_spotify;

SELECT MIN(duration_min) from d_spotify;

select * from d_spotify
WHERE duration_min = 0

DELETE FROM d_spotify
WHERE duration_min = 0

-----------------
-- data analysis -easy category

/*
1. Retrieve the names of all tracks that have more than 1 billion stream.
2. List all albums along with their respective artists.
3. Get the total number of comments for tracks where licensed = TRUE.
4. Find all tracks that belong to the album type single.
5. Count the total number of tracks by each artist.
*/
--1. RETRIEVE THE NAMES OF ALL TRACKS THAT HAVE MORE THAN 1 BILLION STREAM.
select * from d_spotify

select * from d_spotify
where stream > 1000000000

-- 2. LIST ALL ALBUMS ALONG WITH THEIR RESPECTIVE ARTISTS.
select DISTINCT album, artist from d_spotify
order by 1

-- 3. GET THE TOTAL NUMBER OF COMMENTS FOR TRACKS WHERE LICENSED = TRUE.
select sum(comments) from d_spotify
where licensed = 'TRUE'

-- 4. FIND ALL TRACKS THAT BELONG TO THE ALBUM TYPE SINGLE.
select * from d_spotify
where album_type = 'single'

-- 5. COUNT THE TOTAL NUMBER OF TRACKS BY EACH ARTIST
select artist,count(*) as total_track from d_spotify
group by artist
order by 2

/*
6.Calculate the average danceability of tracks in each album.
7.Find the top 5 tracks with the highest energy values.
8.List all tracks along with their views and likes where official_video = TRUE.
9.For each album, calculate the total views of all associated tracks.
10.Retrieve the track names that have been streamed on Spotify more than YouTube.
*/

-- 6 .Calculate the average danceability of tracks in each album.

select album, avg(danceability) from d_spotify
group by 1
order by 2 desc

-- 7 

select 
track, 
max(energy) from d_spotify
group by 1
order by 2 desc
limit 5

select * from d_spotify;

-- 8 List all tracks along with their views and likes where official_video = TRUE.

select 
track, 
SUM(VIEWS) AS total_veiws,
SUM(LIKES) AS  total_likes
from d_spotify
where official_video = 'true'
group by 1
order by 2 desc

-- 9 For each album, calculate the total views of all associated tracks.
select 
album,
track,
sum(views) as total_views
from d_spotify
group by 1,2
order by 3 desc

-- 10.Retrieve the track names that have been streamed on Spotify more than YouTube.
SELECT * FROM
(select 
track,
--most_played_on,
COALESCE(SUM(CASE WHEN most_played_on = 'Youtube' THEN stream END),0)as stream_on_youtube,
COALESCE(SUM(CASE WHEN most_played_on = 'Spotify' THEN stream END),0)as stream_on_spotify
from d_spotify
group by 1)
AS t1
WHERE stream_on_youtube < stream_on_spotify
AND stream_on_youtube<> 0

-- ADVANCED LEVEL 
/*
11. Find the top 3 most-viewed tracks for each artist using window functions.
12. Write a query to find tracks where the liveness score is above the average.
13. Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
14. Find tracks where the energy-to-liveness ratio is greater than 1.2.
15. Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
*/
-- 11. Find the top 3 most-viewed tracks for each artist using window functions.

SELECT * FROM d_Spotify;

-- each artist and total view for each track
-- track with highest view for each artist (we need top)
-- dense rank 
-- cte and filter rank<= 3

WITH ranking_artist
AS
(SELECT 
artist,
track,
sum(views) as total_view,
DENSE_RANK() OVER(PARTITION BY artist ORDER BY sum(views) desc) as rank
from d_spotify
group by 1,2
order by 1,3 desc
)
select * from ranking_artist
WHERE rank <= 3

-- 12. Write a query to find tracks where the liveness score is above the average.
SELECT * FROM d_Spotify;

SELECT AVG(liveness) FROM d_Spotify; -- 0.19

---

SELECT 
track,
artist,
liveness FROM d_Spotify
where liveness > (select AVG(liveness) FROM d_Spotify);

-- 13. Use a WITH clause to calculate the difference between
-- the highest and lowest energy values for tracks in each album.
SELECT * FROM d_Spotify;

WITH CTE
AS
(SELECT album,
MAX(energy) as highest_energy,
MIN(energy) as lowest_energy
FROM d_Spotify
group by 1
)
SELECT album,
highest_energy - lowest_energy as energy_difference
FROM CTE
order by 2 DESC

-- 14. Find tracks where the energy-to-liveness ratio is greater than 1.2.

WITH track_ratio
as
(
SELECT track,energy,liveness ,
       CAST ((energy/liveness)AS decimal(10,2)) AS ratio
    
FROM d_SPOTIFY
)
SELECT track,ratio FROM track_ratio
WHERE ratio>1.2 


-- 15. Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
SELECT 
    track,
    artist,
    views,
    likes,
    SUM(likes) OVER (ORDER BY views DESC) AS cumulative_likes
FROM 
    d_spotify;


-- 15. Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
SELECT 
    track,
    artist,
    views,
    likes,
    SUM(likes) OVER (ORDER BY views DESC) AS cumulative_likes
FROM 
    d_spotify;
