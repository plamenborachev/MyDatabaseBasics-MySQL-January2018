-- ************************Part II – Queries for Geography Database
-- ****************************10.	Countries Holding ‘A’ 3 or More Times
SELECT country_name, iso_code
FROM countries
WHERE country_name LIKE '%a%a%a%'
ORDER BY iso_code;
-- ****************************11. Mix of Peak and River Names
SELECT peak_name, river_name, LOWER(CONCAT(peak_name, SUBSTRING(river_name, 2))) AS mix
FROM peaks, rivers
WHERE SUBSTRING(peak_name, -1, 1) = SUBSTRING(river_name, 1, 1)
ORDER BY mix;
