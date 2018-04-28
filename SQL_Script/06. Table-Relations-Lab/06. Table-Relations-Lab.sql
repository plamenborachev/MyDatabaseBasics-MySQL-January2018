-- ***************************1.Mountains and Peaks
-- CREATE TABLE `mountains`(
-- `id` INT PRIMARY KEY AUTO_INCREMENT,
-- `name` VARCHAR(100) NOT NULL
-- );
-- CREATE TABLE `peaks`(
-- `id` INT PRIMARY KEY AUTO_INCREMENT,
-- `name` VARCHAR(100) NOT NULL,
-- `mountain_id` INT NOT NULL,
-- CONSTRAINT `fk_mountain_id` FOREIGN KEY (`mountain_id`) REFERENCES `mountains`(`id`)
-- );
-- ******************************2.Posts and Authors
-- CREATE DATABASE `library`;
-- USE `library`;
-- CREATE TABLE `authors`(
-- `id` INT PRIMARY KEY AUTO_INCREMENT,
-- `name` VARCHAR(100) NOT NULL
-- );
-- CREATE TABLE `books`(
-- `id` INT PRIMARY KEY AUTO_INCREMENT,
-- `name` VARCHAR(100) NOT NULL,
-- `author_id` INT NOT NULL,
-- CONSTRAINT `fk_author_id` FOREIGN KEY (`author_id`) REFERENCES `authors`(`id`)
-- ON DELETE CASCADE
-- );
-- *********************************3.	 Trip Organization
-- SELECT `driver_id`, `vehicle_type`, CONCAT(`first_name`, ' ', `last_name`) AS `driver_name`
-- FROM `vehicles` AS `v`
-- JOIN `campers` AS `c` ON v.driver_id = c.id;
-- ************************************4.SoftUni Hiking
-- SELECT 
--     `starting_point` AS `route_starting_point`,
--     `end_point` AS `route_ending_point`,
--     `leader_id`,
--     CONCAT(`first_name`, ' ', `last_name`) AS `leader_name`
-- FROM
--     `routes` AS `r`
--         JOIN
--     `campers` AS `c` ON c.id = r.leader_id;
-- **************************************5.Project Management DB
CREATE DATABASE `project_management_db`;
USE `project_management_db`;

CREATE TABLE `clients`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`client_name` VARCHAR(100),
`project_id` INT NOT NULL
);

CREATE TABLE `projects`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`client_id` INT NOT NULL,
`project_lead_id` INT NOT NULL
);

CREATE TABLE `employees`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`first_name` VARCHAR(30),
`last_name` VARCHAR(30),
`project_id` INT NOT NULL

);

ALTER TABLE `clients`
ADD CONSTRAINT `fk_clients_project_id`
FOREIGN KEY (`project_id`) REFERENCES `projects`(`id`);

ALTER TABLE `projects`
ADD CONSTRAINT `fk_projects_clients_id`
FOREIGN KEY (`client_id`) REFERENCES `clients`(`id`),
ADD CONSTRAINT `fk_project_employee_id`
FOREIGN KEY (`project_lead_id`) REFERENCES `employees`(`id`);

ALTER TABLE `employees`
ADD CONSTRAINT `fk_employees_project_id`
FOREIGN KEY (`project_id`) REFERENCES `projects`(`id`);



