SELECT * FROM lesson_1.mobile_phones;

#2. Выведите название, производителя и цену для товаров, количество которых превышает 2
SELECT product_name, manufacture, price 
FROM mobile_phones
WHERE product_count > 2;

#Выведите весь ассортимент товаров марки “Samsung”
SELECT *
FROM mobile_phones
WHERE manufacture = 'Samsung';

#4. (по желанию)* С помощью регулярных выражений найти:
	#4.1. Товары, в которых есть упоминание "Iphone"
SELECT * 
FROM mobile_phones 
WHERE product_name REGEXP 'Iphone';

#4.2. Товары, в которых есть упоминание "Samsung"
SELECT * 
FROM mobile_phones 
WHERE manufacture REGEXP 'Samsung';

#4.3.  Товары, в которых есть ЦИФРЫ
SELECT * 
FROM mobile_phones 
WHERE product_name REGEXP '[[:digit:]]' = 1;

#4.4.  Товары, в которых есть ЦИФРА "8"
SELECT * 
FROM mobile_phones 
WHERE product_name REGEXP '[[8]]' = 1;
