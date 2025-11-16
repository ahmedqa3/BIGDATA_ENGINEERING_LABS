movies = LOAD '/tmp/movies.tsv' USING PigStorage('\t') AS (c0:chararray, c1:chararray, c2:chararray, c3:chararray, c4:chararray);
users  = LOAD '/tmp/users_fixed.tsv' USING PigStorage('\t') AS (u0:chararray, u1:chararray, u2:chararray, u3:chararray, u4:chararray, u5:chararray, u6:chararray, u7:chararray, u8:chararray);

movies_no_hdr = FILTER movies BY (c0 IS NOT NULL AND c0 != '_id');
users_no_hdr  = FILTER users  BY (u0 IS NOT NULL AND u0 != 'user_id');

movies_with_year = FOREACH movies_no_hdr GENERATE c0 AS movieId, c1 AS title,
    (int)REGEX_EXTRACT(c1, '.*\\((\\d{4})\\).*', 1) AS year,
    c2 AS genres;

movies_valid = FILTER movies_with_year BY year IS NOT NULL AND year > 0;
grp_by_year = GROUP movies_valid BY year;
movies_per_year = FOREACH grp_by_year GENERATE group AS year, COUNT(movies_valid.movieId) AS cnt;
STORE movies_per_year INTO '/tmp/pig_output/movies_per_year' USING PigStorage('\t');

    movies_genre_split = FOREACH movies_with_year GENERATE movieId, title, year, FLATTEN(STRSPLIT((genres is null ? '' : genres),'\\|')) AS genre;
    grp_genre = GROUP movies_genre_split BY genre;
    movies_per_genre = FOREACH grp_genre GENERATE group AS genre, COUNT(movies_genre_split.movieId) AS cnt;
    STORE movies_per_genre INTO '/tmp/pig_output/movies_per_genre' USING PigStorage('\t');

ratings_field = FOREACH users_no_hdr GENERATE u0 AS userId, TRIM((u6 is null ? '' : u6)) AS tokens;
tokens = FOREACH ratings_field GENERATE userId, FLATTEN(STRSPLIT((tokens is null ? '' : tokens), '\\|')) AS token;
parsed = FOREACH tokens GENERATE userId, REGEX_EXTRACT(token, '([^:]+):([^:]+):([^:]+)', 1) AS movieId, (double)REGEX_EXTRACT(token, '([^:]+):([^:]+):([^:]+)', 2) AS rating;
parsed_clean = FILTER parsed BY (movieId IS NOT NULL AND movieId != '' AND rating IS NOT NULL);

grp_by_user = GROUP parsed_clean BY userId;
user_rating_stats = FOREACH grp_by_user GENERATE group AS userId, COUNT(parsed_clean) AS n_ratings, AVG(parsed_clean.rating) AS avg_rating;
STORE user_rating_stats INTO '/tmp/pig_output/user_rating_stats' USING PigStorage('\t');

grp_by_movie = GROUP parsed_clean BY movieId;
movie_rating_stats = FOREACH grp_by_movie GENERATE group AS movieId, COUNT(parsed_clean) AS n_ratings, AVG(parsed_clean.rating) AS avg_rating;
STORE movie_rating_stats INTO '/tmp/pig_output/movie_rating_stats' USING PigStorage('\t');

movie_min20 = FILTER movie_rating_stats BY n_ratings >= 20;
movie_sorted = ORDER movie_min20 BY avg_rating DESC, n_ratings DESC;
top50 = LIMIT movie_sorted 50;
STORE top50 INTO '/tmp/pig_output/top50_movies' USING PigStorage('\t');
