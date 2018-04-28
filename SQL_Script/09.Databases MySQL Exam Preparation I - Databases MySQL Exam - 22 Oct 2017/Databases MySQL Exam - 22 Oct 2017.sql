CREATE DATABASE report_service;
USE report_service;

-- ******************************************01. DDL - Table Design
CREATE TABLE users(
id INT(11) UNSIGNED PRIMARY KEY AUTO_INCREMENT,
username VARCHAR(30) UNIQUE,
`password` VARCHAR(50) NOT NULL,
`name` VARCHAR(50),
gender VARCHAR(1),
birthdate DATETIME,
age INT(11) UNSIGNED,
email VARCHAR(50) NOT NULL
);

CREATE TABLE departments(
id INT(11) UNSIGNED PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50) NOT NULL
);

CREATE TABLE employees(
id INT(11) UNSIGNED PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(25),
last_name VARCHAR(25),
gender VARCHAR(1),
birthdate DATETIME,
age INT(11) UNSIGNED,
department_id INT(11) UNSIGNED,
CONSTRAINT fk_employees_departments
FOREIGN KEY (department_id) REFERENCES departments(id)
);

CREATE TABLE categories(
id INT(11) UNSIGNED PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50) NOT NULL,
department_id INT(11) UNSIGNED,
CONSTRAINT fk_categories_departments
FOREIGN KEY (department_id) REFERENCES departments(id)
);

CREATE TABLE `status`(
id INT(11) UNSIGNED PRIMARY KEY AUTO_INCREMENT,
label VARCHAR(30) NOT NULL
);

CREATE TABLE reports(
id INT(11) UNSIGNED PRIMARY KEY AUTO_INCREMENT,
category_id INT(11) UNSIGNED,
status_id INT(11) UNSIGNED,
open_date DATETIME,
close_date DATETIME,
description VARCHAR(200),
user_id INT(11) UNSIGNED,
employee_id INT(11) UNSIGNED,
CONSTRAINT fk_reports_categories FOREIGN KEY (category_id) REFERENCES categories(id),
CONSTRAINT fk_reports_status FOREIGN KEY (status_id) REFERENCES `status`(id),
CONSTRAINT fk_reports_users FOREIGN KEY (user_id) REFERENCES users(id),
CONSTRAINT fk_reports_employees FOREIGN KEY (employee_id) REFERENCES employees(id)
);

-- ******************************************2. Insert
INSERT INTO employees(first_name, last_name, gender, birthdate, department_id)
SELECT e.first_name, e.last_name, e.gender, e.birthdate, e.department_id
FROM employees AS e
WHERE e.id = 1;

INSERT INTO employees(first_name, last_name, gender, birthdate, department_id)
VALUES
('Marlo', 'O\'Malley', 'M', '1958-09-21', 1),
('Niki', 'Stanaghan', 'F', '1969-11-26', 4),
('Ayrton', 'Senna', 'M', '1960-03-21', 9),
('Ronnie', 'Peterson', 'M', '1944-02-14', 9),
('Giovanna', 'Amati', 'F', '1959-07-20', 5);

INSERT INTO reports(category_id, status_id, open_date, close_date, description, user_id, employee_id)
VALUES
(1, 1, '2017-04-13', NULL, 'Stuck Road on Str.133', 6, 2),
(6, 3, '2015-09-05', '2015-12-06', 'Charity trail running', 3, 5),
(14, 2, '2015-09-07', NULL, 'Falling bricks on Str.58', 5, 2),
(4, 3, '2017-07-03', '2017-07-06', 'Cut off streetlight on Str.11', 1, 1);

-- ********************************************3. Update
UPDATE reports AS r
SET r.status_id = 2
WHERE r.status_id = 1 AND r.category_id = 4;

-- *******************************************4. Delete
DELETE FROM reports
WHERE status_id = 4;

-- *********************************************5. Users by Age
SELECT u.username, u.age
FROM users AS u
ORDER BY u.age ASC, u.username DESC;

-- ********************************************6. Unassigned Reports
SELECT r.description, r.open_date
FROM reports AS r
WHERE r.employee_id IS NULL
ORDER BY r.open_date, r.description;

-- **********************************************7. Employees and Reports
SELECT e.first_name, e.last_name, r.description, DATE_FORMAT(r.open_date, '%Y-%m-%d') AS open_date
FROM employees AS e
JOIN reports AS r ON e.id = r.employee_id
ORDER BY e.id, r.open_date, r.id;

-- ***********************************************8. Most Reported Category
SELECT c.`name` AS category_name, COUNT(r.id) AS reports_number
FROM categories AS c
JOIN reports AS r ON c.id = r.category_id
GROUP BY c.id
ORDER BY reports_number ASC, c.`name` ASC;

-- ************************************************9. One Category Employees
SELECT c.`name` AS category_name, COUNT(e.id) AS employees_number
FROM categories AS c
JOIN departments AS d ON c.department_id = d.id
JOIN employees AS e ON d.id = e.department_id
GROUP BY c.id
ORDER BY category_name;

-- *************************************************10. Birthday Report
SELECT DISTINCT c.`name` AS category_name
FROM categories AS c
JOIN reports AS r ON c.id = r.category_id
JOIN users AS u ON r.user_id = u.id
WHERE MONTH(r.open_date) = MONTH(u.birthdate) AND DAY(r.open_date) = DAY(u.birthdate)
ORDER BY c.`name` ASC;

-- *************************************************11. Users per Employee
SELECT CONCAT(e.first_name, ' ', e.last_name) AS `name`, COUNT(r.user_id) AS users_count
FROM employees AS e
LEFT JOIN reports AS r ON e.id = r.employee_id
GROUP BY e.id
ORDER BY users_count DESC, `name` ASC;

-- *************************************************12. Emergency Patrol
SELECT r.open_date, r.description, u.email AS reporter_email
FROM reports AS r
JOIN categories AS c ON r.category_id = c.id
JOIN departments AS d ON c.department_id = d.id
JOIN users AS u ON r.user_id = u.id
WHERE r.close_date IS NULL
	AND CHAR_LENGTH(r.description) > 20
    AND r.description LIKE '%str%'
    AND d.`name` IN('Infrastructure', 'Emergency', 'Roads Maintenance')
ORDER BY r.open_date, u.email, r.id;

-- ************************************************13. Numbers Coincidence
SELECT DISTINCT u.username
FROM users AS u
JOIN reports AS r ON u.id = r.user_id
WHERE (LEFT(u.username, 1) REGEXP '[0-9]' AND r.category_id = LEFT(u.username, 1))
	OR (RIGHT(u.username, 1) REGEXP '[0-9]' AND r.category_id = RIGHT(u.username, 1))
ORDER BY u.username ASC;

-- ***********************************************14. Open/Closed Statistics
SELECT CONCAT(e.first_name, ' ', e.last_name) AS `name`,
	CONCAT(CAST(COUNT(r.close_date) AS CHAR), '/',
			CAST(COUNT(IF (YEAR(r.open_date) = 2016, r.open_date, NULL)) AS CHAR))
	AS closed_open_reports
FROM employees AS e
JOIN reports AS r ON r.employee_id = e.id
WHERE YEAR(r.close_date) = 2016 OR YEAR(r.open_date) = 2016
GROUP BY e.id
ORDER BY `name`;

-- *********************************************15. Average Closing Time
SELECT d.`name` AS department_name,
	IF(FLOOR(AVG(TIMESTAMPDIFF(DAY, r.open_date, r.close_date))) IS NOT NULL,
		FLOOR(AVG(TIMESTAMPDIFF(DAY, r.open_date, r.close_date))), 'no info')
        AS average_duration
FROM departments AS d
JOIN categories AS c ON d.id = c.department_id
JOIN reports AS r ON c.id = r.category_id
GROUP BY department_name
ORDER BY department_name;

-- **********************************************16. Most Reported Category
SELECT d.`name` AS department_name, c.`name` AS category_name,
		ROUND((COUNT(c.`name`) * 100) / (SELECT COUNT(c2.`name`)
										FROM departments AS d2
										JOIN categories AS c2 ON d2.id = c2.department_id
										JOIN reports AS r2 ON c2.id = r2.category_id
										WHERE d2.id = d.id
										GROUP BY d2.`name`),
                                        0)
		AS percentage
FROM departments AS d
JOIN categories AS c ON d.id = c.department_id
JOIN reports AS r ON c.id = r.category_id
GROUP BY d.`name`, c.`name`
ORDER BY department_name, category_name;

-- ************************************************17. Get Reports
DELIMITER $$
CREATE FUNCTION udf_get_reports_count(employee_id INT, status_id INT)
RETURNS INT
BEGIN
	DECLARE reports_count INT;
    SET reports_count := IF((SELECT COUNT(r.id)
							FROM reports AS r
							WHERE r.employee_id = employee_id AND r.status_id = status_id
							GROUP BY r.status_id) IS NOT NULL, (SELECT COUNT(r.id)
																FROM reports AS r
																WHERE r.employee_id = employee_id
																	AND r.status_id = status_id
																GROUP BY r.status_id), 0);
	RETURN reports_count;
END $$

DELIMITER ;

SELECT id, first_name, last_name, udf_get_reports_count(id, 2) AS reports_count
FROM employees AS e
ORDER BY e.id;

-- ********************************************18. Assign Employee
DELIMITER $$
CREATE PROCEDURE usp_assign_employee_to_report(employee_id INT, report_id INT)
BEGIN
	START TRANSACTION;
		IF((SELECT e.department_id
        FROM employees AS e
        WHERE e.id = employee_id) != (SELECT c.department_id
										FROM reports AS r
										JOIN categories AS c ON r.category_id = c.id
										WHERE r.id = report_id))
		THEN SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Employee doesn\'t belong to the appropriate department!';
        ROLLBACK;
        ELSE
			UPDATE reports AS r2
            SET r2.employee_id = employee_id
            WHERE r2.id = report_id;
		END IF;
END $$

DELIMITER ;

CALL usp_assign_employee_to_report(30, 1);
CALL usp_assign_employee_to_report(17, 2);
SELECT employee_id FROM reports WHERE id = 2;

-- *************************************************19. Close Reports
DELIMITER $$

CREATE TRIGGER tr_close_reports
BEFORE UPDATE
ON reports
FOR EACH ROW
BEGIN
	SET NEW.status_id = 3; 
END $$

DELIMITER ;

DROP TRIGGER tr_close_reports;

UPDATE reports
SET close_date = now()
WHERE employee_id = 5;

-- *************************************************20. Categories Revision
SELECT c.`name` AS category_name, COUNT(r.id) AS reports_number,
CASE
	WHEN (SELECT COUNT(*)
			FROM reports AS r1
			WHERE r1.status_id = (SELECT s1.id
									FROM `status` AS s1
									WHERE s1.label = 'waiting')
				AND r1.category_id = c.id)
                > (SELECT COUNT(*)
					FROM reports AS r1
					WHERE r1.status_id = (SELECT s1.id
											FROM `status` AS s1
											WHERE s1.label = 'in progress')
						AND r1.category_id = c.id)
			THEN 'waiting'
		WHEN (SELECT COUNT(*)
			FROM reports AS r1
			WHERE r1.status_id = (SELECT s1.id
									FROM `status` AS s1
									WHERE s1.label = 'waiting')
				AND r1.category_id = c.id) < (SELECT COUNT(*)
												FROM reports AS r1
												WHERE r1.status_id =
													(SELECT s1.id
														FROM `status` AS s1
                                                        WHERE s1.label = 'in progress')
													AND r1.category_id = c.id)
			THEN 'in progress'
		ELSE 'equal'
        END AS main_status
FROM categories AS c
JOIN reports AS r ON c.id = r.category_id
JOIN `status` AS s ON r.status_id = s.id
WHERE s.label IN ('waiting', 'in progress')
GROUP BY c.`name`
ORDER BY c.`name`;








