-- ********************************12.	Highest Peaks in Bulgaria
SELECT mc.country_code, m.mountain_range, p.peak_name, p.elevation
FROM mountains_countries AS mc
JOIN mountains AS m ON mc.mountain_id = m.id
JOIN peaks AS p ON m.id = p.mountain_id
WHERE mc.country_code = 'BG' AND p.elevation > 2835
ORDER BY p.elevation DESC;

-- ***********************************13.	Count Mountain Ranges
SELECT c.country_code, COUNT(m.mountain_range) AS `mountain_range`
FROM countries AS c
JOIN mountains_countries AS mc ON c.country_code = mc.country_code
JOIN mountains AS m ON mc.mountain_id = m.id
WHERE c.country_name IN ('United States', 'Russia', 'Bulgaria')
GROUP BY c.country_code
ORDER BY `mountain_range` DESC;

-- *************************************14.Countries with Rivers
SELECT c.country_name, r.river_name
FROM countries AS c
JOIN continents AS cont ON cont.continent_code = c.continent_code
LEFT JOIN countries_rivers AS cr ON c.country_code = cr.country_code
LEFT JOIN rivers AS r ON cr.river_id = r.id
WHERE cont.continent_name = 'Africa'
ORDER BY c.country_name
LIMIT 5;

-- *************************************15. *Continents and Currencies
SELECT c1.continent_code, c1.currency_code, COUNT(c1.currency_code) AS `currency_usage`
FROM countries AS c1
GROUP BY c1.continent_code, c1.currency_code
HAVING `currency_usage` = (
SELECT COUNT(c2.currency_code) AS `count`
FROM countries AS c2
WHERE c2.continent_code = c1.continent_code
GROUP BY c2.currency_code
ORDER BY `count` DESC
LIMIT 1
) AND `currency_usage` > 1
ORDER BY c1.continent_code, c1.currency_code;

-- ***************************************16.Countries without any Mountains
SELECT COUNT(*) AS `country_count`
FROM mountains_countries AS mc
RIGHT JOIN countries AS c ON mc.country_code = c.country_code
WHERE mc.country_code IS NULL;

-- ******************************************17.Highest Peak and Longest River by Country
SELECT c.country_name,
	MAX(p.elevation) AS `highest_peak_elevation`,
    MAX(r.length) AS `longest_river_length`
FROM countries AS c
LEFT JOIN mountains_countries AS mc ON c.country_code = mc.country_code
LEFT JOIN peaks AS p ON mc.mountain_id = p.mountain_id
LEFT JOIN countries_rivers AS cr ON c.country_code = cr.country_code
LEFT JOIN rivers AS r ON cr.river_id = r.id
GROUP BY c.country_name
ORDER BY `highest_peak_elevation` DESC, longest_river_length DESC, c.country_name
LIMIT 5;



