-- ************************************01. Table Design
CREATE DATABASE the_nerd_herd;
USE the_nerd_herd;

CREATE TABLE locations(
id INT PRIMARY KEY AUTO_INCREMENT,
latitude FLOAT,
longitude FLOAT
);

CREATE TABLE credentials(
id INT PRIMARY KEY AUTO_INCREMENT,
email VARCHAR(30),
password VARCHAR(20)
);

CREATE TABLE users(
id INT PRIMARY KEY AUTO_INCREMENT,
nickname VARCHAR(25),
gender CHAR(1),
age INT,
location_id INT,
credential_id INT UNIQUE,
CONSTRAINT fk_user_location_id FOREIGN KEY (location_id) REFERENCES locations(id),
CONSTRAINT fk_user_credential_id FOREIGN KEY (credential_id) REFERENCES credentials(id)
);

CREATE TABLE chats(
id INT PRIMARY KEY AUTO_INCREMENT,
title VARCHAR(32),
start_date DATE,
is_active BIT
);

CREATE TABLE messages(
id INT PRIMARY KEY AUTO_INCREMENT,
content VARCHAR(200),
sent_on DATE,
chat_id INT,
user_id INT,
CONSTRAINT fk_message_chat_id FOREIGN KEY (chat_id) REFERENCES chats(id),
CONSTRAINT fk_message_user_id FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE users_chats(
user_id INT,
chat_id INT,
CONSTRAINT pk_user_id_chat_id PRIMARY KEY (user_id, chat_id),
CONSTRAINT fk_user_id FOREIGN KEY (user_id) REFERENCES users(id),
CONSTRAINT fk_chat_id FOREIGN KEY (chat_id) REFERENCES chats(id)
);

-- ****************************************02. Insert
INSERT INTO messages(content, sent_on, chat_id, user_id)
SELECT CONCAT_WS('-', u.age, u.gender, l.latitude, l.longitude),
	'2016-12-15',
	CASE
		WHEN u.gender = 'F' THEN CEIL(SQRT(u.age * 2))
		WHEN u.gender = 'M' THEN CEIL(POW(u.age / 18, 3))
	END,
	u.id
FROM users AS u
JOIN locations AS l ON l.id = u.location_id
WHERE u.id BETWEEN 10 AND 20;

-- *****************************************03. Update
-- My solution:
UPDATE chats AS c
JOIN messages AS m ON m.chat_id = c.id
SET c.start_date = (SELECT MIN(m2.sent_on)
					FROM messages AS m2
					GROUP BY m2.chat_id
                    HAVING m2.chat_id = c.id)
WHERE c.start_date > m.sent_on;

-- Lictor's solution 
UPDATE chats AS c
JOIN messages AS m ON m.chat_id = c.id
SET c.start_date = m.sent_on
WHERE c.start_date > m.sent_on;

-- *********************************************04. Delete
DELETE l
FROM locations AS l
LEFT JOIN users AS u ON l.id = u.location_id
WHERE u.id IS NULL;

-- *******************************************05. Age Range
SELECT u.nickname, u.gender, u.age
FROM users AS u
WHERE u.age BETWEEN 22 AND 37
ORDER BY u.id;

-- *******************************************06. Messages
SELECT m.content, m.sent_on
FROM messages AS m
WHERE m.sent_on > '2014-05-12' AND m.content LIKE '%just%'
ORDER BY m.id DESC;

-- *******************************************07. Chats
SELECT c.title, c.is_active
FROM chats AS c
WHERE (c.is_active = 0 AND CHAR_LENGTH(c.title) < 5)
	OR substring(c.title, 3, 2) = 'tl'
ORDER BY c.title DESC;

-- *******************************************08. Chat Messages
SELECT c.id, c.title, m.id
FROM chats AS c
JOIN messages AS m ON c.id = m.chat_id
WHERE m.sent_on < '2012-03-26' AND RIGHT(c.title, 1) = 'x'
ORDER BY c.id, m.id;

-- *******************************************09. Message Count
SELECT c.id, COUNT(*) AS `total_messages`
FROM chats AS c
JOIN messages AS m ON c.id = m.chat_id
WHERE m.id < 90
GROUP BY c.id
ORDER BY `total_messages` DESC, c.id
LIMIT 5;

-- ******************************************10. Credentials
SELECT u.nickname, c.email, c.password
FROM users AS u
JOIN credentials AS c ON u.credential_id = c.id
WHERE c.email LIKE '%co.uk'
ORDER BY c.email;

-- ****************************************11. Locations 
SELECT u.id, u.nickname, u.age
FROM users AS u
WHERE u.location_id IS NULL
ORDER BY u.id;

-- ***************************************12. Left Users
SELECT m.id, m.chat_id, m.user_id
FROM messages AS m
LEFT JOIN users_chats AS uc
	ON m.user_id = uc.user_id AND m.chat_id = uc.chat_id
WHERE uc.user_id IS NULL AND m.chat_id = 17
ORDER BY m.id DESC;

-- **************************************13. Users in Bulgaria 
SELECT u.nickname, c.title, l.latitude, l.longitude
FROM users AS u
JOIN locations AS l ON u.location_id = l.id
JOIN users_chats AS uc ON u.id = uc.user_id
JOIN chats AS c ON c.id = uc.chat_id
WHERE l.latitude >= 41.139999 AND l.latitude <= 44.129999
	AND l.longitude BETWEEN 22.209999 AND 28.359999
ORDER BY c.title;

-- ***************************************14. Last Chat
SELECT c.title, m.content
FROM chats AS c
LEFT JOIN messages AS m ON m.chat_id = c.id
WHERE c.start_date = (SELECT MAX(c2.start_date)
						FROM chats AS c2)
ORDER BY m.sent_on, m.id;

-- ****************************************15. Radians
DELIMITER $$
CREATE FUNCTION udf_get_radians(degrees FLOAT)
RETURNS FLOAT
BEGIN
	DECLARE radians FLOAT;
    SET radians := degrees * PI() / 180;
    RETURN radians;
END $$

SELECT udf_get_radians(22.12);

-- *************************************16. Change Password
DELIMITER $$
CREATE PROCEDURE udp_change_password(email VARCHAR(30), `password` VARCHAR(20))
BEGIN
	IF(SELECT c.email
		FROM credentials AS c
		WHERE c.email = email) IS NOT NULL
	THEN
		UPDATE credentials AS c
        SET c.password = `password`
        WHERE c.email = email;
	ELSE SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The email does\'t exist!';
    END IF;
END $$

CALL udp_change_password('cburns1@geocities.com', 'new_pass ') $$
CALL udp_change_password('abarnes0', 'new_pass ') $$

-- **************************************17. Send Message
DELIMITER $$
CREATE PROCEDURE udp_send_message(user_id INT,
									chat_id INT,
                                    message_content VARCHAR(200))
BEGIN
	IF((SELECT uc.user_id
		FROM users_chats AS uc
		WHERE uc.user_id = user_id AND uc.chat_id = chat_id) IS NULL)
        THEN SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'There is no chat with that user!';
	ELSE
		INSERT INTO messages(content, sent_on, chat_id, user_id)
        VALUES(message_content, '2016-12-15', chat_id, user_id);
	END IF;
END $$

CALL udp_send_message(19, 17, 'Awesome') $$
CALL udp_send_message(18, 17, 'Awesome') $$

-- ***********************************18. Log Messages
CREATE TABLE messages_log(
id INT PRIMARY KEY AUTO_INCREMENT,
content VARCHAR(200),
sent_on DATE,
chat_id INT,
user_id INT,
CONSTRAINT fk_message_log_chat_id FOREIGN KEY (chat_id) REFERENCES chats(id),
CONSTRAINT fk_message_log_user_id FOREIGN KEY (user_id) REFERENCES users(id)
);

DELIMITER $$
CREATE TRIGGER tr_deleted_message
AFTER DELETE
ON `messages`
FOR EACH ROW
BEGIN
	INSERT INTO `messages_log`
    VALUES(OLD.id, OLD.content, OLD.sent_on, OLD.chat_id, OLD.user_id);
END $$

DROP TRIGGER tr_deleted_message; $$

DELETE FROM messages
WHERE id = 1; $$

-- ******************************19. Delete Users
DROP TRIGGER IF EXISTS tr_before_delete_user; $$

DELIMITER $$
CREATE TRIGGER tr_before_delete_user
BEFORE DELETE
ON users
FOR EACH ROW
BEGIN
	DELETE FROM messages WHERE user_id = OLD.id;
	DELETE FROM messages_log WHERE user_id = OLD.id;
    DELETE FROM users_chats WHERE user_id = OLD.id;
END $$

DELETE FROM users
WHERE id = 4; $$
















