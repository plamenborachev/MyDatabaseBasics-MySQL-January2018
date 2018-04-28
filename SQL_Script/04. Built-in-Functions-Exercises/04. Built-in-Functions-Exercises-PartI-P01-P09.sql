-- ***************************Part I – Queries for SoftUni Database
-- **************************1.	Find Names of All Employees by First Name
SELECT first_name, last_name
FROM employees
WHERE first_name LIKE 'Sa%'
ORDER BY employee_id;
-- *****************************02. Find Names of All Employees by Last Name
SELECT first_name, last_name
FROM employees
WHERE last_name LIKE "%ei%"
ORDER BY employee_id;
-- *******************************03. Find First Names of All Employess
SELECT first_name
FROM employees
WHERE department_id IN (3, 10) AND EXTRACT(Year FROM hire_date) BETWEEN 1995 AND 2005
ORDER BY employee_id;
-- **********************************04. Find All Employees Except Engineers
SELECT first_name, last_name
FROM employees
WHERE job_title NOT LIKE '%engineer%'
ORDER BY employee_id;
-- ************************************05. Find Towns with Name Length
SELECT name
FROM towns
WHERE CHAR_LENGTH(name) = 5 OR CHAR_LENGTH(name) = 6
ORDER BY name;
-- *************************************06. Find Towns Starting With
SELECT town_id, name
FROM towns
WHERE name REGEXP '^[MKBE].*$'
ORDER BY name;
-- **************************************07. Find Towns Not Starting With
SELECT town_id, name
FROM towns
WHERE name REGEXP '^[^rbd].*$'
ORDER BY name;
-- **************************************8.	Create View Employees Hired After 2000 Year
CREATE VIEW v_employees_hired_after_2000 AS
SELECT first_name, last_name
FROM employees
WHERE EXTRACT(Year FROM hire_date) > 2000;
-- ***************************************9.	Length of Last Name
SELECT first_name, last_name
FROM employees
WHERE CHAR_LENGTH(last_name) = 5;




