-- Буравцев К. Ю.
-- Практическое задание по теме «Операторы, фильтрация, сортировка и ограничение»
-- 1. Пусть в таблице users поля created_at и updated_at оказались незаполненными. Заполните их текущими датой и временем.

UPDATE vk.users 
   SET created_at = CURRENT_TIMESTAMP
     , updated_at = CURRENT_TIMESTAMP; 

SELECT * FROM vk.users;

-- 2. Таблица users была неудачно спроектирована. Записи created_at и updated_at были заданы типом VARCHAR и в них долгое время помещались значения в формате 20.10.2017 8:10. Необходимо преобразовать поля к типу DATETIME, сохранив введённые ранее значения.
ALTER TABLE vk.users ADD COLUMN created_at_vch VARCHAR(32);
ALTER TABLE vk.users ADD COLUMN updated_at_vch VARCHAR(32);

UPDATE vk.users SET created_at_vch = '25.10.2017 8:15', updated_at_vch = '26.11.2019 6:17';

ALTER TABLE vk.users ADD COLUMN created_at_dt DATETIME;
ALTER TABLE vk.users ADD COLUMN updated_at_dt DATETIME;

UPDATE vk.users SET created_at_dt = STR_TO_DATE(created_at_vch, '%d.%m.%Y %H:%i'), updated_at_dt = STR_TO_DATE(updated_at_vch, '%d.%m.%Y %H:%i');

SELECT * FROM vk.users;

-- 3. В таблице складских запасов storehouses_products в поле value могут встречаться самые разные цифры: 0, если товар закончился и выше нуля, если на складе имеются запасы.
--    Необходимо отсортировать записи таким образом, чтобы они выводились в порядке увеличения значения value. Однако нулевые запасы должны выводиться в конце, после всех записей.

INSERT INTO shop.storehouses (name) VALUES ('Москва-Товарная'), ('Мытищи'), ('Домодедово'), ('Пушкино'), ('Люблино');

INSERT INTO shop.storehouses_products (storehouse_id, product_id, value) VALUES 
(1, 1, 100), (1, 2,  70), (1, 3, 120), (1, 4, 50), (1, 5, 30), (1, 6, 30), (1, 7,  0), 
(2, 1,  50), (2, 2,  90), (2, 3,   0), (2, 4, 40), (2, 5,  5), (2, 6, 45), (2, 7, 90),
(3, 1,   0), (3, 2, 110), (3, 3,  85), (3, 4, 20), (3, 5, 10), (3, 6,  0), (3, 7, 50),
(4, 1, 120), (4, 2,   0), (4, 3,  70), (4, 4,  5), (4, 5,  0), (4, 6, 70), (4, 7, 30),
(5, 1,  80), (5, 2,   0), (5, 3,  10), (5, 4,  0), (5, 5, 20), (5, 6,  0), (5, 7,  5);

SELECT id, value FROM shop.storehouses_products ORDER BY FIELD (value, 0), value

-- 4. (по желанию) Из таблицы users необходимо извлечь пользователей, родившихся в августе и мае. Месяцы заданы в виде списка английских названий (may, august)
SELECT * FROM shop.users WHERE MONTHNAME(birthday_at) IN ('may', 'august');

-- 5. (по желанию) Из таблицы catalogs извлекаются записи при помощи запроса. SELECT * FROM catalogs WHERE id IN (5, 1, 2); Отсортируйте записи в порядке, заданном в списке IN.

SELECT * FROM shop.catalogs WHERE id IN (5, 1, 2) ORDER BY FIELD (id, 5, 1, 2);

-- Практическое задание теме «Агрегация данных»
-- 1. Подсчитайте средний возраст пользователей в таблице users.
SELECT AVG(TIMESTAMPDIFF(YEAR, birthday_at, CURDATE())) FROM shop.users;

-- 2. Подсчитайте количество дней рождения, которые приходятся на каждый из дней недели. Следует учесть, что необходимы дни недели текущего года, а не года рождения.
SELECT DAYOFWEEK(DATE_ADD(birthday_at, INTERVAL TIMESTAMPDIFF(YEAR, birthday_at, CURDATE()) YEAR)) AS dayOfW, COUNT(*) FROM shop.users GROUP BY dayOfW;

-- 3. (по желанию) Подсчитайте произведение чисел в столбце таблицы.
SELECT EXP(SUM(LOG(id))) FROM shop.users;


