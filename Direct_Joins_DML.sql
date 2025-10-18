DROP TABLE if exists GENRES CASCADE CONSTRAINT;
DROP TABLE if exists MOVIES CASCADE CONSTRAINT;

-- Create GENRES table
CREATE TABLE GENRES (
    GENRE_ID INT PRIMARY KEY,
    GENRE_NAME VARCHAR(50)
);

-- Create MOVIES table
CREATE TABLE MOVIES (
    MOVIE_ID INT PRIMARY KEY,
    TITLE VARCHAR(100),
    GENRE_ID INT,
    RATING DECIMAL(3,1),
    FOREIGN KEY (GENRE_ID) REFERENCES GENRES(GENRE_ID)
);

-- Insert sample data into GENRES table
INSERT INTO GENRES (GENRE_ID, GENRE_NAME) VALUES
(1, 'Thriller'),
(2, 'Horror'),
(3, 'Comedy'),
(4, 'Drama');

-- Insert sample data into MOVIES table
INSERT INTO MOVIES (MOVIE_ID, TITLE, GENRE_ID, RATING) VALUES
(1, 'The Silence of the Lambs', 1, 8.6),
(2, 'Psycho', 2, 8.5),
(3, 'Airplane!', 3, 7.7),
(4, 'The Shawshank Redemption', 4, 9.3),
(5, 'Seven', 1, 8.6),
(6, 'A Nightmare on Elm Street', 2, 7.5),
(7, 'Monty Python and the Holy Grail', 3, 8.2),
(8, 'The Godfather', 4, 9.2);

SELECT m.movie_id, m.title, m.genre_id, m.rating
FROM movies m
JOIN genres g ON m.genre_id = g.genre_id
WHERE g.genre_name = 'Thriller';

UPDATE movies m
SET m.rating = m.rating + 0.5
FROM genres g
WHERE m.genre_id = g.genre_id
AND g.genre_name = 'Thriller';

SELECT m.movie_id, m.title, m.genre_id, m.rating
FROM movies m
JOIN genres g ON m.genre_id = g.genre_id
WHERE g.genre_name = 'Horror';

DELETE FROM movies m
FROM genres g
WHERE m.genre_id = g.genre_id
AND g.genre_name = 'Horror';

DROP TABLE if exists GENRES CASCADE CONSTRAINT;
DROP TABLE if exists MOVIES CASCADE CONSTRAINT;