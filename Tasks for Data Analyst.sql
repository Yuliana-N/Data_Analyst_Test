
-- Г) топ-3 товаров по выручке и их доля в общей выручки за любой год

-- ПОЛЯ: год, товар, общая сумма стоимости каждого заказанного товара за год, процент от общей суммы всех товаров за весь год, в котором они были приобретены 
 
 SELECT * FROM(SELECT *, ROW_NUMBER() OVER (PARTITION BY PURCHASE_YEAR ORDER BY SUM_PER DESC) AS NUM_ 
               FROM (
 SELECT PURCHASE_YEAR, ITEMID, SUM_PER, ROUND((SUM_PER / SUM(SUM_PER) OVER (PARTITION BY PURCHASE_YEAR)) * 100) AS PERCENT_
    FROM (
        SELECT EXTRACT(YEAR FROM "DATE") AS PURCHASE_YEAR, I.ITEMID, SUM(I.PRICE) AS SUM_PER
        FROM PURCHASES P
        JOIN ITEMS I ON P.ITEMID = I.ITEMID
        JOIN USERS U ON P.USERID = U.USERID
        GROUP BY EXTRACT(YEAR FROM "DATE"), I.ITEMID
        ORDER BY PURCHASE_YEAR, SUM_PER DESC
    ) RESULT_1_SUM) TOKEN_ ) ROW_N WHERE ROW_N.NUM_ <= 3;

-- В) какой товар дает наибольший вклад в выручку за последний год

-- ЕСТЬ ВОЗМОЖНОСТЬ выбрать период (за текущий календарный год, за предыдущий год, за последние 12 месяцев
SELECT
       TO_CHAR("DATE", 'YYYY') AS year_, items.itemid AS ITEM, SUM(PRICE) AS SUM_OF_YEAR     
    FROM
        PURCHASES
    JOIN ITEMS ON PURCHASES.ITEMID = ITEMS.ITEMID
    JOIN USERS ON PURCHASES.USERID = USERS.USERID
--WHERE date_trunc('year', "DATE") = date_trunc('year', CURRENT_DATE) - INTERVAL '1 year' -- за предыдущий календарный год
--WHERE date_trunc('year', "DATE") = date_trunc('year', CURRENT_DATE) -- за текущий календарный год
WHERE "DATE" >= CURRENT_DATE - INTERVAL '12 months'-- за последние 12 месяцев 
--AND "DATE" < date_trunc('month', CURRENT_DATE)-- можно добавить условие в выборку - не включая текущий месяц т.к. он ещё не завершен или до текущей даты если убрать date_trunc
    GROUP BY year_, items.itemid
    ORDER BY SUM_OF_YEAR DESC
    LIMIT 1;
    
-- Б) в каком месяце года выручка от пользователей в возрастном диапазоне 35+ самая большая

-- ВЫВЕДЕНЫ ПОЛЯ, в которых в каком месяце, каждого года выручка от пользователей в возрастном диапазоне 35+ самая большая

SELECT YEAR_,MONTH_,SUM_OF_MONTH FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY YEAR_ ORDER BY SUM_OF_MONTH DESC) AS NUM_ 
               FROM (SELECT TO_CHAR("DATE", 'YYYY') AS YEAR_,TO_CHAR("DATE", 'MM') AS MONTH_, SUM(I.PRICE) AS SUM_OF_MONTH
FROM PURCHASES P
JOIN USERS U ON P.USERID = U.USERID
JOIN ITEMS I ON P.ITEMID = I.ITEMID
WHERE U.AGE >= 35
GROUP BY YEAR_, MONTH_
--ORDER BY SUM_OF_MONTH DESC 
 ) RESULT_1_SUM ) NUM_
 WHERE NUM_ = 1;
 
 
--А) какую сумму в среднем в месяц тратит: - пользователи в возрастном диапазоне от 18 до 25 лет включительно - пользователи в возрастном диапазоне от 26 до 35 лет включительно
-- для наглядности ВЫВЕДЕНЫ ПОЛЯ месяц-год, суммы выручки от каждого товара за каждый месяц и средняя за месяц за весь период

SELECT MONTH_, SUM_OF_ITEM, ROUND(AVG(SUM_OF_ITEM) OVER (),2) AS AVG_PER_PERIOD_ 
FROM (SELECT TO_CHAR("DATE", 'YYYY-MM') AS MONTH_, SUM(PRICE) AS SUM_OF_ITEM 
FROM PURCHASES P
JOIN USERS U ON P.USERID = U.USERID
JOIN ITEMS I ON P.ITEMID = I.ITEMID
WHERE U.AGE BETWEEN 18 and 25
      -- WHERE U.AGE BETWEEN 26 and 35 -- диапазон от 26 до 35 раскоментить, закоментить предыдущий
AND "DATE" < date_trunc ('month', current_date) ----не включает текущий месяц, т.к. он ещё не завершен или убрать функцию date_trunc и будет до текущей даты
GROUP BY TO_CHAR("DATE", 'YYYY-MM')) SUM_PER_MONTH
ORDER BY MONTH_ DESC
