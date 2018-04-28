CREATE DATABASE hotel;
USE hotel;
CREATE TABLE employees(
id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(50) NOT NULL,
last_name VARCHAR(50) NOT NULL,
title VARCHAR(50) NOT NULL,
notes TEXT
);
INSERT INTO employees(first_name, last_name, title)
VALUES ('first_name', 'last_name', 'title'),
('first_name', 'last_name', 'title'),
('first_name', 'last_name', 'title');
CREATE TABLE customers(
account_number VARCHAR(50) PRIMARY KEY NOT NULL,
first_name VARCHAR(50) NOT NULL,
last_name VARCHAR(50) NOT NULL,
phone_number VARCHAR(50),
emergency_name VARCHAR(50),
emergency_number VARCHAR(50),
notes TEXT
);
INSERT INTO customers(account_number, first_name, last_name)
VALUES ('account_number1', 'first_name', 'last_name'),
('account_number2', 'first_name', 'last_name'),
('account_number3', 'first_name', 'last_name');
CREATE TABLE room_status(
room_status VARCHAR(50) PRIMARY KEY NOT NULL,
notes TEXT
);
INSERT INTO room_status (room_status)
VALUES ('room_status1'), ('room_status2'), ('room_status3');
CREATE TABLE room_types(
room_type VARCHAR(50) PRIMARY KEY NOT NULL,
notes TEXT
);
INSERT INTO room_types (room_type)
VALUES ('room_type1'), ('room_type2'), ('room_type3');
CREATE TABLE bed_types(
bed_type VARCHAR(50) PRIMARY KEY NOT NULL,
notes TEXT
);
INSERT INTO bed_types (bed_type)
VALUES ('bed_type1'), ('bed_type2'), ('bed_type3');
CREATE TABLE rooms(
room_number INT PRIMARY KEY NOT NULL,
room_type VARCHAR(50) NOT NULL,
bed_type VARCHAR(50) NOT NULL,
rate DECIMAL(10,2) NOT NULL,
room_status VARCHAR(50) NOT NULL,
notes TEXT
);
INSERT INTO rooms (room_number, room_type, bed_type, rate, room_status)
VALUES (1, 'room_type', 'bed_type', 100.5, 'room_status'),
(2, 'room_type', 'bed_type', 100.5, 'room_status'),
(3, 'room_type', 'bed_type', 100.5, 'room_status');
CREATE TABLE payments(
id INT PRIMARY KEY AUTO_INCREMENT,
employee_id INT NOT NULL,
payment_date DATE NOT NULL,
account_number VARCHAR(50),
first_date_occupied DATE NOT NULL,
last_date_occupied DATE NOT NULL,
total_days INT NOT NULL,
amount_charged DECIMAL(10,2) NOT NULL,
tax_rate DECIMAL(10,2) NOT NULL,
tax_amount DECIMAL(10,2) NOT NULL,
payment_total DECIMAL(10,2) NOT NULL,
notes TEXT
);
INSERT INTO payments (employee_id, payment_date, first_date_occupied, last_date_occupied, total_days, amount_charged, tax_rate, tax_amount, payment_total)
VALUES (1, '2018-01-17', '2017-01-17', '2018-01-17', 30, 100.5, 50.5, 60.5, 200.5),
(2, '2018-01-17', '2017-01-17', '2018-01-17', 30, 100.5, 50.5, 60.5, 200.5),
(3, '2018-01-17', '2017-01-17', '2018-01-17', 30, 100.5, 50.5, 60.5, 200.5);
CREATE TABLE occupancies(
id INT PRIMARY KEY AUTO_INCREMENT,
employee_id INT NOT NULL,
date_occupied DATE NOT NULL,
account_number VARCHAR(50),
room_number INT NOT NULL,
rate_applied DECIMAL(10,2) NOT NULL,
phone_charge DECIMAL(10,2),
notes TEXT
);
INSERT INTO occupancies (employee_id, date_occupied, room_number, rate_applied)
VALUES (1, '2018-01-17', 1, 100.5), (1, '2018-01-17', 1, 100.5), (1, '2018-01-17', 1, 100.5);
-- *****************************22. Decrease Tax Rate
UPDATE payments SET tax_rate = tax_rate * 0.97;
SELECT tax_rate FROM payments;
-- ********************************23. Delete All Records
TRUNCATE TABLE occupancies;

