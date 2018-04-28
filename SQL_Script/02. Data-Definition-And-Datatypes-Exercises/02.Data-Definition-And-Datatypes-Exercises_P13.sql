CREATE DATABASE car_rental;
USE car_rental;

CREATE TABLE categories(
id INT PRIMARY KEY AUTO_INCREMENT,
category VARCHAR(30) NOT NULL,
daily_rate DECIMAL,
weekly_rate DECIMAL,
monthly_rate DECIMAL,
weekend_rate DECIMAL
);

CREATE TABLE cars(
id INT PRIMARY KEY AUTO_INCREMENT,
plate_number VARCHAR(30) NOT NULL UNIQUE,
make VARCHAR(30) NOT NULL,
model VARCHAR(30) NOT NULL,
car_year YEAR NOT NULL,
category_id INT NOT NULL,
doors INT NOT NULL,
picture BLOB,
car_condition TEXT,
available VARCHAR(30) NOT NULL
);

CREATE TABLE employees(
id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(30) NOT NULL,
last_name VARCHAR(30) NOT NULL,
title VARCHAR(30) NOT NULL,
notes TEXT
);

CREATE TABLE customers(
id INT PRIMARY KEY AUTO_INCREMENT,
driver_licence_number VARCHAR(50) NOT NULL,
full_name VARCHAR(30) NOT NULL,
address VARCHAR(255) NOT NULL,
city VARCHAR(50) NOT NULL,
zip_code INT NOT NULL,
notes TEXT
);

CREATE TABLE rental_orders(
id INT PRIMARY KEY AUTO_INCREMENT,
employee_id INT NOT NULL,
customer_id INT NOT NULL,
car_id INT NOT NULL,
car_condition TEXT,
tank_level DOUBLE NOT NULL,
kilometrage_start INT NOT NULL,
kilometrage_end INT NOT NULL,
total_kilometrage INT NOT NULL,
start_date DATE NOT NULL,
end_date DATE NOT NULL,
total_days INT NOT NULL,
rate_applied VARCHAR(50) NOT NULL,
tax_rate DECIMAL NOT NULL,
order_status VARCHAR(50),
notes TEXT
);

INSERT INTO categories(category, daily_rate, weekly_rate, monthly_rate, weekend_rate)
VALUES('category', 10.5, 10.5, 10.5, 10.5),
('category', 10.5, 10.5, 10.5, 10.5),
('category', 10.5, 10.5, 10.5, 10.5);

INSERT INTO cars(plate_number, make, model, car_year, category_id, doors, picture, car_condition, available)
VALUES ('CA 1234 CC', 'make', 'model', '2018', 1, 3, 'picture', 'car_condition', 'Yes'),
('CA 1235 CC', 'make', 'model', '2018', 1, 3, 'picture', 'car_condition', 'Yes'),
('CA 1236 CC', 'make', 'model', '2018', 1, 3, 'picture', 'car_condition', 'Yes');

INSERT INTO employees(first_name, last_name, title, notes)
VALUES('first_name', 'last_name', 'title', 'notes'),
('first_name', 'last_name', 'title', 'notes'),
('first_name', 'last_name', 'title', 'notes');

INSERT INTO customers(driver_licence_number, full_name, address, city, zip_code, notes)
VALUES ('111111111111111', 'full_name', 'address', 'city', 1528, 'notes'),
('111111111111111', 'full_name', 'address', 'city', 1528, 'notes'),
('111111111111111', 'full_name', 'address', 'city', 1528, 'notes');

INSERT INTO rental_orders (employee_id, customer_id, car_id, car_condition, tank_level, kilometrage_start, kilometrage_end, total_kilometrage, start_date, end_date, total_days, rate_applied, tax_rate, order_status, notes)
VALUES (2, 1, 3, 'car_condition', 44.4, 100000, 100500, 100, '2018-01-02', '2018-01-18', 3, 'rate_applied', 20.5, 'order_status', 'notes'),
(2, 1, 3, 'car_condition', 44.4, 100000, 100500, 100, '2018-01-02', '2018-01-18', 3, 'rate_applied', 20.5, 'order_status', 'notes'),
(2, 1, 3, 'car_condition', 44.4, 100000, 100500, 100, '2018-01-02', '2018-01-18', 3, 'rate_applied', 20.5, 'order_status', 'notes');