DROP DATABASE IF EXISTS lesson_3;
CREATE DATABASE lesson_3;
USE lesson_3;

-- Персонал
DROP TABLE IF EXISTS staff;
CREATE TABLE staff (
	id INT AUTO_INCREMENT PRIMARY KEY, 
	firstname VARCHAR(45),
	lastname VARCHAR(45),
	post VARCHAR(100),
	seniority INT, 
	salary INT, 
	age INT
);

-- Наполнение данными
INSERT INTO staff (firstname, lastname, post, seniority, salary, age)
VALUES
('Вася', 'Петров', 'Начальник', '40', 100000, 60),
('Петр', 'Власов', 'Начальник', '8', 70000, 30),
('Катя', 'Катина', 'Инженер', '2', 70000, 25),
('Саша', 'Сасин', 'Инженер', '12', 50000, 35),
('Иван', 'Иванов', 'Рабочий', '40', 30000, 59),
('Петр', 'Петров', 'Рабочий', '20', 25000, 40),
('Сидр', 'Сидоров', 'Рабочий', '10', 20000, 35),
('Антон', 'Антонов', 'Рабочий', '8', 19000, 28),
('Юрий', 'Юрков', 'Рабочий', '5', 15000, 25),
('Максим', 'Максимов', 'Рабочий', '2', 11000, 22),
('Юрий', 'Галкин', 'Рабочий', '3', 12000, 24),
('Людмила', 'Маркина', 'Уборщик', '10', 10000, 49);

-- Проверка 
SELECT id, firstname, lastname, post, seniority, salary, age  FROM staff;

-- ORDER BY - сотритовка


-- Выведите все записи, отсортированные по полю "age" по возрастанию
-- SELECT * FROM workers ORDER BY age ASC;
SELECT * FROM staff ORDER BY age;

-- Выведите все записи, отсортированные по полю "firstname"
SELECT * FROM staff ORDER BY firstname;

-- Выведите записи полей "firstname", "lastname","age", отсортированные по полю "firstname" в алфавитном порядке по убыванию
SELECT firstname, lastname, age FROM staff ORDER BY firstname DESC ;

-- Выполните сортировку по полям "firstname" и "age" по убыванию
-- SELECT firstname, age FROM staff ORDER BY firstname, age DESC ;
SELECT firstname, age FROM staff ORDER BY firstname DESC, age DESC ;


-- DISTINCT, LIMIT
-- Выведите уникальные (неповторяющиеся) значения полей "firstname"
SELECT DISTINCT firstname FROM staff;

-- Отсортируйте записи по возрастанию значений поля "id". Выведите первые две записи данной выборки
-- SELECT id FROM workers ORDER BY id LIMIT 2;
SELECT * FROM staff LIMIT 2;

-- Отсортируйте записи по возрастанию значений поля "id". Пропустите первые 4 строки данной выборки и извлеките следующие 3
SELECT * FROM staff LIMIT 4, 3;
SELECT * FROM staff LIMIT 3 offset 4;

-- * Отсортируйте записи по убыванию поля "id". Пропустите две последние строки данной выборки и извлеките следующие за ними 3 строки
SELECT * FROM staff ORDER BY id DESC LIMIT 2, 3;


-- Агрегатные функции 
-- AVG, MIN, MAX, COUNT, SUM

-- Найдите количество сотрудников с должностью «Рабочий» 
SELECT COUNT(*) FROM staff WHERE post = 'Рабочий';

-- Посчитайте ежемесячную зарплату начальников
SELECT SUM(salary) FROM staff WHERE post = 'Начальник';

-- Выведите средний возраст сотрудников, у которых заработная плата больше 30000
SELECT AVG(age) FROM staff WHERE salary > 30000;

-- Выведите максимальную и минимальную заработные платы
SELECT MAX(salary), MIN(salary) FROM staff;



-- Работа персонала
DROP TABLE IF EXISTS activity_staff;
CREATE TABLE activity_staff (
	id INT AUTO_INCREMENT PRIMARY KEY, 
	staff_id INT NOT NULL,
	date_activity DATE,
	count_pages INT,
	FOREIGN KEY (staff_id) REFERENCES staff (id) ON DELETE CASCADE ON UPDATE CASCADE  
);

-- Наполнение данными
INSERT INTO activity_staff (staff_id, date_activity, count_pages)
VALUES
(1, '2022-01-01', 250),
(2, '2022-01-01', 220),
(3, '2022-01-01', 170),
(1, '2022-01-02', 100),
(2, '2022-01-02', 220),
(3, '2022-01-02', 300),
(7, '2022-01-02', 350),
(1, '2022-01-03', 168),
(2, '2022-01-03', 62),
(3, '2022-01-03', 84);

-- Найдите общее количество всех страниц 
SELECT SUM(count_pages) FROM activity_staff;

-- GROUP BY - группировка

-- Выведите общее количество напечатанных страниц каждым сотрудником
SELECT staff_id, SUM(count_pages) FROM activity_staff
GROUP BY staff_id;

-- Посчитайте количество страниц за каждый день
SELECT date_activity, SUM(count_pages) FROM activity_staff
GROUP BY date_activity;

-- Найдите среднее арифметическое по количеству ежедневных страниц 
SELECT date_activity, AVG(count_pages) FROM activity_staff
GROUP BY date_activity;


/* Сгруппируйте данные о сотрудниках по возрасту: 
1 группа – младше 20 лет
2 группа – от 20 до 40 лет
3 группа  - старше 40 лет 
Для каждой группы найдите суммарную зарплату */

SELECT 
	CASE 
			WHEN age < 20 THEN 'Младше 20 лет'
			WHEN age between 20 AND 40 THEN 'от 20 до 40 лет'
			WHEN age > 40 THEN 'Старше 40 лет'
			ELSE 'Не определено'
	END AS name_age, 
	SUM(salary)
FROM staff 
GROUP BY name_age;


-- HAVING

-- Выведите id сотрудников, которые напечатали более 500 страниц за всех дни
SELECT staff_id FROM activity_staff 
GROUP BY staff_id
HAVING SUM(count_pages)>500;

-- Выведите дни, когда работало более 3 сотрудников. 
-- Также укажите кол-во сотрудников, которые работали в выбранные дни.

SELECT date_activity, COUNT(count_pages) AS cnt_staff FROM activity_staff 
GROUP BY date_activity
HAVING cnt_staff>3;


-- Выведите должности, у которых средняя заработная плата составляет более 30000 
SELECT post FROM staff 
GROUP BY post
HAVING AVG(salary) > 30000;

SELECT * FROM staff;


#ДОМАШНЕЕ ЗАДАНИЕ
#1 Отсортируйте данные по полю заработная плата (salary) в порядке: убывания; возрастания 

SELECT * FROM staff ORDER BY salary;
SELECT * FROM staff ORDER BY salary DESC;

#2 Выведите 5 максимальных заработных плат (saraly)

SELECT * FROM staff ORDER BY salary DESC LIMIT 5;

#3 Посчитайте суммарную зарплату (salary) по каждой специальности (роst)

SELECT post, SUM(salary) FROM staff GROUP BY post;

#4 Найдите кол-во сотрудников с специальностью (post) «Рабочий» в возрасте от 24 до 49 лет включительно.

SELECT * FROM staff;

SELECT COUNT(*) 
FROM staff 
WHERE post = 'Рабочий' AND age>=29 AND age<=49;

#5 Найдите количество специальностей
SELECT COUNT(DISTINCT post) AS count_post
FROM staff;

#6 Выведите специальности, у которых средний возраст сотрудников меньше 30 лет 

SELECT post FROM staff 
GROUP BY post
HAVING AVG(age) < 30;