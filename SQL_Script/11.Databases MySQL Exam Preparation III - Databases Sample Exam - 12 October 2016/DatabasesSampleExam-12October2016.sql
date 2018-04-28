-- ********************************Section 1: DDL
CREATE TABLE deposit_types(
deposit_type_id INT PRIMARY KEY AUTO_INCREMENT,
deposit_name VARCHAR(20)
);

CREATE TABLE deposits(
deposit_id INT PRIMARY KEY AUTO_INCREMENT,
amount DECIMAL(10,2),
start_date DATE,
end_date DATE,
deposit_type_id INT,
customer_id INT,
CONSTRAINT fk_deposits_deposit_types
FOREIGN KEY (deposit_type_id) REFERENCES deposit_types(deposit_type_id),
CONSTRAINT fk_deposits_customers
FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE employees_deposits (
employee_id INT,
deposit_id INT,
 CONSTRAINT pk_employees_deposits PRIMARY KEY (employee_id, deposit_id),
 CONSTRAINT fk_employees_deposits_employee_id
 FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
 CONSTRAINT fk_employees_deposits_deposit_id
 FOREIGN KEY (deposit_id) REFERENCES deposits(deposit_id)
);

CREATE TABLE credit_history(
credit_history_id INT PRIMARY KEY AUTO_INCREMENT,
mark CHAR(1),
start_date DATE,
end_date DATE,
customer_id INT,
CONSTRAINT fk_credit_history_customers
FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE payments(
payement_id INT PRIMARY KEY AUTO_INCREMENT,
`date` DATE,
amount DECIMAL(10,2),
loan_id INT,
CONSTRAINT fk_payments_loans
FOREIGN KEY (loan_id) REFERENCES loans(loan_id)
);

CREATE TABLE users(
user_id INT PRIMARY KEY AUTO_INCREMENT,
user_name VARCHAR(20),
`password` VARCHAR(20),
customer_id INT UNIQUE,
CONSTRAINT fk_users_customers
FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

ALTER TABLE employees
ADD COLUMN manager_id INT,
ADD CONSTRAINT fk_employees_employees
FOREIGN KEY (manager_id) REFERENCES employees(employee_id);

-- *****************************************Section 2: DML - P01. Inserts
INSERT INTO deposit_types(deposit_type_id, deposit_name)
VALUES
(1, 'Time Deposit'),
(2, 'Call Deposit'),
(3, 'Free Deposit');

INSERT INTO deposits(amount, start_date, deposit_type_id, customer_id)
SELECT
	CASE
		WHEN c.date_of_birth > '1980-01-01' AND c.gender = 'M' THEN 1100
		WHEN c.date_of_birth > '1980-01-01' AND c.gender = 'F' THEN 1200
		WHEN c.date_of_birth < '1980-01-01' AND c.gender = 'M' THEN 1600
        ELSE 1700
	END,
    DATE(now()),
    CASE
		WHEN c.customer_id <= 15 AND c.customer_id % 2 = 1 THEN 1
		WHEN c.customer_id <= 15 AND c.customer_id % 2 = 0 THEN 2
        ELSE 3
	END,
    c.customer_id
FROM customers AS c
WHERE c.customer_id < 20;

INSERT INTO employees_deposits(employee_id, deposit_id)
VALUES(15, 4),
(20, 15),
(8, 7),
(4, 8),
(3, 13),
(3, 8),
(4, 10),
(10, 1),
(13, 4),
(14, 9);

-- ***************************************Section 2: DML - P02. Update
UPDATE employees AS e
SET e.manager_id = CASE
						WHEN e.employee_id BETWEEN 2 AND 10 THEN 1
						WHEN e.employee_id BETWEEN 12 AND 20 THEN 11
						WHEN e.employee_id BETWEEN 22 AND 30 THEN 21
						WHEN e.employee_id IN (11, 21) THEN 1
					END;
                    
-- *****************************************Section 2: DML - P03. Delete
DELETE FROM employees_deposits
WHERE deposit_id = 9 OR employee_id = 3;

-- *****************************************Section 3: Querying - P01. Employees’ Salary
SELECT e.employee_id, e.hire_date, e.salary, e.branch_id
FROM employees AS e
WHERE e.salary > 2000 AND e.hire_date >'2009-06-15';

-- *******************************************Section 3: Querying - P02. Customer Age
SELECT c.first_name AS FirstName,
		c.date_of_birth AS DateOfBirth,
		timestampdiff(YEAR, c.date_of_birth, '2016-10-01') AS `Age`
FROM customers AS c
WHERE timestampdiff(YEAR, c.date_of_birth, '2016-10-01') BETWEEN 40 AND 50;

-- *********************************************Section 3: Querying - P03. Customer City
SELECT c.customer_id, c.first_name, c.last_name, c.gender, ct.city_name
FROM customers AS c
JOIN cities AS ct ON c.city_id = ct.city_id
WHERE (c.last_name LIKE 'Bu%' OR c.first_name LIKE '%a') AND CHAR_LENGTH(ct.city_name) >= 8;

-- *******************************************Section 3: Querying - P04. Employee Accounts
SELECT e.employee_id, e.first_name, a.account_number
FROM employees AS e
JOIN employees_accounts AS ea ON e.employee_id = ea.employee_id
JOIN accounts AS a ON ea.account_id = a.account_id
WHERE YEAR(a.start_date) > 2012
ORDER BY e.first_name DESC
LIMIT 5;

-- ********************************************Section 3: Querying - P05. Count Cities
SELECT c.city_name, b.`name`, COUNT(e.employee_id) AS EmployeesCount
FROM employees AS e
JOIN branches AS b ON e.branch_id = b.branch_id
JOIN cities AS c ON b.city_id = c.city_id
WHERE c.city_id NOT IN (4,5)
GROUP BY c.city_name, b.`name`
HAVING EmployeesCount >= 3;

-- *********************************************Section 3: Querying - P06. Loan Statistics
SELECT SUM(l.amount), MAX(l.interest), MIN(e.salary)
FROM employees AS e
JOIN employees_loans AS el ON e.employee_id = el.employee_id
JOIN loans AS l ON el.loan_id = l.loan_id;

-- ***********************************************Section 3: Querying - P07. Unite People
(SELECT e.first_name, c.city_name
FROM employees AS e
JOIN branches AS b ON e.branch_id = b.branch_id
JOIN cities AS c ON b.city_id = c.city_id
LIMIT 3)

UNION ALL

(SELECT c.first_name, ct.city_name
FROM customers AS c
JOIN cities AS ct ON c.city_id = ct.city_id
LIMIT 3);

-- ****************************************Section 3: Querying - P08. Customers w/o Accounts
SELECT c.customer_id, c.height
FROM customers AS c
LEFT JOIN accounts AS a ON c.customer_id = a.customer_id
WHERE c.height BETWEEN 1.74 AND 2.04 AND a.account_id IS NULL;

-- ******************************************Section 3: Querying - P09. Average Loans
SELECT c.customer_id, l.amount
FROM customers AS c
JOIN loans AS l ON c.customer_id = l.customer_id
WHERE l.amount > (SELECT AVG(l2.amount)
					FROM loans AS l2
					JOIN customers AS c2 ON l2.customer_id = c2.customer_id
					WHERE c2.gender = 'M')
ORDER BY c.last_name
LIMIT 5;

-- *******************************************Section 3: Querying - P10. Oldest Account
SELECT c.customer_id, c.first_name, a.start_date
FROM customers AS c
JOIN accounts AS a ON c.customer_id = a.customer_id
WHERE a.start_date = (SELECT a2.start_date
						FROM accounts AS a2
						ORDER BY a2.start_date
						LIMIT 1);
                        
-- ********************************************Section 4: Programmability - P01. String Joiner
DELIMITER $$
CREATE FUNCTION udf_concat_string(first_string VARCHAR(255), second_string VARCHAR(255))
RETURNS VARCHAR(255)
BEGIN
	RETURN CONCAT(REVERSE(first_string), REVERSE(second_string));
END $$

DELIMITER ;

SELECT udf_concat_string('abc', 'def');

-- ******************************************Section 4: Programmability - P02. Inexpired Loans
DELIMITER $$
CREATE PROCEDURE usp_customers_with_unexpired_loans(customer_id INT)
BEGIN
	SELECT c.customer_id, c.first_name, l.loan_id
	FROM customers AS c
	JOIN loans AS l ON c.customer_id = l.customer_id
	WHERE l.expiration_date IS NULL AND c.customer_id = customer_id;
END $$

DELIMITER ;

CALL usp_customers_with_unexpired_loans(9);
CALL usp_customers_with_unexpired_loans(50);

-- ******************************************Section 4: Programmability - P03. Take Loan
DROP PROCEDURE IF EXISTS usp_take_loan;

DELIMITER $$
CREATE PROCEDURE usp_take_loan(customer_id INT, loan_amount DECIMAL (18,2),
								interest DECIMAL(4,2), start_date DATE)
BEGIN
		START TRANSACTION;
			INSERT INTO loans(start_date, amount, interest, customer_id)
            VALUES(start_date, loan_amount, interest, customer_id);
		IF(loan_amount NOT BETWEEN 0.01 AND 100000)
			THEN ROLLBACK;
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid Loan Amount';
		ELSE
			COMMIT;
		END IF;
END $$

DELIMITER ;

CALL usp_take_loan(2, 500, 1, '2016-09-15');
CALL usp_take_loan(11, -500, 1, '2016-09-15');

-- *****************************************Section 4: Programmability - P04. Hire Employee
DELIMITER $$

CREATE TRIGGER tr_hire_employee
AFTER INSERT
ON employees
FOR EACH ROW
BEGIN
	INSERT INTO employees_loans
    VALUES(NEW.employee_id, (SELECT el.loan_id
								FROM employees_loans AS el
                                WHERE el.employee_id = NEW.employee_id - 1));
END $$

DELIMITER ;

INSERT INTO Employees VALUES (31, 'Jake', '20161212', 500, 2, 1);

-- *******************************************Section 5: Bonus - P01. Delete Trigger
CREATE TABLE account_logs( 
account_id INT,
account_number CHAR(12) NOT NULL,
start_date DATE NOT NULL,
customer_id INT NOT NULL,
CONSTRAINT pk_account_logs PRIMARY KEY(account_id),
CONSTRAINT fk_account_logs_customers FOREIGN KEY(customer_id) REFERENCES customers(customer_id)
);

DELIMITER $$

CREATE TRIGGER tr_delete_accounts
BEFORE DELETE
ON accounts
FOR EACH ROW
BEGIN
	DELETE FROM employees_accounts
    WHERE account_id = OLD.account_id;    
    INSERT INTO account_logs
    VALUES(OLD.account_id, OLD.account_number, OLD.start_date, OLD.customer_id);
   
END $$

DELIMITER ;

DROP TRIGGER IF EXISTS tr_delete_accounts;

DELETE FROM accounts WHERE customer_id = 6;











