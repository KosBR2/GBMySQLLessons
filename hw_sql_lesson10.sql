-- ���������������� ����� ������� ����� ����������� �������� ����� � �������� ������ ���������� � �������� ����������� �������.
-- 1. ����� ������������ � ���� �� �������.
CREATE INDEX users_last_name_IDX USING BTREE ON vk.users (last_name);

-- 2. ����� ������������� � ������. 
CREATE INDEX profiles_city_IDX USING BTREE ON vk.profiles (city);

-- 3. ����� ������������� �� ���� ��������.
CREATE INDEX profiles_birthday_IDX USING BTREE ON vk.profiles (birthday);

-- 4. ����� ������ �� �������� �����.
CREATE INDEX posts_head_IDX USING BTREE ON vk.posts (head);

-- 5. ����� ����� ����� �� �����.
CREATE INDEX media_filename_IDX USING BTREE ON vk.media (filename);
-- ///////////////////////////////////////////////////////////////////////////////////////////// --
-- ������� �� ������� �������
-- ��������� ������, ������� ����� �������� ��������� �������: 
--   ��� ������ +
--   ������� ���������� ������������� � ������� +
--   ����� ������� ������������ � ������ +
--   ����� ������� ������������ � ������ +
--   ����� ���������� ������������� � ������ +
--   ����� ������������� � ������� 
--   ��������� � ��������� (����� ���������� ������������� � ������ / ����� ������������� � �������) * 100

SELECT t6.groupName
     , AVG(t6.userCountInGroup) OVER () AS avgUsersCountInGroup
     , t6.minAgeUser
     , t6.maxAgeUser
     , t6.userCountInGroup
--     , SUM(t6.userCountInGroup) OVER () AS allUsersCountInGroups
     , t6.allUsers
     , (t6.userCountInGroup/t6.allUsers) * 100 AS percRation
  FROM (
SELECT DISTINCT t5.groupName AS groupName
     , MAX(t5.usersCount) OVER (PARTITION BY t5.groupName) AS userCountInGroup
     , MIN(t5.userAge) OVER (PARTITION BY t5.groupName) AS minAgeUser -- ����� ������� � ������
     , MAX(t5.userAge) OVER (PARTITION BY t5.groupName) AS maxAgeUser -- ����� ������� � ������
     , (SELECT COUNT(*) FROM vk.users) AS allUsers
  FROM (
SELECT t2.name AS groupName, 
       t3.last_name AS lastName,
       t3.first_name AS firstName, 
       t4.birthday AS userBirthday,
       TIMESTAMPDIFF(YEAR, t4.birthday, CURDATE()) AS userAge,
       ROW_NUMBER() OVER (PARTITION BY t2.name) AS usersCount
  FROM vk.communities_users AS t1 
  LEFT JOIN vk.communities AS t2 ON t1.community_id = t2.id 
  JOIN vk.users AS t3 ON t3.id = t1.user_id 
  JOIN vk.profiles AS t4 ON t4.user_id = t3.id ) AS t5 
) AS t6;

-- aspernatur	4.1000	7	49	5	200		2.5000
-- assumenda	4.1000	6	32	4	200		2.0000
-- cupiditate	4.1000	14	48	4	200		2.0000
-- delectus	4.1000	3	46	5	200		2.5000
-- deleniti	4.1000	0	44	4	200		2.0000
-- dicta	4.1000	7	31	4	200		2.0000
-- dolorem	4.1000	8	32	4	200		2.0000
-- dolorum	4.1000	10	45	9	200		4.5000
-- est		4.1000	24	43	4	200		2.0000
-- eum		4.1000	9	46	4	200		2.0000
-- facere	4.1000	23	46	2	200		1.0000
-- laudantium	4.1000	2	2	1	200		0.5000
-- modi		4.1000	17	23	2	200		1.0000
-- molestiae	4.1000	9	34	4	200		2.0000
-- praesentium	4.1000	9	32	3	200		1.5000
-- qui		4.1000	9	43	4	200		2.0000
-- sit		4.1000	2	46	4	200		2.0000
-- sunt		4.1000	14	36	2	200		1.0000
-- tempore	4.1000	6	39	5	200		2.5000
-- ut		4.1000	12	50	8	200		4.0000
-- ///////////////////////////////////////////////////////////////////////////////////////////// --
-- ///////////////////////////////////////////////////////////////////////////////////////////// --