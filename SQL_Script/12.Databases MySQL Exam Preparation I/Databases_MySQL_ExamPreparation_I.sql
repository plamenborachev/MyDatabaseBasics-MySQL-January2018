-- *********************************01. Table Design
CREATE DATABASE airport_management_system;
USE airport_management_system;

CREATE TABLE towns(
town_id INT PRIMARY KEY AUTO_INCREMENT,
town_name VARCHAR(30) NOT NULL
);

CREATE TABLE airports(
airport_id INT PRIMARY KEY AUTO_INCREMENT,
airport_name VARCHAR(50) NOT NULL,
town_id INT,
CONSTRAINT fk_airport_town_id
FOREIGN KEY (town_id) REFERENCES towns(town_id)
);

CREATE TABLE airlines(
airline_id INT PRIMARY KEY AUTO_INCREMENT,
airline_name VARCHAR(30) NOT NULL,
nationality VARCHAR(30) NOT NULL,
rating INT DEFAULT 0
);

CREATE TABLE customers(
customer_id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(20) NOT NULL,
last_name VARCHAR(20) NOT NULL,
date_of_birth DATE NOT NULL,
gender VARCHAR(1) NOT NULL,
home_town_id INT,
CONSTRAINT fk_customer_home_town_id
FOREIGN KEY (home_town_id) REFERENCES towns(town_id)
);

CREATE TABLE flights(
flight_id INT PRIMARY KEY AUTO_INCREMENT,
departure_time DATETIME NOT NULL,
arrival_time DATETIME NOT NULL,
`status` VARCHAR(9) NOT NULL,
origin_airport_id INT,
destination_airport_id INT,
airline_id INT,
CONSTRAINT fk_flight_origin_airport_id
FOREIGN KEY (origin_airport_id) REFERENCES airports(airport_id),
CONSTRAINT fk_flight_destination_airport_id
FOREIGN KEY (destination_airport_id) REFERENCES airports(airport_id),
CONSTRAINT fk_flight_airline_id
FOREIGN KEY (airline_id) REFERENCES airlines(airline_id)
);

CREATE TABLE tickets(
ticket_id INT PRIMARY KEY AUTO_INCREMENT,
price DECIMAL(8,2) NOT NULL,
class VARCHAR(6) NOT NULL,
seat VARCHAR(5) NOT NULL,
customer_id INT NOT NULL,
flight_id INT NOT NULL,
CONSTRAINT fk_ticket_customer_id
FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
CONSTRAINT fk_ticket_flight_id
FOREIGN KEY (flight_id) REFERENCES flights(flight_id)
);

-- *************************************02.Data Insertion
INSERT INTO flights(departure_time, arrival_time, `status`, origin_airport_id, destination_airport_id, airline_id)
SELECT '2017-06-19 14:00:00', '2017-06-21 11:00:00',
	CASE
		WHEN a.airline_id % 4 = 0 THEN 'Departing'
		WHEN a.airline_id % 4 = 1 THEN 'Delayed'
		WHEN a.airline_id % 4 = 2 THEN 'Arrived'
		WHEN a.airline_id % 4 = 3 THEN 'Canceled'
	END,
    ceiling(sqrt(char_length(a.airline_name))),
    ceiling(sqrt(char_length(a.nationality))),
    a.airline_id
FROM airlines AS a
WHERE a.airline_id BETWEEN 1 AND 10;

-- *******************************************03. Update Arrived Flights
UPDATE flights AS f
SET f.airline_id = 1
WHERE f.status = 'Arrived';

-- *******************************************04. Update Tickets
UPDATE tickets AS t
JOIN flights AS f ON f.flight_id = t.flight_id
JOIN airlines AS a ON a.airline_id = f.airline_id
SET t.price = t.price * 1.5
WHERE a.rating = (SELECT MAX(a2.rating)
					FROM airlines AS a2);

-- ********************************************05. Tickets
SELECT t.ticket_id, t.price, t.class, t.seat
FROM tickets AS t
ORDER BY t.ticket_id;

-- ********************************************06. Customers
SELECT c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS full_name, c.gender
FROM customers AS c
ORDER BY full_name, c.customer_id;

-- **********************************************07. Flights
SELECT f.flight_id, f.departure_time, f.arrival_time
FROM flights AS f
WHERE f.status = 'Delayed'
ORDER BY f.flight_id;

-- **********************************************08. Top 5 Airlines
SELECT DISTINCT a.airline_id, a.airline_name, a.nationality, a.rating
FROM airlines AS a
RIGHT JOIN flights AS f ON f.airline_id = a.airline_id
ORDER BY a.rating DESC, a.airline_id
LIMIT 5;

-- **********************************************09. First Class Tickets
SELECT t.ticket_id, a.airport_name, CONCAT(c.first_name, ' ', c.last_name) AS customer_name 
FROM tickets AS t
JOIN flights AS f ON f.flight_id = t.flight_id
JOIN airports AS a ON a.airport_id = f.destination_airport_id
JOIN customers AS c ON c.customer_id = t.customer_id
WHERE t.price < 5000 AND t.class = 'First'
ORDER BY t.ticket_id;

-- **********************************************10. Home Town Customers
SELECT DISTINCT c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS full_name, tw.town_name
FROM customers AS c
JOIN towns AS tw ON tw.town_id = c.home_town_id
JOIN tickets AS t ON t.customer_id = c.customer_id
JOIN flights AS f ON f.flight_id = t.flight_id
JOIN airports AS a ON a.airport_id = f.origin_airport_id
WHERE f.status = 'Departing' AND c.home_town_id = a.town_id
ORDER BY c.customer_id;

-- *********************************************11. Flying Customers
SELECT DISTINCT
	c.customer_id,
	CONCAT(c.first_name, ' ', c.last_name) AS full_name,
    2016 - YEAR(c.date_of_birth) AS age
FROM customers AS c
JOIN tickets AS t ON t.customer_id = c.customer_id
JOIN flights AS f ON f.flight_id = t.flight_id
WHERE f.status = 'Departing'
ORDER BY age, c.customer_id;

-- *********************************************12. Delayed Customers
SELECT 
	c.customer_id,
	CONCAT(c.first_name, ' ', c.last_name) AS full_name,
    t.price,
    a.airport_name
FROM customers AS c
JOIN tickets AS t ON t.customer_id = c.customer_id
JOIN flights AS f ON f.flight_id = t.flight_id
JOIN airports AS a ON a.airport_id = f.destination_airport_id
WHERE f.status = 'Delayed'
ORDER BY t.price DESC, c.customer_id
LIMIT 3;

-- *********************************************13. Last Departing Flights
SELECT *
FROM (SELECT f.flight_id, f.departure_time, f.arrival_time,
		a1.airport_name AS origin, a2.airport_name AS destination
		FROM flights AS f
		JOIN airports AS a1 ON a1.airport_id = f.origin_airport_id
		JOIN airports AS a2 ON a2.airport_id = f.destination_airport_id
		WHERE f.`status` = 'Departing'
		ORDER BY f.departure_time DESC
		LIMIT 5) AS result_table
ORDER BY departure_time, flight_id;

-- ********************************************14. Flying Children
SELECT DISTINCT
	c.customer_id,
	CONCAT(c.first_name, ' ', c.last_name) AS full_name,
    (2016 - YEAR(c.date_of_birth)) AS `age`
FROM customers AS c
JOIN tickets AS t ON t.customer_id = c.customer_id
JOIN flights AS f ON f.flight_id = t.flight_id
WHERE f.`status` = 'Arrived' AND (2016 - YEAR(c.date_of_birth)) < 21
ORDER BY age DESC, c.customer_id;

-- *********************************************15. Airports and Passengers
SELECT a.airport_id, a.airport_name, COUNT(t.ticket_id) AS passengers
FROM airports AS a
JOIN flights AS f ON f.origin_airport_id = a.airport_id
JOIN tickets AS t ON f.flight_id = t.flight_id
WHERE f.status = 'Departing'
GROUP BY airport_id
ORDER BY a.airport_id;

-- ***************************************16. Submit Review
DELIMITER $$
CREATE PROCEDURE udp_submit_review(customer_id INT, review_content VARCHAR(255),
									review_grade INT, airline_name VARCHAR(30))
BEGIN
    IF(SELECT COUNT(a.airline_id)
		FROM airlines AS a
		WHERE a.airline_name = airline_name) < 1
        THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Airline does not exist.';
	ELSE
		INSERT INTO customer_reviews(customer_id, review_content, review_grade, airline_id)
		VALUE(customer_id, review_content, review_grade,
				(SELECT a.airline_id
				FROM airlines AS a
				WHERE a.airline_name = airline_name));
	END IF;
END $$

-- ******************************************17. Ticket Purchase
DELIMITER $$
CREATE PROCEDURE udp_purchase_ticket(customer_id INT, flight_id INT,
									ticket_price DECIMAL(8,2), class VARCHAR(6),
                                    seat VARCHAR(5))
BEGIN
	IF ticket_price > (SELECT cba.balance
						FROM customer_bank_accounts AS cba
                        WHERE cba.customer_id = customer_id)
		THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient bank account balance for ticket purchase.';
	ELSE
		INSERT INTO tickets(customer_id, flight_id, price, class, seat)
        VALUE(customer_id, flight_id, ticket_price, class, seat);
        UPDATE customer_bank_accounts AS cba
        SET cba.balance = cba.balance - ticket_price
        WHERE cba.customer_id = customer_id;
	END IF;
END $$

-- ***************************************18. Update Trigger
DELIMITER $$ 
CREATE TRIGGER tr_arrived_flights
BEFORE UPDATE
ON flights
FOR EACH ROW
BEGIN
	IF(OLD.status = 'Departing' OR OLD.status = 'Delayed') THEN
    INSERT INTO arrived_flights(flight_id, arrival_time, origin, destination, passengers)
    VALUES(NEW.flight_id, NEW.arrival_time,
			(SELECT a.airport_name FROM airports AS a WHERE a.airport_id = NEW.origin_airport_id),
            (SELECT a.airport_name FROM airports AS a WHERE a.airport_id = NEW.destination_airport_id),
            (SELECT COUNT(t.ticket_id)
				FROM tickets AS t
				JOIN flights AS f ON f.flight_id = t.flight_id
                WHERE t.flight_id = NEW.flight_id));
	END IF;
END $$

DROP TRIGGER tr_arrived_flights;



















