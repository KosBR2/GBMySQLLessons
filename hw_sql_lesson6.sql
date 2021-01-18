-- 1. Создать и заполнить таблицы лайков и постов.

-- 2. Создать все необходимые внешние ключи и диаграмму отношений.
-- предварительная подготовка данных
ALTER TABLE vk.profiles MODIFY COLUMN status_id int unsigned;
ALTER TABLE vk.profiles MODIFY COLUMN country_id int unsigned;
ALTER TABLE vk.users_media MODIFY COLUMN media_id int unsigned;

INSERT INTO vk.users_media (user_id, media_id, is_photo) (
WITH users_null (user_id) AS ( SELECT id FROM vk.users AS t1 LEFT JOIN vk.users_media AS t2 ON t1.id = t2.user_id WHERE t2.media_id IS NULL)
   (SELECT t.user_id, FLOOR(RAND()*200 + 1), FLOOR(RAND()*2 + 1) FROM users_null AS t )
   )

-- profiles ---------------------------------------------------------
ALTER TABLE vk.profiles ADD CONSTRAINT profiles_user_id_fk          FOREIGN KEY (user_id)    REFERENCES vk.users(id)         ON DELETE CASCADE  ON UPDATE CASCADE;
ALTER TABLE vk.profiles ADD CONSTRAINT profiles_photo_id_fk         FOREIGN KEY (photo_id)   REFERENCES vk.media(id)         ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE vk.profiles ADD CONSTRAINT profiles_user_statuses_id_fk FOREIGN KEY (status_id)  REFERENCES vk.user_statuses(id) ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE vk.profiles ADD CONSTRAINT profiles_countries_id_fk     FOREIGN KEY (country_id) REFERENCES vk.countries(id)     ON DELETE SET NULL ON UPDATE CASCADE;
-- users_media ------------------------------------------------------
ALTER TABLE vk.users_media ADD CONSTRAINT users_media_media_id_fk FOREIGN KEY (media_id) REFERENCES vk.media(id) ON UPDATE CASCADE;
ALTER TABLE vk.users_media ADD CONSTRAINT users_media_users_id_fk FOREIGN KEY (user_id)  REFERENCES vk.users(id) ON DELETE CASCADE ON UPDATE CASCADE;
-- messages ---------------------------------------------------------
ALTER TABLE vk.messages ADD CONSTRAINT messages_from_users_id_fk FOREIGN KEY (from_user_id) REFERENCES vk.users(id) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE vk.messages ADD CONSTRAINT messages_to_users_id_fk   FOREIGN KEY (to_user_id)   REFERENCES vk.users(id) ON UPDATE CASCADE;
-- media ------------------------------------------------------------
ALTER TABLE vk.media ADD CONSTRAINT media_media_type_id_fk FOREIGN KEY (media_type_id) REFERENCES vk.media_types(id) ON UPDATE CASCADE;
-- friendship -------------------------------------------------------
ALTER TABLE vk.friendship ADD CONSTRAINT friendship_friendship_statuses_id_fk FOREIGN KEY (status_id) REFERENCES vk.friendship_statuses(id) ON UPDATE CASCADE;
ALTER TABLE vk.friendship ADD CONSTRAINT friendship_users_id_fk               FOREIGN KEY (user_id)   REFERENCES vk.users(id)               ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE vk.friendship ADD CONSTRAINT friendship_users_friend_id_fk        FOREIGN KEY (friend_id) REFERENCES vk.users(id)               ON UPDATE CASCADE;
-- communities_users ------------------------------------------------
ALTER TABLE vk.communities_users ADD CONSTRAINT communities_users_users_id_fk       FOREIGN KEY (user_id)      REFERENCES vk.users(id)       ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE vk.communities_users ADD CONSTRAINT communities_users_communities_id_fk FOREIGN KEY (community_id) REFERENCES vk.communities(id) ON DELETE CASCADE ON UPDATE CASCADE;
-- likes ------------------------------------------------------------
ALTER TABLE vk.likes ADD CONSTRAINT likes_users_id_fk        FOREIGN KEY (user_id)        REFERENCES vk.users(id)        ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE vk.likes ADD CONSTRAINT likes_users_target_id_fk FOREIGN KEY (target_id)      REFERENCES vk.users(id)        ON UPDATE CASCADE;
ALTER TABLE vk.likes ADD CONSTRAINT likes_target_types_id_fk FOREIGN KEY (target_type_id) REFERENCES vk.target_types(id) ON UPDATE CASCADE;
-- posts ------------------------------------------------------------
ALTER TABLE vk.posts ADD CONSTRAINT posts_community_id_fk FOREIGN KEY (community_id) REFERENCES vk.communities(id) ON DELETE CASCADE  ON UPDATE CASCADE;
ALTER TABLE vk.posts ADD CONSTRAINT posts_users_id_fk     FOREIGN KEY (user_id)      REFERENCES vk.users(id)       ON DELETE CASCADE  ON UPDATE CASCADE;
ALTER TABLE vk.posts ADD CONSTRAINT posts_media_id_fk     FOREIGN KEY (media_id)     REFERENCES vk.media(id)       ON DELETE SET NULL ON UPDATE CASCADE;
---------------------------------------------------------------------

-- 3. Определить кто больше поставил лайков (всего) - мужчины или женщины?
SELECT t2.gender, COUNT(*)
  FROM vk.likes AS t1
  JOIN vk.profiles AS t2 ON t1.user_id = t2.user_id
 GROUP BY t2.gender;

SELECT 'female', COUNT(*) FROM vk.likes WHERE user_id IN (SELECT user_id FROM vk.profiles WHERE gender = 'f')
UNION
SELECT 'male', COUNT(*) FROM vk.likes WHERE user_id IN (SELECT user_id FROM vk.profiles WHERE gender = 'm')

-- male   402
-- female 298
-- больше всего мужчины поставили лайков

-- 4. Подсчитать количество лайков которые получили 10 самых молодых пользователей.
SELECT SUM(t.cnt) FROM (
  SELECT t1.user_id AS usr_id, t1.birthday AS bd, COUNT(*) AS cnt
    FROM vk.profiles AS t1
    LEFT OUTER JOIN vk.likes AS t2 ON t2.target_id = t1.user_id
    LEFT OUTER JOIN vk.target_types AS t3 ON t2.target_type_id = t3.id
   WHERE t3.name = 'users'
   GROUP BY t1.user_id, t1.birthday
   ORDER BY t1.birthday DESC LIMIT 10) AS t;
  
SELECT SUM(t1.CNT) FROM (
  SELECT t.user_id
       , t.birthday
       , (SELECT COUNT(*) FROM vk.likes WHERE target_id = t.user_id AND target_type_id = 2
       /*(SELECT id FROM vk.target_types WHERE name = 'users')*/
       ) AS CNT
    FROM vk.profiles AS t
  HAVING CNT > 0
   ORDER BY t.birthday DESC LIMIT 10) AS t1;
  
-- 22
  
-- 5. Найти 10 пользователей, которые проявляют наименьшую активность в
-- использовании социальной сети
-- (критерии активности необходимо определить самостоятельно).

-- критерий активности пользователя: кол-во проставленных лайков + написанных постов
 SELECT *
   FROM (  
WITH likes_cnt (id, cnt) AS (SELECT user_id, COUNT(*) FROM vk.likes GROUP BY user_id)
   , posts_cnt (id, cnt) AS (SELECT user_id, COUNT(*) FROM vk.posts GROUP BY user_id) (
 SELECT t1.user_id AS id, IFNULL(t2.cnt, 0) + IFNULL(t3.cnt, 0) AS activity_cnt
   FROM vk.profiles AS t1
   LEFT JOIN likes_cnt AS t2 ON t1.user_id = t2.id
   LEFT JOIN posts_cnt AS t3 ON t1.user_id = t3.id ) 
  ) AS t 
  ORDER BY t.activity_cnt ASC LIMIT 10

 SELECT t1.user_id AS id
      , IFNULL((SELECT COUNT(*) FROM vk.likes WHERE t1.user_id = user_id GROUP BY user_id), 0)
      + IFNULL((SELECT COUNT(*) FROM vk.posts WHERE t1.user_id = user_id GROUP BY user_id), 0) AS CNT
   FROM vk.profiles AS t1 
  ORDER BY CNT ASC LIMIT 10

  
-- 107	0
-- 165	0
-- 103	0
-- 158	0
-- 140	0
-- 194	0
-- 119	0
-- 117	0
-- 112	0
-- 128	0

 
  