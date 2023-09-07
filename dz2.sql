DROP DATABASE IF EXISTS lesson_2;
CREATE DATABASE lesson_2;
USE lesson_2;

-- фильмы
DROP TABLE IF EXISTS movies;
CREATE TABLE movies (
	id SERIAL PRIMARY KEY, -- SERIAL = BIGINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE
	title VARCHAR(50) NOT NULL,
	title_eng VARCHAR(50),
	year_movie  YEAR NOT NULL,
	count_min  INT,
	storyline TEXT
);

-- наполнение данными 
INSERT INTO `movies` (title, title_eng, year_movie, count_min, storyline)
VALUES 
('Игры разума', 'A Beautiful Mind', 2001, 135, 'От всемирной известности до греховных глубин — все это познал на своей шкуре Джон Форбс Нэш-младший. Математический гений, он на заре своей карьеры сделал титаническую работу в области теории игр, которая перевернула этот раздел математики и практически принесла ему международную известность. Однако буквально в то же время заносчивый и пользующийся успехом у женщин Нэш получает удар судьбы, который переворачивает уже его собственную жизнь.'),
('Форрест Гамп', 'Forrest Gump', 1994, 142, 'Сидя на автобусной остановке, Форрест Гамп — не очень умный, но добрый и открытый парень — рассказывает случайным встречным историю своей необыкновенной жизни. С самого малолетства парень страдал от заболевания ног, соседские мальчишки дразнили его, но в один прекрасный день Форрест открыл в себе невероятные способности к бегу. Подруга детства Дженни всегда его поддерживала и защищала, но вскоре дороги их разошлись.'),
('Иван Васильевич меняет профессию', NULL, 1998, 128,'Инженер-изобретатель Тимофеев сконструировал машину времени, которая соединила его квартиру с далеким шестнадцатым веком - точнее, с палатами государя Ивана Грозного. Туда-то и попадают тезка царя пенсионер-общественник Иван Васильевич Бунша и квартирный вор Жорж Милославский. На их место в двадцатом веке «переселяется» великий государь. Поломка машины приводит ко множеству неожиданных и забавных событий...'),
('Назад в будущее', 'Back to the Future', 1985, 116, 'Подросток Марти с помощью машины времени, сооружённой его другом-профессором доком Брауном, попадает из 80-х в далекие 50-е. Там он встречается со своими будущими родителями, ещё подростками, и другом-профессором, совсем молодым.'),
('Криминальное чтиво', 'Pulp Fiction', 1994, 154, NULL);


-- жанры
DROP TABLE IF EXISTS genres;
CREATE TABLE genres (
	id SERIAL PRIMARY KEY, -- SERIAL = BIGINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE
	name VARCHAR(100) NOT NULL
);

-- актеры
DROP TABLE IF EXISTS actors;
CREATE TABLE actors (
	id SERIAL PRIMARY KEY, -- SERIAL = BIGINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE
	firstname VARCHAR(100) NOT NULL ,
	lastname VARCHAR(100) COMMENT 'Фамилия' -- COMMENT на случай, если имя неочевидное
);

-- переименование таблицы movies в cinema   
RENAME TABLE movies TO cinema;

-- добавление новых столбцов status_active и genre_id в таблицу cinema
ALTER TABLE cinema
ADD COLUMN status_active BIT DEFAULT b'1',
ADD genre_id BIGINT UNSIGNED AFTER title_eng;

-- удаление столбца status_active из таблицы cinema
ALTER TABLE cinema
DROP COLUMN status_active;

-- удаление таблицы actors
DROP TABLE actors;

-- добавление внешнего ключа от поля genre_id таблицы cinema к полю id таблицы genres
ALTER TABLE cinema
ADD FOREIGN KEY(genre_id) REFERENCES genres(id);
 
-- очистить таблицу от данных 
-- TRUNCATE TABLE genres;

ALTER TABLE cinema
DROP FOREIGN KEY cinema_ibfk_1;

TRUNCATE TABLE genres;

ALTER TABLE cinema
ADD FOREIGN KEY(genre_id) REFERENCES genres(id) 
ON UPDATE CASCADE ON DELETE SET NULL;


-- добавим поле возрастная категория фильмов
ALTER TABLE cinema
ADD COLUMN age_category CHAR(1);

-- присвоение фильмам категорий 
UPDATE cinema SET age_category='П' WHERE id=1;
UPDATE cinema SET age_category='Д' WHERE id=4;
UPDATE cinema SET age_category='В' WHERE id=5;

/*
 В зависимости от поля age_category, выведите столбец с именем “Категория”
 Д- Десткая, П – Подростковая, В – Взрослая, Не указана
 */
SELECT 
	id AS 'Номер фильма',
	title AS 'Название фильма',
	CASE age_category 
		WHEN 'Д' THEN 'Детская'
		WHEN 'П' THEN 'Подростковая'
		WHEN 'В' THEN 'Взрослая'
		ELSE 'Не указана'
	END AS 'Категория'	
FROM cinema;

-- изменение продолжительности фильмов 
UPDATE cinema SET count_min = 88 WHERE id=2;
UPDATE cinema SET count_min = NULL WHERE id=3;
UPDATE cinema SET count_min = 34 WHERE id=4;

/* Расставить фильмы в зависимости от продолжительности.
До 50 минут -  Короткометражный фильм
От 50 минут до 100 минут  -  Среднеметражный фильм
Более 100 минут  -  Полнометражный фильм
Иначе  - Не определено
 */
SELECT 
	id AS 'Номер фильма',
	title AS 'Название фильма',
	count_min AS 'Продолжительность',
	CASE 
		WHEN count_min < 50 THEN 'Короткометражный фильм'
		WHEN count_min BETWEEN 50 AND 100 THEN 'Среднеметражный фильм'
		WHEN count_min > 100 THEN 'Полнометражный фильм'
		ELSE 'Не определено'
	END AS 'Тип'	
FROM cinema;

-- функция IF()
-- IF( condition, [value_if_true], [value_if_false] )

-- Если 100<200, то печатаем 'Да'; иначе - 'Нет'

SELECT IF(100<200, 'Да', 'Нет') AS Result;

SELECT 
	id AS 'Номер фильма',
	title AS 'Название фильма',
	count_min AS 'Продолжительность',
	IF (count_min < 50, 'Короткометражный фильм', 
		IF (count_min BETWEEN 50 AND 100, 'Среднеметражный фильм', 
			IF (count_min > 100, 'Полнометражный фильм', 'Не определено')  
			)
		) AS 'Тип'	
FROM cinema;

#1. Используя операторы языка SQL, создайте таблицу “sales”. Заполните ее данными. Справа располагается рисунок к первому заданию.

USE lesson_2;
CREATE TABLE sales (
	id SERIAL NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
	order_date text NOT NULL,
	count_product INT
);

INSERT INTO `sales` (order_date, count_product)
VALUES 
('2022-01-01', 156),
('2022-01-02', 180),
('2022-01-03', 21),
('2022-01-04', 124),
('2022-01-05', 341);

SELECT * FROM sales;

/*
 2.  Для данных таблицы “sales” укажите тип заказа в зависимости от кол-ва : 
меньше 100  -    Маленький заказ
от 100 до 300 - Средний заказ
больше 300  -     Большой заказ
 */
SELECT 
	id AS 'id заказа',
	CASE 
		WHEN count_product<100 THEN 'Маленький заказ'
		WHEN count_product>300 THEN 'Большой заказ'
		ELSE 'Средний заказ'
	END AS 'Тип заказа'	
FROM sales;

/*
 Создайте таблицу “orders”, заполните ее значениями
 */

DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
	id SERIAL NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
	employee_id VARCHAR(5) NOT NULL,
	amount FLOAT(2),
    order_status VARCHAR(15)
);

INSERT INTO `orders` (employee_id, amount, order_status)
VALUES 
('e03', '15.00', 'OPEN'),
('e01', '25.50', 'OPEN'),
('e05', '100.70', 'CLOSED'),
('e02', '22.18', 'OPEN'),
('e04', '9.50', 'CANCELLED');

/*
 Выберите все заказы. В зависимости от поля order_status выведите столбец full_order_status:
OPEN – «Order is in open state» ; CLOSED - «Order is closed»; CANCELLED -  «Order is cancelled»
 */
 
 SELECT * FROM orders;
 
 SELECT order_status,
	CASE 
		WHEN order_status='OPEN' THEN 'Order is in open state'
		WHEN order_status='CLOSED' THEN 'Order is closed'
        WHEN order_status='CANCELLED' THEN 'Order is cancelled'
		ELSE 'No status'
	END AS full_order_status
FROM orders;
 