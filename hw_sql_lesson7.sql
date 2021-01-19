-- 1.Составьте список пользователей users, которые осуществили хотя бы один заказ orders в интернет магазине.
INSERT INTO shop.orders (user_id) (
  SELECT RAND()*5+1
    FROM shop.users
);

INSERT INTO shop.orders_products (order_id, product_id, total) (
  SELECT (RAND()*19+1), (RAND()*6+1), (RAND()*3+1)
    FROM shop.orders AS t
);

SELECT t1.id, t1.name, COUNT(*) AS orders_cnt
  FROM shop.users AS t1
  JOIN shop.orders AS t2 ON t1.id = t2.user_id 
 GROUP BY t1.id, t1.name
HAVING orders_cnt > 0

-- 2. Выведите список товаров products и разделов catalogs, который соответствует товару.
SELECT t1.id, t1.name, t1.description, t2.name, t1.price 
  FROM shop.products AS t1
  JOIN shop.catalogs AS t2 ON t1.catalog_id = t2.id 

-- 3.(по желанию) Пусть имеется таблица рейсов flights (id, from, to) и таблица городов cities (label, name). Поля from, to и label содержат английские названия городов, поле name — русское.
-- Выведите список рейсов flights с русскими названиями городов.

CREATE TABLE shop.flight (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 go_from VARCHAR(64),
 go_to VARCHAR(64)
);

INSERT INTO shop.flight (go_from, go_to) VALUES ('moscow', 'omsk'), ('novgorod', 'kazan'), ('irkutsk', 'moscow'), ('omsk', 'irkutsk'), ('moscow', 'kazan');

CREATE TABLE shop.cities (name_eng VARCHAR(64), name_ru VARCHAR(64));

INSERT INTO shop.cities (name_eng, name_ru) VALUES ('moscow', 'Москва'), ('irkutsk', 'Иркутск'), ('novgorod', 'Новгород'), ('kazan', 'Казань'), ('omsk', 'Омск');

SELECT * FROM shop.flight;
SELECT * FROM shop.cities;

SELECT t.id, t1.name_ru, t2.name_ru
  FROM shop.flight AS t
  LEFT JOIN shop.cities AS t1 ON t.go_from = t1.name_eng
  LEFT JOIN shop.cities AS t2 ON t.go_to = t2.name_eng;
  
-- 1	Москва		Омск
-- 2	Новгород	Казань
-- 3	Иркутск		Москва
-- 4	Омск		Иркутск
-- 5	Москва		Казань