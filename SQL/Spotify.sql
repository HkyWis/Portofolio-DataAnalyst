-- See all dataset
select *
from portofolio..spotify;

-- Retrieve track names that have higher consumption on Spotify vs YouTube
/*
Objective: Identify songs that have stronger streaming performance on Spotify than YouTube
*/

select 
    track, 
    most_palyed_on_spotify, 
    most_palyed_on_youtube 
from (
    select 
        track,
        sum(case when most_playedon = 'Spotify' then Stream else 0 end) as most_palyed_on_spotify,
        sum(case when most_playedon = 'Youtube' then Stream else 0 end) as most_palyed_on_youtube
    from portofolio..spotify
    group by track
) as t1
where most_palyed_on_spotify > most_palyed_on_youtube 
      and most_palyed_on_youtube != 0;

-- Find the top 3 most viewed tracks for each artist.
/*
Objective: Determine the 3 most popular videos for each artist.
*/
with ranking_artist as (
    select artist, 
	       track,
	       sum(Views) as total_view,
	       row_number() over (partition by artist order by sum(Views) desc) as rank_position
    from portofolio..spotify
    group by artist, track 
)
select *
from ranking_artist
where rank_position <= 3;

-- Find High Danceability and Energy tracks with Below Average Streams
/*
Objective: Looking for songs with high audio quality (high Energy and Danceability) 
but streaming performance is still below the market average
*/
SELECT Top 10
    Artist, 
    Track, 
    Energy, 
    Danceability, 
    Stream
FROM portofolio..spotify 
WHERE Energy > 0.8 
  AND Danceability > 0.8 
  AND Stream < (SELECT AVG(Stream) FROM portofolio..spotify ) 
ORDER BY Stream DESC;

-- Top 5 Artists with highest Engagement Rate
-- Formula: (Likes + Comments) / Views
/*
Objective: Find artists with the most loyal fan base based on interactions (Likes + Comments) 
relative to the number of Views
*/
SELECT TOP 5
    artist,
    COUNT(track) AS total_track,
    (CAST(SUM(likes) + SUM(comments) AS FLOAT) / NULLIF(SUM(views), 0)) * 100 AS engagement_percentage
FROM portofolio..spotify
GROUP BY artist
ORDER BY engagement_percentage DESC;

-- Comparing average Stream based on duration categories
/*
Objective: Analyze whether shorter songs actually generate 
higher average streams than standard length songs.
*/
with Categorize_Durations as (
    select
        track,
        stream,
        case 
            when duration_min < 2.5 then 'Short duration'
            when duration_min between 2.5 and 4.5 then 'Standard duration'
            when duration_min >= 4.5 then 'Long duration'
        end as Duration_Categorize
    from portofolio..spotify 
)
select Duration_Categorize, 
       count(track) as total_track, 
       avg(stream) as average_stream
from Categorize_Durations
group by Duration_Categorize

-- Retrieve top 3 highest streaming songs for each Album Type
/*
Objective: Find the 3 best songs from each type of release (Album, Single, Compilation)
*/
select 
    album_type,
    rank_position,
    artist,
    track,
    stream
from (
    select 
        album_type,
        ROW_NUMBER() over (partition by album_type order by stream desc) rank_position,
        artist,
        track,
        stream
    from portofolio..spotify
) as w
where rank_position <= 3;

