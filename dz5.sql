DROP DATABASE IF EXISTS lesson_5;
CREATE DATABASE lesson_5;
USE lesson_5;

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
('Ольга', 'Васютина', 'Инженер', '2', 70000, 25),
('Петр', 'Некрасов', 'Уборщик', '36', 16000, 59),
('Саша', 'Петров', 'Инженер', '12', 50000, 49),
('Иван', 'Сидоров', 'Рабочий', '40', 50000, 59),
('Петр', 'Петров', 'Рабочий', '20', 25000, 40),
('Сидр', 'Сидоров', 'Рабочий', '10', 20000, 35),
('Антон', 'Антонов', 'Рабочий', '8', 19000, 28),
('Юрий', 'Юрков', 'Рабочий', '5', 15000, 25),
('Максим', 'Максимов', 'Рабочий', '2', 11000, 22),
('Юрий', 'Галкин', 'Рабочий', '3', 12000, 24),
('Людмила', 'Маркина', 'Уборщик', '10', 10000, 49),
('Юрий', 'Онегин', 'Начальник', '8', 100000, 39);

-- ОКОННЫЕ ФУНКЦИИ

-- Ранжирование 
-- Вывести список всех сотрудников и указать место в рейтинге по зарплатам

SELECT 
	DENSE_RANK() OVER(ORDER BY salary DESC) AS rank_salary, 
	CONCAT(firstname, ' ', lastname),
	post, 
	salary
FROM staff;

-- Вывести список всех сотрудников и указать место в рейтинге по зарплатам, но по каждой должности
SELECT 
	DENSE_RANK() OVER(PARTITION BY post ORDER BY salary DESC) AS rank_salary, 
	CONCAT(firstname, ' ', lastname),
	post, 
	salary
FROM staff;

-- Найти самых высокооплачиваемых сотрудников по каждой должности

SELECT rank_salary, 
	staff,
	post, 
	salary
FROM 	
(SELECT 
	DENSE_RANK() OVER(PARTITION BY post ORDER BY salary DESC) AS rank_salary, 
	CONCAT(firstname, ' ', lastname) AS staff,
	post, 
	salary
FROM staff) AS list
WHERE rank_salary=1
ORDER BY salary DESC;
	
-- Сравнение со смещением 

-- Вывести список всех сотрудников, отсортировав по зарплатам в порядке убывания и 
-- указать на сколько процентов ЗП меньше, чем у сотрудника со следующей (по значению) зарплатой

SELECT 
	id,
	CONCAT(firstname, ' ', lastname) AS staff,
	post, 
	salary,
	LEAD(salary, 1, 0) OVER(ORDER BY salary DESC) AS last_salary, 
	ROUND((salary-LEAD(salary, 1, 0) OVER(ORDER BY salary DESC))*100/salary) AS diff_percent
FROM staff;


--  Агрегация

-- Вывести всех сотрудников, отсортировав по зарплатам в рамках каждой должности и рассчитать:
-- общую сумму зарплат для каждой должности
-- процентное соотношение каждой зарплаты от общей суммы по должности
-- среднюю зарплату по каждой должности 
-- процентное соотношение каждой зарплаты к средней зарплате по должности

SELECT 
	id,
	CONCAT(firstname, ' ', lastname) AS staff,
	post, 
	salary,
	SUM(salary) OVER w AS sum_salary,
	ROUND(salary*100/SUM(salary) OVER w) AS percent_sum, 
	AVG(salary) OVER w AS avg_salary,
	ROUND(salary*100/AVG(salary) OVER w) AS percent_avg
FROM staff
WINDOW w AS (PARTITION BY post);  

-- примеры использования оконных функций
SELECT 
	id, firstname, lastname, salary,
	ROW_NUMBER() OVER(ORDER BY salary DESC) AS 'ROW_NUMBER', 
	RANK() OVER(ORDER BY salary DESC) AS 'RANK',
 	DENSE_RANK() OVER(ORDER BY salary DESC) AS 'DENSE_RANK',
 	NTILE(3) OVER(ORDER BY salary DESC) AS 'NTILE'
FROM staff;



-- Оценки учеников
DROP TABLE IF EXISTS academic_record;
CREATE TABLE academic_record (
	id INT AUTO_INCREMENT PRIMARY KEY, 
	name VARCHAR(45),
	quartal  VARCHAR(45),
    subject VARCHAR(45),
	grade INT
);

INSERT INTO academic_record (name, quartal, subject, grade)
values
	('Александр','1 четверть', 'математика', 4),
	('Александр','2 четверть', 'русский', 4),
	('Александр', '3 четверть','физика', 5),
	('Александр', '4 четверть','история', 4),
	('Антон', '1 четверть','математика', 4),
	('Антон', '2 четверть','русский', 3),
	('Антон', '3 четверть','физика', 5),
	('Антон', '4 четверть','история', 3),
    ('Петя', '1 четверть', 'физика', 4),
	('Петя', '2 четверть', 'физика', 3),
	('Петя', '3 четверть', 'физика', 4),
	('Петя', '2 четверть', 'математика', 3),
	('Петя', '3 четверть', 'математика', 4),
	('Петя', '4 четверть', 'физика', 5);


/*  Получить с помощью оконных функции:
- средний балл ученика 
- наименьшую оценку ученика
- наибольшую оценку ученика
- сумму всех оценок ученика
- количество всех оценок*/
SELECT 
	name, quartal, subject, grade, 
	AVG(grade) OVER(PARTITION BY name) AS avg_grade,
	MIN(grade) OVER(PARTITION BY name) AS min_grade,
	MAX(grade) OVER(PARTITION BY name) AS max_grade,
	SUM(grade) OVER(PARTITION BY name) AS sum_grade,
	COUNT(grade) OVER(PARTITION BY name) AS count_grade
FROM academic_record; 

-- с использованием псевдонима
SELECT 
	name, quartal, subject, grade, 
	AVG(grade) OVER w AS avg_grade,
	MIN(grade) OVER w AS min_grade,
	MAX(grade) OVER w AS max_grade,
	SUM(grade) OVER w AS sum_grade,
	COUNT(grade) OVER w AS count_grade
FROM academic_record
WINDOW w AS (PARTITION BY name); 

/* Получить информацию об оценках Пети по четвертям: 
- текущая успеваемость по физике
- оценка по физике в следующей четверти
- оценка по физике в предыдущей четверти
 */
SELECT 
	name, quartal, subject, 
	grade, 
	LAG(grade) OVER w AS prev_grade,
	LAG(grade, 1, 0) OVER w AS prev_grade, -- смещение на 1 и вместо NULL будет 0
	LEAD (grade) OVER w AS last_grade,
	LEAD (grade, 1, 0) OVER w AS last_grade -- смещение на 1 и вместо NULL будет 0
FROM academic_record
WHERE name = 'Петя' AND subject = 'физика'
WINDOW w AS (ORDER BY  quartal); 

DROP DATABASE IF EXISTS lesson_4;
CREATE DATABASE lesson_4;
USE lesson_4;

-- пользователи
DROP TABLE IF EXISTS users;
CREATE TABLE users (
	id SERIAL PRIMARY KEY, -- SERIAL = BIGINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE
    firstname VARCHAR(50),
    lastname VARCHAR(50) COMMENT 'Фамилия',
    email VARCHAR(120) UNIQUE
);

INSERT INTO users (id, firstname, lastname, email) VALUES 
(1, 'Reuben', 'Nienow', 'arlo50@example.org'),
(2, 'Frederik', 'Upton', 'terrence.cartwright@example.org'),
(3, 'Unique', 'Windler', 'rupert55@example.org'),
(4, 'Norene', 'West', 'rebekah29@example.net'),
(5, 'Frederick', 'Effertz', 'von.bridget@example.net'),
(6, 'Victoria', 'Medhurst', 'sstehr@example.net'),
(7, 'Austyn', 'Braun', 'itzel.beahan@example.com'),
(8, 'Jaida', 'Kilback', 'johnathan.wisozk@example.com'),
(9, 'Mireya', 'Orn', 'missouri87@example.org'),
(10, 'Jordyn', 'Jerde', 'edach@example.com');

-- сообщения
DROP TABLE IF EXISTS messages;
CREATE TABLE messages (
	id SERIAL PRIMARY KEY,
	from_user_id BIGINT UNSIGNED NOT NULL,
    to_user_id BIGINT UNSIGNED NOT NULL,
    body TEXT,
    created_at DATETIME DEFAULT NOW(),
    FOREIGN KEY (from_user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (to_user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE
);

INSERT INTO messages  (from_user_id, to_user_id, body, created_at) VALUES
(1, 2, 'Voluptatem ut quaerat quia. Pariatur esse amet ratione qui quia. In necessitatibus reprehenderit et. Nam accusantium aut qui quae nesciunt non.',  DATE_ADD(NOW(), INTERVAL 1 MINUTE)),
(2, 1, 'Sint dolores et debitis est ducimus. Aut et quia beatae minus. Ipsa rerum totam modi sunt sed. Voluptas atque eum et odio ea molestias ipsam architecto.',  DATE_ADD(NOW(), INTERVAL 3 MINUTE)),
(3, 1, 'Sed mollitia quo sequi nisi est tenetur at rerum. Sed quibusdam illo ea facilis nemo sequi. Et tempora repudiandae saepe quo.',  DATE_ADD(NOW(), INTERVAL 5 MINUTE)),
(4, 1, 'Quod dicta omnis placeat id et officiis et. Beatae enim aut aliquid neque occaecati odit. Facere eum distinctio assumenda omnis est delectus magnam.',  DATE_ADD(NOW(), INTERVAL 11 MINUTE)),
(1, 5, 'Voluptas omnis enim quia porro debitis facilis eaque ut. Id inventore non corrupti doloremque consequuntur. Molestiae molestiae deleniti exercitationem sunt qui ea accusamus deserunt.',  DATE_ADD(NOW(), INTERVAL 12 MINUTE)),
(1, 6, 'Rerum labore culpa et laboriosam eum totam. Quidem pariatur sit alias. Atque doloribus ratione eum rem dolor vitae saepe.',  DATE_ADD(NOW(), INTERVAL 14 MINUTE)),
(1, 7, 'Perspiciatis temporibus doloribus debitis. Et inventore labore eos modi. Quo temporibus corporis minus. Accusamus aspernatur nihil nobis placeat molestiae et commodi eaque.',  DATE_ADD(NOW(), INTERVAL 15 MINUTE)),
(8, 1, 'Suscipit dolore voluptas et sit vero et sint. Rem ut ratione voluptatum assumenda nesciunt ea. Quas qui qui atque ut. Similique et praesentium non voluptate iure. Eum aperiam officia quia dolorem.',  DATE_ADD(NOW(), INTERVAL 21 MINUTE)),
(9, 3, 'Et quia libero aut vitae minus. Rerum a blanditiis debitis sit nam. Veniam quasi aut autem ratione dolorem. Sunt quo similique dolorem odit totam sint sed.',  DATE_ADD(NOW(), INTERVAL 22 MINUTE)),
(10, 2, 'Praesentium molestias quia aut odio. Est quis eius ut animi optio molestiae. Amet tempore sequi blanditiis in est.',  DATE_ADD(NOW(), INTERVAL 25 MINUTE)),
(8, 3, 'Molestiae laudantium quibusdam porro est alias placeat assumenda. Ut consequatur rerum officiis exercitationem eveniet. Qui eum maxime sed in.',  DATE_ADD(NOW(), INTERVAL 27 MINUTE)),
(8, 1, 'Quo asperiores et id veritatis placeat. Aperiam ut sit exercitationem iste vel nisi fugit quia. Suscipit labore error ducimus quaerat distinctio quae quasi.',  DATE_ADD(NOW(), INTERVAL 28 MINUTE)),
(8, 1, 'Earum sunt quia sed harum modi accusamus. Quia dolor laboriosam asperiores aliquam quia. Sint id quasi et cumque qui minima ut quo. Autem sed laudantium officiis sit sit.',  DATE_ADD(NOW(), INTERVAL 33 MINUTE)),
(4, 1, 'Aut enim sint voluptas saepe. Ut tenetur quos rem earum sint inventore fugiat. Eaque recusandae similique earum laborum.',  DATE_ADD(NOW(), INTERVAL 35 MINUTE)),
(4, 1, 'Nisi rerum officiis officiis aut ad voluptates autem. Dolor nesciunt eum qui eos dignissimos culpa iste. Atque qui vitae quos odit inventore eum. Quam et voluptas quia amet.',  DATE_ADD(NOW(), INTERVAL 35 MINUTE)),
(4, 1, 'Consequatur ut et repellat non voluptatem nihil veritatis. Vel deleniti omnis et consequuntur. Et doloribus reprehenderit sed earum quas velit labore.',  DATE_ADD(NOW(), INTERVAL 37 MINUTE)),
(2, 1, 'Iste deserunt in et et. Corrupti rerum a veritatis harum. Ratione consequatur est ut deserunt dolores.',  DATE_ADD(NOW(), INTERVAL 37 MINUTE)),
(8, 1, 'Dicta non inventore autem incidunt accusamus amet distinctio. Aut laborum nam ab maxime. Maxime minima blanditiis et neque. Et laboriosam qui at deserunt magnam.',  DATE_ADD(NOW(), INTERVAL 41 MINUTE)),
(8, 1, 'Amet ad dolorum distinctio excepturi possimus quia. Adipisci veniam porro ipsum ipsum tempora est blanditiis. Magni ut quia eius qui.',  DATE_ADD(NOW(), INTERVAL 42 MINUTE)),
(8, 1, 'Porro aperiam voluptate quo eos nobis. Qui blanditiis cum id eos. Est sit reprehenderit consequatur eum corporis. Molestias quia quo sit architecto aut.',  DATE_ADD(NOW(), INTERVAL 50 MINUTE));

-- заявки на дружбу
DROP TABLE IF EXISTS friend_requests;
CREATE TABLE friend_requests (
	initiator_user_id BIGINT UNSIGNED NOT NULL,
    target_user_id BIGINT UNSIGNED NOT NULL,
    `status` ENUM('requested', 'approved', 'unfriended', 'declined'),
	requested_at DATETIME DEFAULT NOW(),
	updated_at DATETIME,
    PRIMARY KEY (initiator_user_id, target_user_id),
    FOREIGN KEY (initiator_user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE, 
    FOREIGN KEY (target_user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE
);

INSERT INTO friend_requests (initiator_user_id, target_user_id, `status`, requested_at, updated_at) 
VALUES 
(1, 10, 'approved', '2023-01-05 06:40:37', '2023-01-05 16:28:19'),
(1, 2, 'requested', '2023-01-06 07:33:23', NULL),
(1, 3, 'approved', '2023-01-07 01:53:07', '2023-01-18 16:22:56'),
(4, 1, 'approved', '2023-01-08 15:57:26', '2023-01-15 18:12:00'),
(5, 2, 'approved', '2023-01-08 18:22:00', '2023-01-14 08:25:00'),
(6, 3, 'unfriended', '2023-01-09 17:07:59', '2023-01-09 17:12:45'),
(7, 1, 'requested', '2023-01-09 06:20:23', NULL),
(8, 6, 'unfriended', '2023-01-10 01:50:03', '2023-01-10 06:50:59'),
(9, 7, 'approved', '2023-01-11 22:52:09', NULL),
(10, 6, 'approved', '2023-01-12 00:32:15', '2023-01-12 10:22:15');

-- сообщества
DROP TABLE IF EXISTS communities;
CREATE TABLE communities(
	id SERIAL PRIMARY KEY,
	name VARCHAR(150),
    INDEX communities_name_idx(name)
);

INSERT INTO `communities` (name) 
VALUES ('atque'), ('beatae'), ('est'), ('eum'), ('hic'), ('nemo'), ('quis'), ('rerum'), ('tempora'), ('voluptas');

-- пользователи сообщества
DROP TABLE IF EXISTS users_communities;
CREATE TABLE users_communities(
	user_id BIGINT UNSIGNED NOT NULL,
	community_id BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (user_id, community_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (community_id) REFERENCES communities(id) ON UPDATE CASCADE ON DELETE CASCADE
);

INSERT INTO users_communities (user_id, community_id) 
VALUES 
(1, 1), (1, 2), (1, 3),
(2, 1), (2, 2), 
(3, 1), (3, 2), (3, 10), (3, 5), (3, 8),
(4, 1), (4, 2), (4, 3), (4, 8),
(5, 1), (5, 2), (5, 3), (5, 6), (5, 8), (5, 10),
(6, 1), (6, 2), (6, 3), (6, 6),
(7, 1), (7, 2), (7, 3), (7, 8), (7, 7), (7, 6),
(8, 1), (8, 2), (8, 3), (8, 5), (8, 7), (8, 9),
(9, 1), (9, 2),  
(10, 1), (10, 10);

-- типы медиа
DROP TABLE IF EXISTS media_types;
CREATE TABLE media_types(
	id SERIAL PRIMARY KEY,
    name_type VARCHAR(255)
);

INSERT INTO media_types (name_type)
VALUES 	('Photo'), ('Music'), ('Video'), ('Post');


-- медиа
DROP TABLE IF EXISTS media;
CREATE TABLE media(
	id SERIAL PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    media_type_id BIGINT UNSIGNED,
  	body text,
  	filename VARCHAR(255), 
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME ON UPDATE CURRENT_TIMESTAMP,
	FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (media_type_id) REFERENCES media_types(id) ON UPDATE CASCADE ON DELETE SET NULL
);

INSERT INTO media (media_type_id, user_id, filename, body) VALUES 
(3, 1, 'a.avi', 'Est aut aliquid est. Soluta eveniet doloribus ipsam ut id assumenda quam. Consequuntur et velit aperiam error corporis rem corporis. Est similique quisquam quia maxime eaque possimus facere officiis. Odio magni atque dicta voluptatibus hic iste delectus.'),
(2, 2, '1.mp3', 'Laborum dolorem magni unde vero sit hic. Pariatur quia voluptas magnam. Blanditiis dolorem et molestias veniam facere provident.'),
(1, 3, 'sapiente.png', 'A quam ea ullam reiciendis vel et reiciendis. Delectus iure mollitia est. Eum dolores dolores sed officia vitae qui. Sed repudiandae voluptatem voluptatibus libero culpa quo.'),
(3, 4, 'rerum.mp4', 'Velit commodi in veniam occaecati. Tenetur temporibus ullam enim officiis aut illum. In maiores velit nobis soluta molestias maiores tempora. Quisquam et ut et sequi.'),
(1, 5, 'user5-profile-image.bmp', 'Est eaque est qui et omnis rerum. Expedita porro nesciunt inventore consequatur quos. Inventore aut rerum voluptas. Dicta vel ut quibusdam cupiditate tempore.'),
(1, 6, 'quasi.jpg', 'Atque et nam nulla et aliquid. Vel repellendus aut natus odit quibusdam quis atque et. Laudantium minima velit dolores eos voluptate nostrum.'),
(3, 7, 'non.mp4', 'Nihil ut et reprehenderit et. Numquam veniam quis impedit. Voluptas saepe rerum illo vel omnis. Aliquam illum ut quo saepe ea unde est.'),
(4, 8, 'new_01012023.docx', 'Sint quod fugit molestiae dolore repellendus est. Quis corporis necessitatibus commodi placeat temporibus doloremque voluptatem. Nemo maxime sit dolorem perferendis repellat. Et impedit deleniti eaque pariatur ut quia voluptatibus.'),
(1, 9, 'ullam.jpg', 'Optio sed aperiam veniam eum. Rerum placeat soluta iusto perspiciatis quibusdam dolorem eos. Ea pariatur optio est ut.'),
(2, 10, '2.mp3', 'Facere nostrum facilis aperiam quisquam dolor. Minima omnis est nam.'),
(3, 1, 'non.mp4', 'A omnis ratione non. Et velit sed incidunt corporis ut rerum nemo. Ut pariatur tempora ea incidunt praesentium ut. Eligendi et et rerum sequi ut.'),
(4, 1, 'new_07012023.html', 'Quo minus harum debitis debitis quis sunt. Dolores suscipit placeat dolorum non voluptate et. Non eos odio esse tempore. Illum minus quidem temporibus porro.'),
(1, 1, '1.jpg', NULL),
(2, 1, 'godt.mp3', 'Nobis est sed blanditiis assumenda incidunt explicabo. Facere rem assumenda odio explicabo ad enim repellat quia. Dolor mollitia fugiat officia nihil animi.'),
(3, 1, 'path1.avi', 'Tempora ad et aspernatur laborum ut dolor et. Exercitationem quaerat corporis placeat et.'),
(4, 1, 'new_07012023.html', 'Accusantium est ea fuga omnis mollitia. Dolores officia et consequatur iste est quo. Ullam laborum qui ut quo delectus temporibus.'),
(1, 1, 'map.bmp', 'Quasi itaque atque ut aliquam debitis. Qui consequuntur maiores sit ad perspiciatis quaerat assumenda repudiandae. Necessitatibus placeat quaerat aut voluptatem ratione voluptate expedita. Nulla doloremque aut molestiae nam.'),
(2, 1, '7.acc', 'Deserunt voluptatem quia voluptatem sit. Qui omnis distinctio optio voluptatem veniam atque dolorem. Repellat laboriosam illo consequatur nesciunt voluptas magni rerum. Saepe quos qui doloremque.'),
(3, 1, 'path2.avi', 'Fugiat consequuntur voluptatem odit omnis. Quia aut voluptate officia rerum. Cumque voluptatem eaque dolorum voluptas sed. Et autem atque est minus veritatis explicabo eos.'),
(4, 2, 'new_10012023.html', 'Autem dolore beatae aut corporis fugit ratione. Ex beatae qui at. Est deleniti asperiores temporibus perferendis est.'),
(1, 8, 'poster.jpg', 'Provident eligendi animi quidem qui ipsum. Accusamus dolor sint est qui magnam. Omnis enim quis dolore magni facilis repudiandae deserunt. Consequatur eum at recusandae id tenetur voluptas amet.'),
(2, 10, 'music_all.mp3', 'Animi ut labore dolore atque consequuntur maxime fugit. Sunt et et facere sint. Recusandae numquam accusamus a. Non quia dolorem reiciendis earum et officiis iure.'),
(3, 3, 'kino.avi', 'Sint officiis a ipsa quaerat rerum ea totam. Aut perferendis deleniti error ipsa ducimus ipsam. Ipsum a sunt quis placeat.'),
(4, 9, 'new_117012023.doc', 'Et accusamus a et adipisci dolore. Blanditiis sit vitae dolorem voluptas temporibus numquam ab. Aut temporibus accusantium consectetur.'),
(1, 10, 'main_photo.jpg', 'Consequuntur animi sed ea perferendis ad magnam. Aut libero alias sequi iste qui est. Ut quo dignissimos quibusdam doloremque est est incidunt.'),
(2, 1, 'ariya.mp3', 'Accusantium sit praesentium voluptatem molestias architecto. Excepturi doloremque ab eligendi eum ullam voluptas qui. Inventore expedita distinctio omnis laborum laboriosam.'),
(3, 1, 'film.mp4', NULL),
(4, 1, 'news.html', 'A culpa nostrum et quis. Id ipsum ipsum deserunt earum eaque aut earum. Blanditiis et commodi voluptas.'),
(1, 3, 'non.jpg', 'Cumque quod provident provident fugit cumque numquam. Fuga totam delectus a aut quaerat nemo dignissimos eos. Ratione harum et laborum qui dolore aliquam facilis numquam. At quas nam sapiente porro nesciunt voluptatum.'),
(1, 8, 'et.jpg', 'Provident quia fuga et consequatur reprehenderit repellat. Et aut cum nostrum ut beatae animi aut alias.');

-- лайки медиа
DROP TABLE IF EXISTS likes;
CREATE TABLE likes(
	id SERIAL PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    media_id BIGINT UNSIGNED NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id)  ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (media_id) REFERENCES media(id)  ON UPDATE CASCADE ON DELETE CASCADE
);

INSERT INTO likes (user_id, media_id) VALUES 
(1, 1), (2, 1), (3, 1), (4, 1), (5, 2), (6, 2), (7, 2), (8, 8), (1, 9), (10, 15), (7, 11), (5, 12), (6, 13), (1, 14), (1, 15), (1, 16), (1, 17), (1, 18), (1, 19), (1, 20); 

-- профиль пользователя
DROP TABLE IF EXISTS `profiles`;
CREATE TABLE `profiles` (
	user_id SERIAL PRIMARY KEY,
    gender CHAR(1),
    birthday DATE,
	photo_id BIGINT UNSIGNED,
    hometown VARCHAR(100),
    FOREIGN KEY (user_id) REFERENCES users(id)  ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (photo_id) REFERENCES media(id)  ON UPDATE CASCADE ON DELETE SET NULL
);
INSERT INTO `profiles` (user_id, gender, birthday, photo_id, hometown) VALUES 
(1, 'f', '1976-11-08', 9, 'Adriannaport'),
(2, 'f', '2011-12-20', 13, 'North Nettieton'),
(3, 'm', '1994-06-15', 3, 'Padbergtown'),
(4, 'f', '1979-11-07', NULL, 'Port Rupertville'),
(5, 'f', '1976-04-19', 5, 'Spencerfort'),
(6, 'f', '1983-09-07', 6, 'South Woodrowmouth'),
(7, 'm', '2014-07-31', NULL, 'South Jeffereyshire'),
(8, 'f', '1975-03-26', 17, 'Howeside'),
(9, 'f', '1982-11-01', 9, 'Loweborough'),
(10, 'm', '1977-05-14', NULL, 'New Nellaside'); 

-- TEMPORARY TABLE, СTE, VIEW
-- получение друзей пользователя с id=1 из базы lesson_4
SELECT initiator_user_id AS friend_id FROM lesson_4.friend_requests 
WHERE target_user_id=1 AND status='approved' -- ID друзей, заявку которых подтвердили
UNION
SELECT target_user_id FROM  lesson_4.friend_requests  
WHERE  initiator_user_id=1 AND status='approved'; -- ID друзей, подтвердивших заявку

-- ВРЕМЕННАЯ ТАБЛИЦА
DROP TABLE IF EXISTS tbl_friends;
CREATE TEMPORARY TABLE tbl_friends 
SELECT initiator_user_id AS user_id, target_user_id AS friend_id FROM lesson_4.friend_requests 
WHERE  status='approved' -- ID друзей, заявку которых подтвердили
UNION
SELECT target_user_id, initiator_user_id FROM  lesson_4.friend_requests  
WHERE  status='approved'; -- ID друзей, подтвердивших заявку

SELECT friend_id FROM tbl_friends
WHERE user_id=1;

-- ОБЩЕЕ ТАБЛИЧНОЕ ВЫРАЖЕНИЕ
WITH friends AS  
(SELECT initiator_user_id AS user_id, target_user_id AS friend_id FROM lesson_4.friend_requests 
WHERE  status='approved' -- ID друзей, заявку которых подтвердили
UNION
SELECT target_user_id, initiator_user_id FROM  lesson_4.friend_requests  
WHERE  status='approved') -- ID друзей, подтвердивших заявку

SELECT friend_id FROM friends
WHERE user_id=1;

-- С помощью СТЕ реализуйте таблицу квадратов чисел от 1 до 10
WITH RECURSIVE cte AS
(
	SELECT 1 AS a, 1 as result
	UNION ALL
	SELECT a + 1, pow(a+1,2) as result FROM cte
	WHERE a < 10
)
SELECT a, result FROM cte;


-- ПРЕДСТАВЛЕНИЯ

CREATE OR REPLACE VIEW v_friends AS  
(SELECT initiator_user_id AS user_id, target_user_id AS friend_id FROM lesson_4.friend_requests 
WHERE  status='approved' -- ID друзей, заявку которых подтвердили
UNION
SELECT target_user_id, initiator_user_id FROM  lesson_4.friend_requests  
WHERE  status='approved'); -- ID друзей, подтвердивших заявку

SELECT friend_id FROM v_friends
WHERE user_id=1;


-- Создайте представление, в котором будут выводится все сообщения, в которых принимал 
-- участие пользователь с id = 1.
CREATE OR REPLACE VIEW v_messages_user AS
SELECT id, body FROM lesson_4.messages
WHERE from_user_id = 1 -- от пользователя
OR to_user_id = 1; -- к пользователю

SELECT id, body FROM v_messages_user;

-- Найдите друзей у  друзей пользователя с id = 1 и поместите выборку в представление; 
-- (решение задачи с помощью CTE)

CREATE OR REPLACE VIEW v_friends_friends AS
WITH friends AS (
	SELECT initiator_user_id AS id
    FROM lesson_4.friend_requests
    WHERE status = 'approved' AND target_user_id = 1 
    UNION
    SELECT target_user_id AS id
    FROM lesson_4.friend_requests
    WHERE status = 'approved' AND initiator_user_id = 1 
)
SELECT fr.initiator_user_id AS friend_id
FROM friends f
JOIN lesson_4.friend_requests fr ON fr.target_user_id = f.id
WHERE fr.initiator_user_id != 1  AND fr.status = 'approved'
UNION
SELECT fr.target_user_id
FROM  friends f
JOIN  lesson_4.friend_requests fr ON fr.initiator_user_id = f.id 
WHERE fr.target_user_id != 1  AND status = 'approved';

SELECT friend_id FROM v_friends_friends;

-- Найдите друзей у  друзей пользователя с id = 1. 
-- (решение задачи с помощью представления “друзья”)


SELECT fr.initiator_user_id AS friend_id
FROM v_friends f
JOIN lesson_4.friend_requests fr ON fr.target_user_id = f.friend_id
WHERE fr.initiator_user_id != 1 AND f.user_id=1  AND fr.status = 'approved'
UNION
SELECT fr.target_user_id
FROM  v_friends f
JOIN  lesson_4.friend_requests fr ON fr.initiator_user_id = f.friend_id 
WHERE fr.target_user_id != 1  AND f.user_id=1 AND  status = 'approved';


-- ДОМАШНЕЕ ЗАДАНИЕ

-- 1. Создайте представление, в которое попадет информация о пользователях (имя, фамилия, город и пол), которые не старше 20 лет.

CREATE OR REPLACE VIEW v_users AS 
SELECT 
CONCAT (firstname, ' ', lastname) AS 'Пользователи < 20 лет', 
hometown, 
gender
FROM users u
JOIN profiles p ON u.id = p.user_id
WHERE TIMESTAMPDIFF(YEAR, birthday, NOW()) < 20
GROUP BY u.id;

SELECT * FROM v_users;

-- 2. Найдите кол-во отправленных сообщений каждым пользователем и выведите ранжированный список пользователей, указав имя и фамилию пользователя, количество отправленных сообщений и место в рейтинге (первое место у пользователя с максимальным количеством сообщений) . (используйте DENSE_RANK)

SELECT 
	DENSE_RANK() OVER (ORDER BY COUNT(from_user_id) DESC) AS 'Место в рейтинге',
	COUNT(from_user_id) AS 'Количество отправленных сообщений',
	CONCAT(firstname, ' ', lastname) AS 'Пользователи'
FROM users u
JOIN messages m ON u.id = m.from_user_id
GROUP BY u.id;

-- 3. Выберите все сообщения, отсортируйте сообщения по возрастанию даты отправления (created_at) и найдите разницу дат отправления между соседними сообщениями, получившегося списка. (используйте LEAD или LAG)

SELECT *, 
LAG(created_at, 1, 0) OVER (PARTITION BY TIMESTAMPDIFF(SECOND, created_at, created_at)) AS lag_created_at,
LEAD(created_at) OVER (PARTITION BY TIMESTAMPDIFF(SECOND, created_at, created_at)) AS lead_created_at
FROM messages ORDER BY TIMESTAMPDIFF(SECOND, created_at, NOW()) DESC;