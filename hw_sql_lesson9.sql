-- Практическое задание по теме “Транзакции, переменные, представления”
-- ///////////////////////////////////////////////////////////////////////////////////////
-- 1. В базе данных shop и sample присутствуют одни и те же таблицы, учебной базы данных. Переместите запись id = 1 из таблицы shop.users в таблицу sample.users. Используйте транзакции.
SELECT * FROM shop.users;
SELECT * FROM sample.users;

START TRANSACTION;

INSERT INTO sample.users (name) (SELECT name FROM shop.users WHERE id = 1);

COMMIT;
-- ///////////////////////////////////////////////////////////////////////////////////////
-- 2.Создайте представление, которое выводит название name товарной позиции из таблицы products и соответствующее название каталога name из таблицы catalogs. 
SELECT * FROM shop.products;
SELECT * FROM shop.catalogs;

CREATE OR REPLACE VIEW shop.vw_prodName AS 
	SELECT t1.name AS prodName
	     , t2.name AS catName 
      FROM shop.products AS t1 
      JOIN shop.catalogs AS t2 ON t1.catalog_id = t2.id;

SELECT * FROM shop.vw_prodName;
-- ///////////////////////////////////////////////////////////////////////////////////////
-- 3.по желанию) Пусть имеется таблица с календарным полем created_at. В ней размещены разряженые календарные записи за август 2018 года '2018-08-01', '2016-08-04', '2018-08-16' и 2018-08-17. 
--   Составьте запрос, который выводит полный список дат за август, выставляя в соседнем поле значение 1, если дата присутствует в исходном таблице и 0, если она отсутствует.
-- DROP TABLE IF EXISTS shop.important_dates;
CREATE TABLE shop.important_dates (create_at DATE);
INSERT INTO shop.important_dates (create_at) VALUES ('2018-08-01'), ('2016-08-04'), ('2018-08-16'), ('2018-08-17');

-- DROP TABLE IF EXISTS shop.august_days;
-- v1.
TRUNCATE shop.august_days;
CREATE TEMPORARY TABLE shop.august_days (aug_day INT);
SET @strt_date = STR_TO_DATE('01.08.2018', '%d.%m.%Y'); 
INSERT INTO shop.august_days (aug_day) VALUES (0), (1), (2), (3), (4), (5), (6), (7), (8), (9), (10), (11), (12), (13), (14), (15), (16), (17), (18), (19), (20), (21), (22), (23), (24), (25), (26), (27), (28), (29), (30);

SELECT t1.dayNum, t1.augDay, IF(t2.create_at IS NULL, 0, 1)
  FROM ( SELECT aug_day AS dayNum
              , ADDDATE(@strt_date, INTERVAL aug_day DAY) AS augDay 
           FROM shop.august_days) AS t1
  LEFT JOIN shop.important_dates AS t2 ON t1.augDay = t2.create_at

-- Способ v2.
-- DROP TABLE IF EXISTS shop.august_days;
CREATE TEMPORARY TABLE shop.august_days (aug_day DATE);

TRUNCATE shop.august_days;

-- DROP PROCEDURE shop.genDaysAugust;
CREATE OR REPLACE PROCEDURE shop.genDaysAugust()
BEGIN
  DECLARE strt_date DATE DEFAULT NOW();
  DECLARE stop_date DATE DEFAULT NOW();
 
  SET strt_date = STR_TO_DATE('01.08.2018', '%d.%m.%Y');
  SET stop_date = STR_TO_DATE('01.09.2018', '%d.%m.%Y');
	
  WHILE strt_date < stop_date DO
    INSERT INTO shop.august_days (aug_day) VALUES (strt_date);
    SET strt_date = ADDDATE(strt_date, INTERVAL 1 DAY);
  END WHILE;
END;

CALL shop.genDaysAugust();
SELECT * FROM shop.august_days;

SELECT t1.aug_day, IF(t2.create_at IS NULL, 0, 1) 
  FROM shop.august_days AS t1 
  LEFT JOIN shop.important_dates AS t2 ON t1.aug_day = t2.create_at;
-- ///////////////////////////////////////////////////////////////////////////////////////
-- 4.(по желанию) Пусть имеется любая таблица с календарным полем created_at. Создайте запрос, который удаляет устаревшие записи из таблицы, оставляя только 5 самых свежих записей.

-- DELETE FROM shop.august_days
CREATE TABLE shop.august_days_static (aug_day DATE);

CREATE OR REPLACE PROCEDURE shop.genDaysAugustStatic()
BEGIN
  DECLARE strt_date DATE DEFAULT NOW();
  DECLARE stop_date DATE DEFAULT NOW();
 
  SET strt_date = STR_TO_DATE('01.08.2018', '%d.%m.%Y');
  SET stop_date = STR_TO_DATE('01.09.2018', '%d.%m.%Y');
	
  WHILE strt_date < stop_date DO
    INSERT INTO shop.august_days_static (aug_day) VALUES (strt_date);
    SET strt_date = ADDDATE(strt_date, INTERVAL 1 DAY);
  END WHILE;
END;

CALL shop.genDaysAugustStatic();
SELECT * FROM shop.august_days_static;

DELETE t1
  FROM shop.august_days_static AS t1
  JOIN (SELECT ROW_NUMBER() OVER () AS rowNum, aug_day AS augDay FROM shop.august_days_static) AS t2 ON t2.augDay = t1.aug_day
 CROSS JOIN (SELECT COUNT(*) AS daysCnt FROM shop.august_days_static) AS t3
 WHERE t3.daysCnt - t2.rowNum >= 5;


-- Практическое задание по теме “Хранимые процедуры и функции, триггеры"
-- ///////////////////////////////////////////////////////////////////////////////////////
-- 1.Создайте хранимую функцию hello(), которая будет возвращать приветствие, в зависимости от текущего времени суток. 
-- С 6:00 до 12:00 функция должна возвращать фразу "Доброе утро", 
-- с 12:00 до 18:00 функция должна возвращать фразу "Добрый день", 
-- с 18:00 до 00:00 — "Добрый вечер", 
-- с 00:00 до 6:00 — "Доброй ночи". © geekbrains.ru

-- DROP FUNCTION shop.spHello;

CREATE FUNCTION shop.spHello() RETURNS VARCHAR(64)
DETERMINISTIC READS SQL DATA
BEGIN
  DECLARE curDT DATETIME;
  DECLARE retVal VARCHAR(64);

  SET curDT = CURTIME();
  SET retVal = '';
  
  IF curDT >= CAST('00:00:00' AS TIME) AND curDT < CAST('06:00:00' AS TIME) THEN SET retVal = "Доброй ночи";
  ELSEIF curDT >= CAST('06:00:00' AS TIME) AND curDT < CAST('12:00:00' AS TIME) THEN SET retVal = "Доброе утро";
  ELSEIF curDT >= CAST('12:00:00' AS TIME) AND curDT < CAST('18:00:00' AS TIME) THEN SET retVal = "Добрый день";
  ELSEIF curDT >= CAST('18:00:00' AS TIME) AND curDT < CAST('24:00:00' AS TIME) THEN SET retVal = "Добрый вечер";
  ELSE SET retVal = 'Не могу произвести сравнение дат!';
  END IF;
  
  RETURN retVal;
END

-- SELECT shop.spHello();

-- ///////////////////////////////////////////////////////////////////////////////////////
-- 2.В таблице products есть два текстовых поля: name с названием товара и description с его описанием. 
-- Допустимо присутствие обоих полей или одно из них. Ситуация, когда оба поля принимают неопределенное значение NULL неприемлема. 
-- Используя триггеры, добейтесь того, чтобы одно из этих полей или оба поля были заполнены. При попытке присвоить полям NULL-значение необходимо отменить операцию.

CREATE TRIGGER `_before_ins_tr1` BEFORE INSERT ON `products`
  FOR EACH ROW
BEGIN
   DECLARE raise_error CONDITION FOR SQLSTATE '22012';
   IF (NEW.name IS NULL AND NEW.description IS NULL) OR (NEW.name = '' AND NEW.description = '') THEN
     SIGNAL raise_error;
   END IF;
END;

INSERT INTO shop.products (name, description, price, catalog_id) VALUE (NULL, NULL, 32000, 1);
INSERT INTO shop.products (name, description, price, catalog_id) VALUE ('1dfdsfd', '', 32000, 1);


CREATE TRIGGER `_before_upd_tr1` BEFORE UPDATE ON `products`
  FOR EACH ROW
BEGIN
   DECLARE raise_error CONDITION FOR SQLSTATE '22012';
   DECLARE descrValue TEXT;
   DECLARE nameValue VARCHAR(256);

   SET descrValue = (SELECT description FROM shop.products WHERE id = NEW.id);
   SET nameValue = (SELECT name FROM shop.products WHERE id = NEW.id);
   
   IF NEW.name IS NULL AND NEW.description IS NULL THEN
     SIGNAL raise_error;
   END IF;
   
   IF (NEW.name IS NULL AND nameValue IS NULL) OR (NEW.name = '' AND nameValue = '') THEN
     SIGNAL raise_error;
   END IF;
   
   IF (NEW.description IS NULL AND descrValue IS NULL) OR (NEW.description = '' AND descrValue = '') THEN
     SIGNAL raise_error;
   END IF;
END;

UPDATE shop.products SET name = 'any text in name', description = 'any text in description' WHERE id = 9;
UPDATE shop.products SET name = NULL, description = 'any text in description' WHERE id = 9;
UPDATE shop.products SET name = NULL, description = '' WHERE id = 9;
UPDATE shop.products SET name = 'any text in name', description = 'any text in description' WHERE id = 9;
UPDATE shop.products SET name = 'any text in name', description = NULL WHERE id = 9;
UPDATE shop.products SET name = NULL WHERE id = 9;
UPDATE shop.products SET name = '', description = NULL WHERE id = 9;

-- ///////////////////////////////////////////////////////////////////////////////////////
-- 3.(по желанию) Напишите хранимую функцию для вычисления произвольного числа Фибоначчи. 
-- Числами Фибоначчи называется последовательность в которой число равно сумме двух предыдущих чисел. 
-- Вызов функции FIBONACCI(10) должен возвращать число 55.

-- DROP FUNCTION shop.getFIBO;

CREATE FUNCTION shop.getFIBO(intNum INT) RETURNS INT
DETERMINISTIC READS SQL DATA
BEGIN
  DECLARE curVal INT;
  DECLARE prev1 INT;
  DECLARE prev2 INT;
  DECLARE step INT;
  
  SET step = 0;
  SET curVal = 1;
  SET prev1 = 0;
  SET prev2 = 0;

  WHILE step < intNum-1 DO
    SET prev2 = prev1;
    SET prev1 = curVal;
    SET curVal = prev1 + prev2;
    
    SET step = step + 1;
  END WHILE;
 
  RETURN curVal;
END

-- 
-- SELECT shop.getFIBO(0);
-- SELECT shop.getFIBO(1);
-- SELECT shop.getFIBO(2);
-- SELECT shop.getFIBO(3);
-- SELECT shop.getFIBO(4);
-- SELECT shop.getFIBO(5);
-- SELECT shop.getFIBO(6);
-- SELECT shop.getFIBO(7);
-- SELECT shop.getFIBO(8);
-- SELECT shop.getFIBO(9);
-- SELECT shop.getFIBO(10);