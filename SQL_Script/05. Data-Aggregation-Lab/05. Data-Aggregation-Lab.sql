*******************************1.Departments Info
USE `restaurant`;
SELECT `department_id`, COUNT(`id`) AS `Number of employees`
FROM `employees`
GROUP BY `department_id`
ORDER BY `department_id`, `Number of employees`;
********************************2.Average Salary
SELECT `department_id`, ROUND(AVG(`salary`), 2) AS `Average Salary`
FROM `employees` AS e
GROUP BY `e.department_id`
ORDER BY `e.department_id`;
*********************************3.Min Salary
SELECT `department_id`, ROUND(MIN(`salary`), 2) AS `Min Salary`
FROM `employees` AS e
GROUP BY `department_id`
HAVING `Min Salary` > 800;
**********************************4.Appetizers Count
SELECT COUNT(`id`)
FROM `products`
WHERE `price` > 8 and `category_id` = 2
GROUP BY `category_id`;

SELECT COUNT(`id`)
FROM `products`
WHERE `price` > 8 and `category_id` = 2
GROUP BY `category_id`
HAVING ;
**************************************5.Menu Prices
SELECT `category_id`,
	ROUND(AVG(price), 2) AS `Average Price`,
    ROUND(MIN(price), 2) AS `Cheapest Product`,
    ROUND(MAX(price), 2) AS `Most Expensive Product`
FROM `products`
GROUP BY `category_id`;