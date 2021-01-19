-- 1.��������� ������ ������������� users, ������� ����������� ���� �� ���� ����� orders � �������� ��������.
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

-- 2. �������� ������ ������� products � �������� catalogs, ������� ������������� ������.
SELECT t1.id, t1.name, t1.description, t2.name, t1.price 
  FROM shop.products AS t1
  JOIN shop.catalogs AS t2 ON t1.catalog_id = t2.id 

-- 3.(�� �������) ����� ������� ������� ������ flights (id, from, to) � ������� ������� cities (label, name). ���� from, to � label �������� ���������� �������� �������, ���� name � �������.
-- �������� ������ ������ flights � �������� ���������� �������.

CREATE TABLE shop.flight (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 go_from VARCHAR(64),
 go_to VARCHAR(64)
);

INSERT INTO shop.flight (go_from, go_to) VALUES ('moscow', 'omsk'), ('novgorod', 'kazan'), ('irkutsk', 'moscow'), ('omsk', 'irkutsk'), ('moscow', 'kazan');

CREATE TABLE shop.cities (name_eng VARCHAR(64), name_ru VARCHAR(64));

INSERT INTO shop.cities (name_eng, name_ru) VALUES ('moscow', '������'), ('irkutsk', '�������'), ('novgorod', '��������'), ('kazan', '������'), ('omsk', '����');

SELECT * FROM shop.flight;
SELECT * FROM shop.cities;

SELECT t.id, t1.name_ru, t2.name_ru
  FROM shop.flight AS t
  LEFT JOIN shop.cities AS t1 ON t.go_from = t1.name_eng
  LEFT JOIN shop.cities AS t2 ON t.go_to = t2.name_eng;
  
-- 1	������		����
-- 2	��������	������
-- 3	�������		������
-- 4	����		�������
-- 5	������		������