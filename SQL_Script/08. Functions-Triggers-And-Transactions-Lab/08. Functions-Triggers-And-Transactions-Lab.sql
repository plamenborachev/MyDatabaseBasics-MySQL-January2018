-- ***********************************1.Count Employees by Town
DELIMITER $$
CREATE FUNCTION ufn_count_employees_by_town(town_name VARCHAR(20))
RETURNS DOUBLE 
BEGIN
	DECLARE e_count DOUBLE;
	SET e_count := (SELECT COUNT(employee_id) FROM employees AS e
	INNER JOIN addresses AS a ON a.address_id = e.address_id
	INNER JOIN towns AS t ON t.town_id = a.town_id
	WHERE t.name = town_name);
	RETURN e_count;
END $$

SELECT ufn_count_employees_by_town('Redmond'); $$

-- **************************************2.Employees Promotion
DELIMITER $$
CREATE PROCEDURE usp_raise_salaries(department_name VARCHAR(50))
BEGIN
	UPDATE employees AS e
	SET e.salary = e.salary * 1.05
	WHERE e.department_id = (SELECT d.department_id
							FROM departments AS d
                            WHERE d.name = department_name);
END $$

CALL usp_raise_salaries('Finance')$$

SELECT e.first_name, e.salary
FROM employees AS e
WHERE department_id = 10
ORDER BY e.first_name, e.salary DESC;

-- ***************************************3.Employees Promotion By ID
DELIMITER $$
CREATE PROCEDURE usp_raise_salary_by_id(id INT)
BEGIN 
	START TRANSACTION;
		UPDATE employees AS e
        SET e.salary = e. salary * 1.05
        WHERE e.employee_id = id;
    COMMIT;
END $$

SELECT e.salary
FROM employees AS e
WHERE e.employee_id = 178 $$

CALL usp_raise_salary_by_id(300);

-- ****************************************4.Triggered
CREATE TABLE deleted_employees(
employee_id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(50) NOT NULL,
last_name VARCHAR(50) NOT NULL,
middle_name VARCHAR(50),
job_title VARCHAR(50) NOT NULL,
department_id INT NOT NULL,
salary DECIMAL(19,4) NOT NULL
);

DELIMITER $$
CREATE TRIGGER tr_deleted_employees 
AFTER DELETE 
ON employees 
FOR EACH ROW 
BEGIN 
	INSERT INTO deleted_employees (first_name, last_name, middle_name, job_title, department_id, salary) 
	VALUES(OLD.first_name, OLD.last_name, OLD.middle_name, OLD.job_title, OLD.department_id, OLD.salary); 
END $$

-- *******************************************
DELIMITER $$ 

CREATE PROCEDURE usp_add_numbers 
(first_number INT, 
second_number INT, 
OUT result INT) 
BEGIN 
SET result = first_number + second_number;
END $$ 

DELIMITER ;  

SET @answer=0;

CALL usp_add_numbers(5, 6, @answer); 

SELECT @answer;     
    
    
    
    
    
