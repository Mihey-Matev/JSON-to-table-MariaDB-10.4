DELIMITER //

CREATE PROCEDURE `json_to_table`(IN `json_input` TEXT)
BEGIN
  DECLARE `json` JSON;
  
  IF json_valid(json_input) THEN
    SET `json` = JSON_EXTRACT(`json_input`, '$');
  ELSE
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid JSON input', MYSQL_ERRNO = 333;
  END IF;

  WITH recursive `cte` (`ind`, `key`, `value`) AS (
      SELECT -1, CAST('' AS VARCHAR(255)), CAST('' AS VARCHAR(255))  
      UNION

      SELECT 
      	`i` AS `ind`, 
      	JSON_UNQUOTE(`key_i`) AS `key`, 
      	JSON_UNQUOTE(JSON_EXTRACT(`json`, CONCAT('$.', `key_i`))) AS `value`
      FROM
      (
          SELECT 
          	JSON_EXTRACT(JSON_KEYS(`json`), CONCAT('$[', (`ind` + 1),']')) AS `key_i`,
          	`ind` + 1 AS `i`
          FROM `cte`
          WHERE `ind` < JSON_LENGTH(`json`) - 1
      )      AS outerTable
  )  
  SELECT `key`, `value` FROM `cte` WHERE `ind` != -1;
  
END//

DELIMITER ;

-- MariaDB 10.6.0 introduced JSON_TABLE() which has a very similar effect to this
