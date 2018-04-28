-- ***************************15. Create SoftUni Database
-- CREATE DATABASE soft_uni;
-- USE soft_uni;

CREATE TABLE towns (
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(50) NOT NULL
);
CREATE TABLE addresses (
id INT PRIMARY KEY AUTO_INCREMENT,
address_text VARCHAR(50) NOT NULL,
town_id INT NOT NULL,
CONSTRAINT fk_address_town_id
FOREIGN KEY (town_id) REFERENCES towns (id)
);
CREATE TABLE departments (
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(50) NOT NULL
);
CREATE TABLE employees (
id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(50) NOT NULL,
middle_name VARCHAR(50) NOT NULL,
last_name VARCHAR(50) NOT NULL,
job_title VARCHAR(50) NOT NULL,
department_id INT NOT NULL,
hire_date DATE NOT NULL,
salary DECIMAL(10,2) NOT NULL,
address_id INT,
CONSTRAINT fk_department_id
FOREIGN KEY (department_id) REFERENCES departments(id),
CONSTRAINT fk_address_id
FOREIGN KEY (address_id) REFERENCES addresses(id)
);
-- ***************************16. Backup Database
-- $ mysqldump --opt -u [uname] -p[pass] [dbname] > [backupfile.sql];
-- $ mysqldump --opt -u root -p1234 soft_uni > softuni-backup.sql;
-- $ mysql -u [uname] -p[pass] [db_to_restore] < [backupfile.sql];
-- ************************17. Basic Insert
INSERT INTO towns(name) VALUES ("Sofia"), ("Plovdiv"), ("Varna"), ("Burgas");
INSERT INTO departments (name)
VALUES ("Engineering"), ("Sales"), ("Marketing"), ("Software Development"), ("Quality Assurance");
INSERT INTO employees (first_name, middle_name, last_name, job_title, department_id, hire_date, salary)
VALUES ("Ivan", "Ivanov", "Ivanov", ".NET Developer", 4, "2013-02-01", 3500.00),
("Petar", "Petrov", "Petrov", "Senior Engineer", 1, "2004-03-02", 4000.00),
("Maria", "Petrova", "Ivanova", "Intern", 5, "2016-08-28", 525.25),
("Georgi", "Terziev", "Ivanov", "CEO", 2, "2007-12-09", 3000.00),
("Peter", "Pan", "Pan", "Intern", 3, "2016-08-28", 599.88);
-- ****************************18. Basic Select All Fields
SELECT * FROM towns;
SELECT * FROM departments;
SELECT * FROM employees;
-- *******************************19. Basic Select All Fields and Order Them
SELECT * FROM towns ORDER BY name ASC;
SELECT * FROM departments ORDER BY name ASC;
SELECT * FROM employees ORDER BY salary DESC;
-- *********************************20. Basic Select Some Fields
SELECT name FROM towns ORDER BY name;
SELECT name FROM departments ORDER BY name;
SELECT first_name, last_name, job_title, salary FROM employees ORDER BY salary DESC;
-- ************************************21. Increase Employees Salary
UPDATE employees SET salary = salary * 1.10;
SELECT salary FROM employees;