-- ********************************01. One-To-One Relationship
CREATE TABLE `passports`(
`passport_id` INT PRIMARY KEY,
`passport_number` VARCHAR(50) UNIQUE NOT NULL 
);

CREATE TABLE `persons`(
`person_id` INT PRIMARY KEY AUTO_INCREMENT,
`first_name` VARCHAR(50),
`salary` DECIMAL(10,2),
`passport_id` INT UNIQUE NOT NULL,
CONSTRAINT `fk_passport_id`
FOREIGN KEY (`passport_id`) REFERENCES `passports`(`passport_id`)
);

INSERT INTO `passports`(`passport_id`, `passport_number`)
VALUES(101, 'N34FG21B'), (102, 'K65LO4R7'), (103, 'ZE657QP2');

INSERT INTO `persons`(`first_name`, `salary`, `passport_id`)
VALUES('Roberto', 43300.00, 102), ('Tom', 56100.00, 103), ('Yana', 60200.00, 101);

-- *************************************2.	One-To-Many Relationship
CREATE TABLE `manufacturers`(
`manufacturer_id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50) NOT NULL,
`established_on` DATE NOT NULL
);

CREATE TABLE `models`(
`model_id` INT PRIMARY KEY,
`name` VARCHAR(50) NOT NULL,
`manufacturer_id` INT NOT NULL,
CONSTRAINT `fk_manufacturer_id`
FOREIGN KEY (`manufacturer_id`) REFERENCES `manufacturers`(`manufacturer_id`)
);

INSERT INTO `manufacturers`(`name`, `established_on`)
VALUES('BMW', '1916-03-01'), ('Tesla', '2003-01-01'), ('Lada', '1966-05-01');

INSERT INTO `models`(`model_id`, `name`, `manufacturer_id`)
VALUES(101, 'X1', 1), (102, 'i6', 1), (103, 'Model S', 2), (104, 'Model X', 2), (105, 'Model 3', 2), (106, 'Nova', 3);

-- ********************************************03. Many-To-Many Relationship
CREATE TABLE `students` (
    `student_id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50) NOT NULL
);

CREATE TABLE `exams` (
    `exam_id` INT PRIMARY KEY,
    `name` VARCHAR(50) NOT NULL
);

CREATE TABLE `students_exams` (
    `student_id` INT NOT NULL,
    `exam_id` INT NOT NULL,
    CONSTRAINT `pk_student_id_exam_id` PRIMARY KEY (`student_id` , `exam_id`),
    CONSTRAINT `fk_student_id` FOREIGN KEY (`student_id`)
        REFERENCES `students` (`student_id`),
    CONSTRAINT `fk_exam_id` FOREIGN KEY (`exam_id`)
        REFERENCES `exams` (`exam_id`)
);

INSERT INTO `students`(`name`)
VALUES('Mila'), ('Toni'), ('Ron');

INSERT INTO `exams`(`exam_id`, `name`)
VALUES(101, 'Spring MVC'), (102, 'Neo4j'), (103, 'Oracle 11g');

INSERT INTO `students_exams`(`student_id`, `exam_id`)
VALUES(1, 101), (1, 102), (2, 101), (3, 103), (2, 102), (2, 103);

-- ******************************4.	Self-Referencing
CREATE TABLE `teachers`(
`teacher_id` INT PRIMARY KEY,
`name` VARCHAR(50),
`manager_id` INT
);

ALTER TABLE `teachers`
ADD CONSTRAINT `fk_manager_id_teacher_id`
FOREIGN KEY (`manager_id`) REFERENCES `teachers`(`teacher_id`);

INSERT INTO `teachers`(`teacher_id`, `name`, `manager_id`)
VALUES(101, 'John', NULL), (106, 'Greta', 101), (105, 'Mark', 101),  (102, 'Maya', 106), (103, 'Silvia', 106), (104, 'Ted', 105);

-- **********************************05. Online Store Database
CREATE DATABASE `online_store`;
USE `online_store`;

CREATE TABLE `cities`(
`city_id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50)
);

CREATE TABLE `customers`(
`customer_id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50),
`birthday` DATE,
`city_id` INT,
CONSTRAINT `fk_city_id`
FOREIGN KEY (`city_id`) REFERENCES `cities`(`city_id`)
);

CREATE TABLE `orders`(
`order_id` INT PRIMARY KEY AUTO_INCREMENT,
`customer_id` INT,
CONSTRAINT `fk_customer_id`
FOREIGN KEY (`customer_id`) REFERENCES `customers`(`customer_id`)
);

CREATE TABLE `item_types`(
`item_type_id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50)
);

CREATE TABLE `items`(
`item_id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50),
`item_type_id` INT,
CONSTRAINT `fk_item_type_id`
FOREIGN KEY (`item_type_id`) REFERENCES `item_types`(`item_type_id`)
);

CREATE TABLE `order_items`(
`order_id` INT,
`item_id` INT,
CONSTRAINT `pk_order_id_item_id` PRIMARY KEY (`order_id`, `item_id`),
CONSTRAINT `fk_order_id` FOREIGN KEY (`order_id`) REFERENCES `orders`(`order_id`),
CONSTRAINT `fk_item_id` FOREIGN KEY (`item_id`) REFERENCES `items`(`item_id`)
);

-- ************************************6.University Database
CREATE DATABASE `university`;
USE `university`;

CREATE TABLE `majors` (
    `major_id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50)
);

CREATE TABLE `students` (
    `student_id` INT PRIMARY KEY AUTO_INCREMENT,
    `student_number` VARCHAR(12),
    `student_name` VARCHAR(50),
    `major_id` INT,
    CONSTRAINT `fk_major_id` FOREIGN KEY (`major_id`)
        REFERENCES `majors` (`major_id`)
);

CREATE TABLE `payments` (
    `payment_id` INT PRIMARY KEY AUTO_INCREMENT,
    `payment_date` DATE,
    `payment_amount` DECIMAL(8 , 2 ),
    `student_id` INT,
    CONSTRAINT `fk_student_id` FOREIGN KEY (`student_id`)
        REFERENCES `students` (`student_id`)
);

CREATE TABLE `subjects` (
    `subject_id` INT PRIMARY KEY AUTO_INCREMENT,
    `subject_name` VARCHAR(50)
);

CREATE TABLE `agenda` (
    `student_id` INT,
    `subject_id` INT,
    CONSTRAINT `pk_student_id_subject_id` PRIMARY KEY (`student_id` , `subject_id`),
    CONSTRAINT `fk_student_id_agenda` FOREIGN KEY (`student_id`)
        REFERENCES `students` (`student_id`),
    CONSTRAINT `fk_subject_id` FOREIGN KEY (`subject_id`)
        REFERENCES `subjects` (`subject_id`)
);

-- *********************************9.	Peaks in Rila
SELECT `mountain_range`, `peak_name`, `elevation`
FROM `mountains` AS `m`
JOIN `peaks` AS `p` ON `p`.`mountain_id` = `m`.`id`
WHERE `m`.`mountain_range` = 'Rila'
ORDER BY `elevation` DESC;
