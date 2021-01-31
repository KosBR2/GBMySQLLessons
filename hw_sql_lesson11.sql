-- ///////////////////////////////////////////////////////////////////////////////////////////// --
-- Практическое задание по теме “Оптимизация запросов”
-- Создайте таблицу logs типа Archive. Пусть при каждом создании записи в таблицах users, catalogs и products в таблицу logs помещается время и дата создания записи, название таблицы, идентификатор первичного ключа и содержимое поля name.
--
-- DROP TABLE shop.logs;
CREATE TABLE shop.logs (
  create_at DATETIME DEFAULT NOW(),
  table_name VARCHAR(64),
  primary_key INT,
  value_name VARCHAR(255)
) ENGINE = ARCHIVE;

-- DROP TRIGGER shop.trg_log_catalog_ins;
CREATE TRIGGER shop.trg_log_catalog_ins AFTER INSERT
ON shop.catalogs FOR EACH ROW
BEGIN
   INSERT INTO shop.logs (table_name, primary_key, value_name) VALUES ('catalogs', NEW.id, NEW.name);
END;
-- DROP TRIGGER shop.trg_log_users_ins;
CREATE TRIGGER shop.trg_log_users_ins AFTER INSERT
ON shop.users FOR EACH ROW
BEGIN
   INSERT INTO shop.logs (table_name, primary_key, value_name) VALUES ('users', NEW.id, NEW.name);
END;
-- DROP TRIGGER shop.trg_log_products_ins;
CREATE TRIGGER shop.trg_log_products_ins AFTER INSERT
ON shop.products FOR EACH ROW
BEGIN
   INSERT INTO shop.logs (table_name, primary_key, value_name) VALUES ('products', NEW.id, NEW.name);
END;

-- DELETE FROM shop.users WHERE name = 'Alexandr';
INSERT INTO shop.users (name, birthday_at) VALUES ('Alexandr', CAST('1982-10-01' AS DATE));
INSERT INTO shop.products (name, description, price, catalog_id) VALUES ('Intel Core2Duo 2600Hz', 'Процессор фирмы Intel', 5000, 1);
INSERT INTO shop.catalogs (name) VALUES ('Блок питания');

select * from shop.logs;

-- 2021-01-31 23:13:06	users		12	Alexandr
-- 2021-01-31 23:13:49	products	10	Intel Core2Duo 2600Hz
-- 2021-01-31 23:13:51	catalogs	6	Блок питания

-- (по желанию) Создайте SQL-запрос, который помещает в таблицу users миллион записей.
-- к сожалению на данный момент на доп. задание нет времени