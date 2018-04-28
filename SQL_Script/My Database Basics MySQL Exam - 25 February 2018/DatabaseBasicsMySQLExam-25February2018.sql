-- **********************************01. Table Design
CREATE DATABASE buhtig;

CREATE TABLE users(
id INT PRIMARY KEY AUTO_INCREMENT,
username VARCHAR(30) NOT NULL UNIQUE,
`password` VARCHAR(30) NOT NULL,
email VARCHAR(50) NOT NULL
);

CREATE TABLE repositories(
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50) NOT NULL
);

CREATE TABLE repositories_contributors(
repository_id INT,
contributor_id INT,
CONSTRAINT fk_repositories_contributors_repositories
FOREIGN KEY (repository_id) REFERENCES repositories(id),
CONSTRAINT fk_repositories_contributors_users
FOREIGN KEY (contributor_id) REFERENCES users(id)
);

CREATE TABLE issues(
id INT PRIMARY KEY AUTO_INCREMENT,
title VARCHAR(255) NOT NULL,
issue_status VARCHAR(6) NOT NULL,
repository_id INT NOT NULL,
assignee_id INT NOT NULL,
CONSTRAINT fk_issues_repositories
FOREIGN KEY (repository_id) REFERENCES repositories(id),
CONSTRAINT fk_issues_users
FOREIGN KEY (assignee_id) REFERENCES users(id)
);

CREATE TABLE commits(
id INT PRIMARY KEY AUTO_INCREMENT,
message VARCHAR(255) NOT NULL,
issue_id INT,
repository_id INT NOT NULL,
contributor_id INT NOT NULL,
CONSTRAINT fk_commits_issues
FOREIGN KEY (issue_id) REFERENCES issues(id),
CONSTRAINT fk_commits_repositories
FOREIGN KEY (repository_id) REFERENCES repositories(id),
CONSTRAINT fk_commits_users
FOREIGN KEY (contributor_id) REFERENCES users(id)
);

CREATE TABLE files(
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(100) NOT NULL,
size DECIMAL(10,2) NOT NULL,
parent_id INT,
commit_id INT NOT NULL,
CONSTRAINT fk_files_files
FOREIGN KEY (parent_id) REFERENCES files(id),
CONSTRAINT fk_files_commits
FOREIGN KEY (commit_id) REFERENCES commits(id)
);

-- *****************************************02. Insert
INSERT INTO issues(title, issue_status, repository_id, assignee_id)
SELECT CONCAT('Critical Problem With ', f.`name`, '!'),
	'open',
    CEILING((f.id * 2) / 3),
    c.contributor_id    
FROM files AS f
JOIN commits AS c ON f.commit_id = c.id
WHERE f.id BETWEEN 46 AND 50;

-- *****************************************03. Update
SET @repository_with_the_lowest_id := (SELECT MIN(r.id)
										FROM repositories AS r
										LEFT JOIN repositories_contributors AS rc1
                                        ON r.id = rc1.repository_id
										WHERE rc1.repository_id IS NULL);

UPDATE repositories_contributors AS rc
SET rc.repository_id = @repository_with_the_lowest_id
WHERE rc.contributor_id = rc.repository_id;
-- *************************************04. Delete
DELETE r FROM repositories AS r
LEFT JOIN issues AS i ON r.id = i.repository_id
WHERE i.id IS NULL;

-- ***************************************05. Users
SELECT u.id, u.username
FROM users AS u
ORDER BY u.id;

-- ***************************************06. Lucky Numbers
SELECT *
FROM repositories_contributors AS rc
WHERE rc.contributor_id = rc.repository_id
ORDER BY rc.repository_id;

-- ****************************************07. Heavy HTML
SELECT f.id, f.`name`, f.size
FROM files AS f
WHERE f.size > 1000 AND f.`name` LIKE '%html%'
ORDER BY f.size DESC;

-- ******************************************08. Issues and Users
SELECT i.id, CONCAT(u.username, ' : ', i.title) AS issue_assignee
FROM issues AS i
JOIN users AS u ON i.assignee_id = u.id
ORDER BY i.id DESC;

-- ****************************************09. Non-Directory Files
SELECT f1.id, f1.`name`, CONCAT(f1.size, 'KB') AS size
FROM files AS f1
LEFT JOIN files AS f2 ON f1.id = f2.parent_id
WHERE f2.parent_id IS NULL
ORDER BY f1.id;

-- ****************************************10. Active Repositories
SELECT r.id, r.`name`, COUNT(i.id) AS issues
FROM repositories AS r
JOIN issues AS i ON r.id = i.repository_id
GROUP BY r.id
ORDER BY issues DESC, r.id
LIMIT 5;

-- ****************************************11. Most Contributed Repository
SELECT r.id, r.`name`, IF((SELECT COUNT(c.id)
									FROM commits AS c
									WHERE c.repository_id = r.id
									GROUP BY c.repository_id) IS NULL,
                                    0,
                                    (SELECT COUNT(c.id)
									FROM commits AS c
									WHERE c.repository_id = r.id
									GROUP BY c.repository_id)) AS commits,
		COUNT(rc.contributor_id) AS contributors
FROM repositories AS r
LEFT JOIN repositories_contributors AS rc ON r.id = rc.repository_id
GROUP BY r.id, r.`name`
ORDER BY contributors DESC, r.id
LIMIT 1;

-- *******************************************12. Fixing My Own Problems
SELECT u.id, u.username, COUNT(c.id) AS commits
FROM users AS u
LEFT JOIN issues AS i ON u.id = i.assignee_id
LEFT JOIN commits AS c ON u.id = c.contributor_id AND i.id = c.issue_id
GROUP BY u.id
ORDER BY commits DESC, u.id;

-- ***************************************13. RecursiveCommits
SELECT SUBSTRING_INDEX(f1.`name`, '.', 1) AS `file`,
	(SELECT COUNT(c.id)
		FROM commits AS c
		WHERE c.message LIKE CONCAT('%', f1.`name`, '%')) AS recursive_count
FROM files AS f1
JOIN files AS f2 ON f1.id = f2.parent_id AND f2.id = f1.parent_id AND f1.id != f1.parent_id
ORDER BY `file`;

-- **************************************14. RepositoriesAndCommits
SELECT r.id, r.`name`, COUNT(DISTINCT c.contributor_id) AS users
FROM repositories AS r
LEFT JOIN commits AS c ON r.id = c.repository_id
GROUP BY r.id
ORDER BY users DESC, r.id;

-- ***************************************15. Commit
DELIMITER $$

CREATE PROCEDURE
	udp_commit(username VARCHAR(30), `password` VARCHAR(30), message VARCHAR(255), issue_id INT)  
BEGIN
	IF(SELECT u.id FROM users AS u WHERE u.username = username) IS NULL
		THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No such user!';
	ELSEIF(SELECT u.`password` FROM users AS u WHERE u.username = username) != `password`
		THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Password is incorrect!';
	ELSEIF(SELECT i.id FROM issues AS i WHERE i.id = issue_id) IS NULL
		THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The issue does not exist!';
	ELSE
		INSERT INTO commits(message, issue_id, repository_id, contributor_id)
        VALUES(message, issue_id,
				(SELECT i.repository_id FROM issues AS i WHERE i.id = issue_id),
                (SELECT u.id FROM users AS u WHERE u.username = username));
		UPDATE issues AS i
        SET i.issue_status = 'closed'
        WHERE i.id = issue_id;
	END IF;
END $$

DELIMITER ;

-- ****************************************16. Filter Extensions
DELIMITER $$

CREATE PROCEDURE udp_findbyextension(extension VARCHAR(100))
BEGIN
	SELECT f.id, f.`name`, CONCAT(f.size, 'KB')
	FROM files AS f
	WHERE SUBSTRING_INDEX(f.`name`, '.', -1) LIKE extension
    ORDER BY f.id;
END $$

DELIMITER ;

CALL udp_findbyextension('html');

















