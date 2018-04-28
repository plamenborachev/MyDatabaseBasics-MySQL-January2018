-- *********************************01. Table Design
CREATE DATABASE closed_judge_system;
USE closed_judge_system;

CREATE TABLE users(
id INT PRIMARY KEY AUTO_INCREMENT,
username VARCHAR(30) UNIQUE NOT NULL,
`password` VARCHAR(30) NOT NULL,
email VARCHAR(50)
);

CREATE TABLE categories(
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50) NOT NULL,
parent_id INT,
CONSTRAINT fk_parent_id_categories_id
FOREIGN KEY (parent_id) REFERENCES categories(id)
);

CREATE TABLE contests(
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50) NOT NULL,
category_id INT,
CONSTRAINT fk_contests_category_id
FOREIGN KEY (category_id) REFERENCES categories(id)
);

CREATE TABLE problems(
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(100) NOT NULL,
points INT NOT NULL,
tests INT DEFAULT 0,
contest_id INT,
CONSTRAINT fk_problems_contest_id
FOREIGN KEY (contest_id) REFERENCES contests(id)
);

CREATE TABLE submissions(
id INT PRIMARY KEY AUTO_INCREMENT,
passed_tests INT NOT NULL,
problem_id INT,
user_id INT,
CONSTRAINT fk_submissions_problem_id
FOREIGN KEY (problem_id) REFERENCES problems(id),
CONSTRAINT fk_submissions_user_id
FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE users_contests(
user_id INT,
contest_id INT,
CONSTRAINT pk_user_id_contest_id PRIMARY KEY (user_id, contest_id),
CONSTRAINT fk_user_id FOREIGN KEY (user_id) REFERENCES users(id),
CONSTRAINT fk_contest_id FOREIGN KEY (contest_id) REFERENCES contests(id)
);

-- ****************************************02. Data Insertion
INSERT INTO submissions(passed_tests, problem_id, user_id)
SELECT CEILING(SQRT(POW(CHAR_LENGTH(p.name), 3)) - CHAR_LENGTH(p.name)),
		p.id,
		CEILING((p.id * 3) / 2)
		FROM problems AS p
		WHERE p.id BETWEEN 1 AND 10;

-- ****************************************03. Data Update
UPDATE problems AS p
JOIN contests AS co ON p.contest_id = co.id
JOIN categories AS ca ON co.category_id = ca.id
SET p.tests = CASE
					WHEN p.id % 3 = 0 THEN CHAR_LENGTH(ca.name)
					WHEN p.id % 3 = 1 THEN (SELECT sum(s.id)
											FROM submissions AS s
                                            WHERE s.problem_id = p.id
											GROUP BY s.problem_id)
					WHEN p.id % 3 = 2 THEN CHAR_LENGTH(co.name)
				END
WHERE p.tests = 0;
                    
-- ********************************************04. Data Deletion
DELETE u FROM users AS u
LEFT JOIN users_contests AS uc ON u.id = uc.user_id
WHERE uc.contest_id IS NULL;

-- *********************************************05. Users
SELECT u.id, u.username, u.email
FROM users AS u
ORDER BY u.id;

-- *******************************************06. Root Categories
SELECT c.id, c.name
FROM categories AS c
WHERE c.parent_id IS NULL
ORDER BY c.id;

-- ******************************************07. Well Tested Problems
SELECT p.id, p.name, p.tests
FROM problems AS p
WHERE p.tests > p.points AND p.name LIKE '% %'
ORDER BY p.id DESC;

-- *********************************************08. Full Path Problems
SELECT p.id, CONCAT_WS(' - ', ca.`name`, c.`name`, p.`name`) AS full_path
FROM problems AS p
JOIN contests AS c ON p.contest_id = c.id
JOIN categories AS ca ON c.category_id = ca.id
ORDER BY p.id;

-- ********************************************09. Leaf Categories
SELECT c1.id, c1.name
FROM categories AS c1
LEFT JOIN categories AS c2 ON c1.id = c2.parent_id
WHERE c2.parent_id IS NULL
ORDER BY c1.name, c1.id;

-- **********************************************10. Mainstream Passwords
SELECT DISTINCT u1.id, u1.username, u1.`password`
FROM users AS u1
JOIN users AS u2 ON u1.`password` = u2.`password` AND u1.username NOT LIKE u2.username
ORDER BY u1.username, u1.id;

-- *********************************************11. Most Participated Contests
SELECT *
FROM (SELECT c.id AS id, c.`name`, COUNT(uc.user_id) AS contestants
FROM contests AS c
LEFT JOIN users_contests AS uc ON uc.contest_id = c.id
GROUP BY uc.contest_id
ORDER BY contestants DESC	
LIMIT 5) AS r
ORDER BY r.contestants, r.id;

-- *******************************************12. Most Valuable Person
SELECT DISTINCT s.id, u.username, p.`name` ,CONCAT(s.passed_tests, ' / ', p.tests) AS result
FROM submissions AS s
JOIN users AS u ON s.user_id = u.id
JOIN users_contests AS uc ON u.id = uc.user_id
JOIN problems AS p ON s.problem_id = p.id
WHERE s.user_id = (SELECT uc.user_id
					FROM users_contests AS uc
					GROUP BY uc.user_id
					ORDER BY count(uc.contest_id) DESC
					LIMIT 1)
ORDER BY s.id DESC;

-- *******************************************13. Contests Maximum Points
SELECT c.id, c.name, sum(p.points) AS maximum_points
FROM contests AS c
JOIN problems AS p ON c.id = p.contest_id
GROUP BY c.id
ORDER BY maximum_points DESC, c.id;

-- ******************************************14. Contestants Submissions
SELECT c.id, c.`name`, COUNT(s.id) AS submissions
FROM contests AS c
JOIN problems AS p ON c.id = p.contest_id
JOIN submissions AS s ON p.id = s.problem_id
JOIN users_contests AS uc ON c.id = uc.contest_id AND s.user_id = uc.user_id
GROUP BY c.id
ORDER BY submissions DESC, c.id;

-- ********************************************15. Login
DELIMITER $$
CREATE PROCEDURE udp_login(username VARCHAR(30), `password` VARCHAR(30))
BEGIN
	CASE
		WHEN (SELECT u.username FROM users AS u WHERE u.username LIKE username) IS NULL
			THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Username does not exist!';
		WHEN (SELECT u.`password` FROM users AS u WHERE u.`password` LIKE `password`) IS NULL
			THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Password is incorrect!';
		WHEN (SELECT liu.username FROM logged_in_users AS liu WHERE liu.username LIKE username) IS NOT NULL
			THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User is already logged in!';
		ELSE INSERT INTO logged_in_users(id, username, `password`, email)
			SELECT u.id, u.username, u.`password`, u.email FROM users AS u WHERE u.username = username;
		END CASE;
END $$

DELIMITER ;

CALL udp_login('doge', 'doge');

-- ******************************************16. Evaluate Submission
DELIMITER $$
CREATE PROCEDURE udp_evaluate(id INT)
BEGIN
	IF(SELECT s.id FROM submissions AS s WHERE s.id = id) IS NULL
		THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Submission does not exist!';
	ELSE
		INSERT INTO evaluated_submissions
        SELECT s.id, p.`name`, u.username, CEILING(p.points / p.tests * s.passed_tests)
        FROM submissions AS s
        JOIN problems AS p ON s.problem_id = p.id
        JOIN users AS u ON s.user_id = u.id
        WHERE s.id = id;
	END IF;
END $$

DELIMITER ;

CALL udp_evaluate(1);

-- *******************************************17. Check Constraint
DELIMITER $$
CREATE TRIGGER tr_check_constraint
BEFORE INSERT
ON problems
FOR EACH ROW
BEGIN	
		IF NEW.`name` NOT LIKE '% %'
			THEN SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'The given name is invalid!';		
		ELSEIF NEW.points <= 0
			THEN SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'The problem’s points cannot be less or equal to 0!';		
		ELSEIF NEW.tests <= 0
			THEN SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'The problem’s tests cannot be less or equal to 0!';		
		END IF;
END $$

DELIMITER ;

DROP TRIGGER tr_check_constraint;

INSERT INTO problems
VALUES(1, 'asd asd', 0, 2 );










