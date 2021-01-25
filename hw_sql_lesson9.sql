-- ������������ ������� �� ���� �����������, ����������, ��������������
-- ///////////////////////////////////////////////////////////////////////////////////////
-- 1. � ���� ������ shop � sample ������������ ���� � �� �� �������, ������� ���� ������. ����������� ������ id = 1 �� ������� shop.users � ������� sample.users. ����������� ����������.
SELECT * FROM shop.users;
SELECT * FROM sample.users;

START TRANSACTION;

INSERT INTO sample.users (name) (SELECT name FROM shop.users WHERE id = 1);

COMMIT;
-- ///////////////////////////////////////////////////////////////////////////////////////
-- 2.�������� �������������, ������� ������� �������� name �������� ������� �� ������� products � ��������������� �������� �������� name �� ������� catalogs. 
SELECT * FROM shop.products;
SELECT * FROM shop.catalogs;

CREATE OR REPLACE VIEW shop.vw_prodName AS 
	SELECT t1.name AS prodName
	     , t2.name AS catName 
      FROM shop.products AS t1 
      JOIN shop.catalogs AS t2 ON t1.catalog_id = t2.id;

SELECT * FROM shop.vw_prodName;
-- ///////////////////////////////////////////////////////////////////////////////////////
-- 3.�� �������) ����� ������� ������� � ����������� ����� created_at. � ��� ��������� ���������� ����������� ������ �� ������ 2018 ���� '2018-08-01', '2016-08-04', '2018-08-16' � 2018-08-17. 
--   ��������� ������, ������� ������� ������ ������ ��� �� ������, ��������� � �������� ���� �������� 1, ���� ���� ������������ � �������� ������� � 0, ���� ��� �����������.
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

-- ������ v2.
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
-- 4.(�� �������) ����� ������� ����� ������� � ����������� ����� created_at. �������� ������, ������� ������� ���������� ������ �� �������, �������� ������ 5 ����� ������ �������.

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


-- ������������ ������� �� ���� ��������� ��������� � �������, ��������"
-- ///////////////////////////////////////////////////////////////////////////////////////
-- 1.�������� �������� ������� hello(), ������� ����� ���������� �����������, � ����������� �� �������� ������� �����. 
-- � 6:00 �� 12:00 ������� ������ ���������� ����� "������ ����", 
-- � 12:00 �� 18:00 ������� ������ ���������� ����� "������ ����", 
-- � 18:00 �� 00:00 � "������ �����", 
-- � 00:00 �� 6:00 � "������ ����". � geekbrains.ru

-- DROP FUNCTION shop.spHello;

CREATE FUNCTION shop.spHello() RETURNS VARCHAR(64)
DETERMINISTIC READS SQL DATA
BEGIN
  DECLARE curDT DATETIME;
  DECLARE retVal VARCHAR(64);

  SET curDT = CURTIME();
  SET retVal = '';
  
  IF curDT >= CAST('00:00:00' AS TIME) AND curDT < CAST('06:00:00' AS TIME) THEN SET retVal = "������ ����";
  ELSEIF curDT >= CAST('06:00:00' AS TIME) AND curDT < CAST('12:00:00' AS TIME) THEN SET retVal = "������ ����";
  ELSEIF curDT >= CAST('12:00:00' AS TIME) AND curDT < CAST('18:00:00' AS TIME) THEN SET retVal = "������ ����";
  ELSEIF curDT >= CAST('18:00:00' AS TIME) AND curDT < CAST('24:00:00' AS TIME) THEN SET retVal = "������ �����";
  ELSE SET retVal = '�� ���� ���������� ��������� ���!';
  END IF;
  
  RETURN retVal;
END

-- SELECT shop.spHello();

-- ///////////////////////////////////////////////////////////////////////////////////////
-- 2.� ������� products ���� ��� ��������� ����: name � ��������� ������ � description � ��� ���������. 
-- ��������� ����������� ����� ����� ��� ���� �� ���. ��������, ����� ��� ���� ��������� �������������� �������� NULL �����������. 
-- ��������� ��������, ��������� ����, ����� ���� �� ���� ����� ��� ��� ���� ���� ���������. ��� ������� ��������� ����� NULL-�������� ���������� �������� ��������.

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
-- 3.(�� �������) �������� �������� ������� ��� ���������� ������������� ����� ���������. 
-- ������� ��������� ���������� ������������������ � ������� ����� ����� ����� ���� ���������� �����. 
-- ����� ������� FIBONACCI(10) ������ ���������� ����� 55.

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