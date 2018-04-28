******************************01.	Create Database
CREATE DATABASE minions;
USE minions;
******************************02. Create Tables
CREATE TABLE minions(
id INT NOT NULL,
name VARCHAR(50) NOT NULL,
age INT
);
CREATE TABLE towns(
id INT NOT NULL,
name VARCHAR(50) NOT NULL
);
ALTER TABLE minions
ADD CONSTRAINT pk_id
PRIMARY KEY (id);
ALTER TABLE towns
ADD CONSTRAINT pk_id
PRIMARY KEY (id);
******************************03. Alter Minions Table
ALTER TABLE minions
ADD COLUMN town_id INT NOT NULL;
ALTER TABLE minions
ADD CONSTRAINT fk_minions_towns
FOREIGN KEY (town_id) REFERENCES towns(id);
*******************************04. Insert Records in Both Tables
INSERT INTO towns (id, name)
VALUES (1, "Sofia"), (2, "Plovdiv"), (3, "Varna");
INSERT INTO minions (id, name, age, town_id)
VALUES (1, "Kevin", 22, 1), (2, "Bob", 15, 3), (3, "Steward", NULL, 2);
******************************05. Truncate Table Minions
TRUNCATE TABLE minions;
******************************06. Drop All Tables
DROP TABLE minions;
DROP TABLE towns;
******************************07. Create Table People
CREATE TABLE people(
id INT UNIQUE AUTO_INCREMENT,
name VARCHAR(200) NOT NULL,
picture MEDIUMBLOB,
height DOUBLE(10, 2),
weight DOUBLE(10,2),
gender ENUM('m', 'f') NOT NULL,
birthdate DATE NOT NULL,
biography LONGTEXT
);
ALTER TABLE people
ADD CONSTRAINT pk_id
PRIMARY KEY (id);
INSERT INTO people(name, picture, height, weight, gender, birthdate, biography)
VALUES ('Pesho', picture, 2.22, 3.33, 'm', '1978-04-07', 'longtext'),
('Pesho', picture, 2.22, 3.33, 'm', '1978-04-07', 'longtext'),
('Pesho', picture, 2.22, 3.33, 'm', '1978-04-07', 'longtext'),
('Pesho', picture, 2.22, 3.33, 'm', '1978-04-07', 'longtext'),
('Pesho', picture, 2.22, 3.33, 'm', '1978-04-07', 'longtext');
******************************08. Create Table Users
CREATE TABLE users(
id BIGINT UNIQUE AUTO_INCREMENT,
username VARCHAR(30) UNIQUE NOT NULL,
password VARCHAR(26) NOT NULL,
profile_picture MEDIUMBLOB,
last_login_time DATETIME,
is_deleted ENUM('true', 'false')
);
ALTER TABLE users
ADD CONSTRAINT pk_id
PRIMARY KEY (id);
INSERT INTO users (username, password, profile_picture, last_login_time, is_deleted)
VALUES ('Test1', 'Test2', 'picture', '2018-01-18 20:46:00', 'true'),
('Test2', 'Test2', 'picture', '2018-01-18 20:46:00', 'true'),
('Test3', 'Test2', 'picture', '2018-01-18 20:46:00', 'true'),
('Test4', 'Test2', 'picture', '2018-01-18 20:46:00', 'true'),
('Test5', 'Test2', 'picture', '2018-01-18 20:46:00', 'true');
******************************09. Change Primary Key
ALTER TABLE users
DROP PRIMARY KEY,
ADD CONSTRAINT pk_users
PRIMARY KEY (id, username);
-- /**My Code with compile time error in JUDGE:
-- ***ALTER TABLE users
-- ***DROP PRIMARY KEY;
-- ***ALTER TABLE users
-- ***ADD CONSTRAINT pk_users
-- ***PRIMARY KEY (id, username);**/
******************************10. Set Default Value of a Field
ALTER TABLE users
MODIFY  COLUMN last_login_time DATETIME DEFAULT CURRENT_TIMESTAMP;
******************************11. Set Unique Field
/* First line is needed for Judge in order not to give "Compile time error"*/
ALTER TABLE users MODIFY id BIGINT NOT NULL;
ALTER TABLE users
DROP PRIMARY KEY;
ALTER TABLE users
ADD CONSTRAINT pk_users
PRIMARY KEY (id);
ALTER TABLE users
ADD CONSTRAINT uq_username
UNIQUE (username);
******************************12. Movies Database
-- CREATE DATABASE movies;
-- USE movies;
CREATE TABLE directors(
id INT PRIMARY KEY AUTO_INCREMENT,
director_name VARCHAR(30) NOT NULL,
notes TEXT
);
CREATE TABLE genres(
id INT PRIMARY KEY AUTO_INCREMENT,
genre_name VARCHAR(30) NOT NULL,
notes TEXT
);
CREATE TABLE categories(
id INT PRIMARY KEY AUTO_INCREMENT,
category_name VARCHAR(30) NOT NULL,
notes TEXT
);
CREATE TABLE movies(
id INT PRIMARY KEY AUTO_INCREMENT,
title VARCHAR(255) NOT NULL,
director_id INT NOT NULL,
copyright_year YEAR NOT NULL,
`length` INT NOT NULL,
genre_id INT NOT NULL,
category_id INT NOT NULL,
rating DOUBLE,
notes TEXT
);
INSERT INTO directors(director_name, notes)
VALUES('Director1', 'Some notes'),
('Director1', 'Some notes'),
('Director1', 'Some notes'),
('Director1', 'Some notes'),
('Director1', 'Some notes');
INSERT INTO genres(genre_name, notes)
VALUES('genre1', 'Some notes'),
('genre1', 'Some notes'),
('genre1', 'Some notes'),
('genre1', 'Some notes'),
('genre1', 'Some notes');
INSERT INTO categories(category_name, notes)
VALUES('Category', 'Some notes'),
('Category', 'Some notes'),
('Category', 'Some notes'),
('Category', 'Some notes'),
('Category', 'Some notes');
INSERT INTO MOVIES(title, director_id, copyright_year, `length`, genre_id, category_id, rating, notes)
VALUES('title', 1, '1978', 100, 2, 3, 7.8, 'Notes'),
('title', 1, '1978', 100, 2, 3, 7.8, 'Notes'),
('title', 1, '1978', 100, 2, 3, 7.8, 'Notes'),
('title', 1, '1978', 100, 2, 3, 7.8, 'Notes'),
('title', 1, '1978', 100, 2, 3, 7.8, 'Notes');