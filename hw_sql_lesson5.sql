-- �������� �. �.
-- ������������ ������� �� ���� ����������, ����������, ���������� � �����������
-- 1. ����� � ������� users ���� created_at � updated_at ��������� ��������������. ��������� �� �������� ����� � ��������.

UPDATE vk.users 
   SET created_at = CURRENT_TIMESTAMP
     , updated_at = CURRENT_TIMESTAMP; 

SELECT * FROM vk.users;

-- 2. ������� users ���� �������� ��������������. ������ created_at � updated_at ���� ������ ����� VARCHAR � � ��� ������ ����� ���������� �������� � ������� 20.10.2017 8:10. ���������� ������������� ���� � ���� DATETIME, �������� �������� ����� ��������.
ALTER TABLE vk.users ADD COLUMN created_at_vch VARCHAR(32);
ALTER TABLE vk.users ADD COLUMN updated_at_vch VARCHAR(32);

UPDATE vk.users SET created_at_vch = '25.10.2017 8:15', updated_at_vch = '26.11.2019 6:17';

ALTER TABLE vk.users ADD COLUMN created_at_dt DATETIME;
ALTER TABLE vk.users ADD COLUMN updated_at_dt DATETIME;

UPDATE vk.users SET created_at_dt = STR_TO_DATE(created_at_vch, '%d.%m.%Y %H:%i'), updated_at_dt = STR_TO_DATE(updated_at_vch, '%d.%m.%Y %H:%i');

SELECT * FROM vk.users;

-- 3. � ������� ��������� ������� storehouses_products � ���� value ����� ����������� ����� ������ �����: 0, ���� ����� ���������� � ���� ����, ���� �� ������ ������� ������.
--    ���������� ������������� ������ ����� �������, ����� ��� ���������� � ������� ���������� �������� value. ������ ������� ������ ������ ���������� � �����, ����� ���� �������.

INSERT INTO shop.storehouses (name) VALUES ('������-��������'), ('������'), ('����������'), ('�������'), ('�������');

INSERT INTO shop.storehouses_products (storehouse_id, product_id, value) VALUES 
(1, 1, 100), (1, 2,  70), (1, 3, 120), (1, 4, 50), (1, 5, 30), (1, 6, 30), (1, 7,  0), 
(2, 1,  50), (2, 2,  90), (2, 3,   0), (2, 4, 40), (2, 5,  5), (2, 6, 45), (2, 7, 90),
(3, 1,   0), (3, 2, 110), (3, 3,  85), (3, 4, 20), (3, 5, 10), (3, 6,  0), (3, 7, 50),
(4, 1, 120), (4, 2,   0), (4, 3,  70), (4, 4,  5), (4, 5,  0), (4, 6, 70), (4, 7, 30),
(5, 1,  80), (5, 2,   0), (5, 3,  10), (5, 4,  0), (5, 5, 20), (5, 6,  0), (5, 7,  5);

SELECT id, value FROM shop.storehouses_products ORDER BY FIELD (value, 0), value

-- 4. (�� �������) �� ������� users ���������� ������� �������������, ���������� � ������� � ���. ������ ������ � ���� ������ ���������� �������� (may, august)
SELECT * FROM shop.users WHERE MONTHNAME(birthday_at) IN ('may', 'august');

-- 5. (�� �������) �� ������� catalogs ����������� ������ ��� ������ �������. SELECT * FROM catalogs WHERE id IN (5, 1, 2); ������������ ������ � �������, �������� � ������ IN.

SELECT * FROM shop.catalogs WHERE id IN (5, 1, 2) ORDER BY FIELD (id, 5, 1, 2);

-- ������������ ������� ���� ���������� �������
-- 1. ����������� ������� ������� ������������� � ������� users.
SELECT AVG(TIMESTAMPDIFF(YEAR, birthday_at, CURDATE())) FROM shop.users;

-- 2. ����������� ���������� ���� ��������, ������� ���������� �� ������ �� ���� ������. ������� ������, ��� ���������� ��� ������ �������� ����, � �� ���� ��������.
SELECT DAYOFWEEK(DATE_ADD(birthday_at, INTERVAL TIMESTAMPDIFF(YEAR, birthday_at, CURDATE()) YEAR)) AS dayOfW, COUNT(*) FROM shop.users GROUP BY dayOfW;

-- 3. (�� �������) ����������� ������������ ����� � ������� �������.
SELECT EXP(SUM(LOG(id))) FROM shop.users;


