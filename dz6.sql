-- ДОМАШНЯЯ РАБОТА
-- 1. Создайте таблицу users_old, аналогичную таблице users. Создайте процедуру,  с помощью которой можно переместить любого (одного) пользователя из таблицы users в таблицу users_old. (использование транзакции с выбором commit или rollback – обязательно).

USE lesson_4;

DROP TABLE IF EXISTS users_old;
CREATE TABLE users_old (
	id INT PRIMARY KEY auto_increment, 
    firstname varchar(50), 
    lastname varchar(50), 
    email varchar(120)
);

DELIMITER $$
DROP PROCEDURE IF EXISTS move_user;
CREATE PROCEDURE  move_user (IN num1 INT) 
	DETERMINISTIC
BEGIN
INSERT INTO users_old (firstname,lastname,email) 
SELECT firstname, lastname, email 
	FROM users 
	WHERE users.id = num1;
DELETE FROM users 
	WHERE id = num1;
COMMIT;
END$$

DELIMITER ;

CALL move(2);


-- 2. Создайте хранимую функцию hello(), которая будет возвращать приветствие, в зависимости от текущего времени суток. С 6:00 до 12:00 функция должна возвращать фразу "Доброе утро", с 12:00 до 18:00 функция должна возвращать фразу "Добрый день", с 18:00 до 00:00 — "Добрый вечер", с 00:00 до 6:00 — "Доброй ночи".

DELIMITER $$
CREATE FUNCTION hello() 
	RETURNS VARCHAR(20)
	DETERMINISTIC
BEGIN
DECLARE hi VARCHAR(20);
SELECT CASE
	WHEN CURRENT_TIME BETWEEN '06:00:00' AND '12:00:00' THEN 'Доброе утро'
	WHEN CURRENT_TIME BETWEEN '12:00:00' AND '18:00:00' THEN 'Добрый день'
	WHEN CURRENT_TIME BETWEEN '18:00:00' AND '00:00:00' THEN 'Добрый вечер'
	ELSE 'Доброй ночи'
END INTO hi;
RETURN hi;
END$$

DELIMITER ;


SELECT hello();

-- 3. Создайте таблицу logs типа Archive. Пусть при каждом создании записи в таблицах users, communities и messages в таблицу logs помещается время и дата создания записи, название таблицы, идентификатор первичного ключа.
DROP TABLE IF EXISTS logs;

CREATE TABLE logs (
    data_and_time DATETIME DEFAULT now(),
    name_of_table VARCHAR(20) NOT NULL,
    id_of_primery_key INT UNSIGNED NOT NULL
)  ENGINE=ARCHIVE;

CREATE 
    TRIGGER  users_log
 AFTER INSERT ON users FOR EACH ROW 
    INSERT INTO logs SET name_of_table = 'users' , id_of_primery_key = NEW.id;

CREATE 
    TRIGGER  communities_log
 AFTER INSERT ON communities FOR EACH ROW 
    INSERT INTO logs SET name_of_table = 'communities' , id_of_primery_key = NEW.id;

CREATE 
    TRIGGER  messages_log
AFTER INSERT ON messages FOR EACH ROW 
    INSERT INTO logs SET name_of_table = 'messages' , id_of_primery_key = NEW.id;
