-- *******************************01.Employees with Salary Above 35000
DELIMITER $$
CREATE PROCEDURE usp_get_employees_salary_above_35000()
BEGIN
	SELECT e.first_name, e.last_name
    FROM `employees` AS e
    WHERE e.salary > 35000
    ORDER BY e.first_name, e.last_name, e.employee_id;
END $$

CALL usp_get_employees_salary_above_35000();

-- **********************************02.Employees with Salary Above Number
DELIMITER $$
CREATE PROCEDURE usp_get_employees_salary_above(salary_amount DECIMAL(19,4))
BEGIN
	SELECT e.first_name, e.last_name
    FROM employees AS e
	WHERE e.salary >= salary_amount
    ORDER BY e.first_name, e.last_name, e.employee_id;
END $$

CALL usp_get_employees_salary_above(48100);

-- ***********************************03.Town Names Starting With
DELIMITER $$
CREATE PROCEDURE usp_get_towns_starting_with(start_of_town_name VARCHAR(10))
BEGIN
	SELECT t.name
    FROM towns AS t
    WHERE t.name LIKE CONCAT(start_of_town_name, '%')
    ORDER BY t.name;
END $$

CALL usp_get_towns_starting_with('b');

-- ***********************************04.Employees from Town
DELIMITER $$
CREATE PROCEDURE usp_get_employees_from_town(town_name VARCHAR(50))
BEGIN
	SELECT e.first_name, e.last_name
	FROM employees AS e
	JOIN addresses AS a ON a.address_id = e.address_id
	JOIN towns AS t ON t.town_id = a.town_id
	WHERE t.`name` = town_name
	ORDER BY e.first_name, e.last_name, e.employee_id;    
END $$

CALL usp_get_employees_from_town('Sofia');

-- ************************************05.Salary Level Function
DELIMITER $$
CREATE FUNCTION ufn_get_salary_level(salary DECIMAL(19,4)) 
RETURNS VARCHAR(10)
BEGIN
	DECLARE salary_level VARCHAR(10);
    SET salary_level := CASE
							WHEN salary < 30000 THEN 'Low'
							WHEN salary <= 50000 THEN 'Average'
							ELSE 'High'
						END;						
    RETURN salary_level;
END $$

SELECT ufn_get_salary_level(43300);

-- ***************************************06.Employees by Salary Level
DELIMITER $$
CREATE FUNCTION ufn_get_salary_level(salary DECIMAL(19,4)) 
RETURNS VARCHAR(10)
BEGIN
	DECLARE salary_level VARCHAR(10);
    SET salary_level := CASE
								WHEN salary < 30000 THEN 'Low'
								WHEN salary <= 50000 THEN 'Average'
								ELSE 'High'
							END;						
    RETURN salary_level;
END $$

CREATE PROCEDURE usp_get_employees_by_salary_level(level_of_salary VARCHAR(10))
BEGIN
	SELECT e.first_name, e.last_name
	FROM employees AS e
	WHERE ufn_get_salary_level(e.salary) = level_of_salary
	ORDER BY e.first_name DESC, e.last_name DESC;
END $$

CALL usp_get_employees_by_salary_level('High');

-- ****************************************07.Define Function
DELIMITER $$
CREATE FUNCTION ufn_is_word_comprised(set_of_letters varchar(50), word varchar(50))
RETURNS BIT
BEGIN
	DECLARE result BIT;
		SET result := CASE
						WHEN word REGEXP CONCAT('^[', set_of_letters, ']+$') THEN 1
						ELSE 0
					END;
		RETURN result;
END $$

SELECT ufn_is_word_comprised('oistmiahf', 'Sofia') AS `result` $$
SELECT ufn_is_word_comprised('oistmiahf', 'halves') AS `result` $$
SELECT ufn_is_word_comprised('bobr', 'Rob') AS `result` $$
SELECT ufn_is_word_comprised('pppp', 'Guy') AS `result` $$

-- ******************************************8.Find Full Name
DELIMITER $$
CREATE PROCEDURE usp_get_holders_full_name()
BEGIN
	SELECT CONCAT(ah.first_name, ' ', ah.last_name) AS `full_name`
    FROM account_holders AS ah
    ORDER BY full_name, ah.id;
END $$

CALL usp_get_holders_full_name()$$

-- *************************************9.People with Balance Higher Than
DELIMITER $$
CREATE PROCEDURE usp_get_holders_with_balance_higher_than(min_balance DECIMAL(19,4))
BEGIN
	SELECT ah.first_name, ah.last_name
	FROM account_holders AS ah
	JOIN accounts AS a ON a.account_holder_id = ah.id
	GROUP BY ah.id
	HAVING SUM(a.balance) > min_balance
	ORDER BY a.id;
END $$

CALL usp_get_holders_with_balance_higher_than(7000);

-- ***************************************10.Future Value Function
DELIMITER $$
CREATE FUNCTION ufn_calculate_future_value(initial_sum DECIMAL(19,4),
											yearly_interest_rate DECIMAL(10,4),
                                            number_of_years INT)
RETURNS DOUBLE
BEGIN
	DECLARE future_value DOUBLE(19,2);
	SET future_value := initial_sum * POW((1 + yearly_interest_rate), number_of_years);
	RETURN future_value;
END $$

SELECT ufn_calculate_future_value(1000, 0.1, 5) AS result $$
SELECT ufn_calculate_future_value(0.00, 0.1, 5) AS result $$
SELECT ufn_calculate_future_value(1500.00, 0.04, 2) AS result $$

-- ******************************************11.Calculating Interest
DELIMITER $$
CREATE FUNCTION ufn_calculate_future_value(initial_sum DECIMAL(19,4),
											yearly_interest_rate DECIMAL(10,4),
                                            number_of_years INT)
RETURNS DECIMAL(19,4)
BEGIN
	DECLARE future_value DECIMAL(19,4);
		SET future_value := initial_sum * POW((1.00 + yearly_interest_rate), number_of_years);
RETURN future_value;
END $$

CREATE PROCEDURE usp_calculate_future_value_for_account(account_id INT, interest_rate DECIMAL(10,4))
BEGIN
	SELECT a.id,
		ah.first_name,
        ah.last_name,
        a.balance AS `current_balance`,
        ufn_calculate_future_value((SELECT balance FROM accounts WHERE id = a.id), interest_rate, 5)	AS balance_in_5_years	
	FROM account_holders AS ah
	JOIN accounts AS a ON a.account_holder_id = ah.id
	WHERE a.id = account_id;
END $$

CALL usp_calculate_future_value_for_account(1, 0.1);

-- *******************************************12.Deposit Money
DELIMITER $$
CREATE PROCEDURE usp_deposit_money(account_id INT, money_amount DECIMAL(19,4))
BEGIN
	UPDATE accounts AS a
    SET a.balance = a.balance + money_amount
    WHERE a.id = account_id AND money_amount > 0;
END $$

CALL usp_deposit_money(1, -10) $$

SELECT *
FROM accounts AS a
WHERE a.id = 1;

-- *******************************************13.Withdraw Money
DELIMITER $$
CREATE PROCEDURE usp_withdraw_money(account_id INT, money_amount DECIMAL(19,4))
BEGIN
	UPDATE accounts AS a
    SET a.balance = a.balance - money_amount
    WHERE a.id = account_id AND money_amount > 0 AND a.balance >= money_amount;
END $$

CALL usp_withdraw_money(1, 143.12) $$

SELECT *
FROM accounts AS a
WHERE a.id = 1 $$

-- ************************************14.Money Transfer
DELIMITER $$
CREATE PROCEDURE usp_deposit_money(account_id INT, money_amount DECIMAL(19,4))
BEGIN
	UPDATE accounts AS a
    SET a.balance = a.balance + money_amount
    WHERE a.id = account_id AND money_amount > 0;
END $$

CREATE PROCEDURE usp_withdraw_money(account_id INT, money_amount DECIMAL(19,4))
BEGIN
	UPDATE accounts AS a
    SET a.balance = a.balance - money_amount
    WHERE a.id = account_id AND money_amount > 0 AND a.balance >= money_amount;
END $$

CREATE PROCEDURE usp_transfer_money(from_account_id INT, to_account_id INT, amount DECIMAL(19,4)) 
BEGIN 
	START TRANSACTION; 
		IF((SELECT COUNT(a.id) FROM accounts AS a WHERE a.id like from_account_id) != 1
			OR (SELECT count(a.id) FROM accounts AS a WHERE a.id like to_account_id) != 1
            OR amount < 0
            OR (SELECT a.balance FROM accounts AS a WHERE a.id = from_account_id) < amount)
            OR from_account_id = to_account_id THEN 
				ROLLBACK; 
		ELSE 
			CALL usp_withdraw_money(from_account_id, amount);
			CALL usp_deposit_money(to_account_id, amount);
		END IF;
END $$

CALL usp_transfer_money(2, 100, 200) $$

SELECT *
FROM accounts AS a
WHERE a.id = 1 OR a.id = 2 $$

-- ******************************************15.Log Accounts Trigger
CREATE TABLE logs(
log_id INT PRIMARY KEY AUTO_INCREMENT,
account_id INT,
old_sum DECIMAL(19,4),
new_sum DECIMAL(19,4)
);

DELIMITER $$
CREATE TRIGGER tr_account_change
BEFORE UPDATE
ON accounts
FOR EACH ROW
BEGIN
	INSERT INTO logs(account_id, old_sum, new_sum)
    VALUES(OLD.id, OLD.balance, NEW.balance);
END $$

-- DROP TRIGGER tr_account_change $$
-- 
-- UPDATE accounts AS a
-- SET a.balance = a.balance + 10
-- WHERE a.id = 1 $$

-- *************************************16. Emails Trigger
CREATE TABLE logs(
log_id INT PRIMARY KEY AUTO_INCREMENT,
account_id INT,
old_sum DECIMAL(19,4),
new_sum DECIMAL(19,4)
);

DELIMITER $$
CREATE TRIGGER tr_account_change
BEFORE UPDATE
ON accounts
FOR EACH ROW
BEGIN
	INSERT INTO logs(account_id, old_sum, new_sum)
    VALUES(OLD.id, OLD.balance, NEW.balance);
END $$

CREATE TABLE notification_emails(
id INT PRIMARY KEY AUTO_INCREMENT,
recipient INT,
`subject` VARCHAR(50),
body VARCHAR(200)
) $$

CREATE TRIGGER tr_log_change
BEFORE INSERT
ON `logs`
FOR EACH ROW
BEGIN
	INSERT INTO notification_emails(recipient, `subject`, body)
    VALUE(NEW.account_id,
			CONCAT('Balance change for account: ', NEW.account_id),
            CONCAT('On ', DATE_FORMAT(DATE(NOW()), '%M %d %Y'), ' at ', TIME_FORMAT(TIME(NOW()), '%r'), ' your balance was changed from ', NEW.old_sum, ' to ', NEW.new_sum, '.'));
END $$

-- DROP TRIGGER tr_log_change $$
-- 
-- UPDATE accounts AS a
-- SET a.balance = a.balance + 10
-- WHERE a.id = 1 $$













