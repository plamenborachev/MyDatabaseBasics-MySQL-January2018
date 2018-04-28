**************************Problem 1: Select Employee Information
SELECT id, first_name, last_name, job_title
FROM employees
ORDER BY id;
*****************************Problem 2: Select Employees with Filter
SELECT id, concat(first_name, ' ', last_name) AS full_name, job_title, salary
FROM employees
WHERE salary > 1000.00
ORDER BY id;
*******************************Problem 3: Update Employees Salary
UPDATE employees
SET salary = salary * 1.1
WHERE job_title = "Therapist";
SELECT salary
FROM employees
ORDER BY salary;
**********************************Problem 4: Top Paid Employee
CREATE VIEW `top_paid_employee` AS
SELECT * FROM `employees`
ORDER BY `salary` DESC
LIMIT 1;
SELECT * FROM `top_paid_employee`;
*************************************Problem 5: Select Employees by Multiple Filters
SELECT * FROM employees
WHERE department_id = 4 AND salary >= 1600
ORDER BY id;
***************************************Problem 6: Delete from Table
DELETE FROM employees
WHERE department_id IN (2, 1);
SELECT * FROM employees
ORDER BY id;