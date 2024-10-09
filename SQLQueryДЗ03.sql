/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, GROUP BY, HAVING".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Посчитать среднюю цену товара, общую сумму продажи по месяцам.
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Средняя цена за месяц по всем товарам
* Общая сумма продаж за месяц

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/



SELECT YEAR(sI.InvoiceDate)          as 'Год продажи',
       MONTH(sI.InvoiceDate)			as 'Месяц продажи',
       AVG(sOL.Quantity * sOl.UnitPrice)        as [Средняя цена за месяц по всем товарам],
       SUM(sOL.Quantity * sOl.UnitPrice)        as [Общая сумма продаж за месяц]
FROM Sales.Invoices sI
      INNER JOIN Sales.Orders sO on sO.OrderID = sI.OrderID
         INNER JOIN Sales.OrderLines sOL on sO.OrderID = sOL.OrderID
GROUP BY YEAR(sI.InvoiceDate), MONTH(sI.InvoiceDate)

/*
2. Отобразить все месяцы, где общая сумма продаж превысила 4 600 000

Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Общая сумма продаж

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/


SELECT YEAR(sI.InvoiceDate)          as 'Год продажи',
       MONTH(sI.InvoiceDate) as 'Месяц продажи',
       sum(sOL.Quantity * sOL.UnitPrice)        as 'Общая сумма продаж'
FROM Sales.Invoices sI
      INNER JOIN Sales.Orders sO on sO.OrderID = sI.OrderID
         INNER JOIN Sales.OrderLines sOL on sO.OrderID = sOL.OrderID
GROUP BY YEAR(sI.InvoiceDate), MONTH(sI.InvoiceDate)
HAVING SUM(sOL.Quantity * sOL.UnitPrice) > 4600000

/*
3. Вывести сумму продаж, дату первой продажи
и количество проданного по месяцам, по товарам,
продажи которых менее 50 ед в месяц.
Группировка должна быть по году,  месяцу, товару.

Вывести:
* Год продажи
* Месяц продажи
* Наименование товара
* Сумма продаж
* Дата первой продажи
* Количество проданного

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECT YEAR(sI.InvoiceDate)          as 'Год продажи',
       MONTH(sI.InvoiceDate) as 'Месяц продажи',
       wSI.StockItemName                       as 'Наименование товара',
       SUM(sOL.Quantity * sOl.UnitPrice)        as 'Сумма продаж',
       (SELECT TOP 1 OInn.OrderDate
        FROM Sales.OrderLines solInn
                 INNER JOIN Sales.Orders OInn on OInn.OrderID = solInn.OrderID
        WHERE solInn.StockItemID = wSI.StockItemID
        ORDER BY OInn.OrderDate)			AS 'Дата первой продажи',
		SUM(sOL.Quantity )        as 'Количество проданного'
FROM Sales.Invoices sI
     INNER JOIN Sales.Orders sO on sO.OrderID = sI.OrderID
       INNER JOIN Sales.OrderLines sOL on sO.OrderID = sOL.OrderID
         INNER JOIN Warehouse.StockItems wSI on wSI.StockItemID = sOL.StockItemID
GROUP BY YEAR(sI.InvoiceDate), MONTH(sI.InvoiceDate), wSI.StockItemID, wSI.StockItemName
HAVING SUM(sOL.Quantity) < 50

-- ---------------------------------------------------------------------------
-- Опционально
-- ---------------------------------------------------------------------------
/*
Написать запросы 2-3 так, чтобы если в каком-то месяце не было продаж,
то этот месяц также отображался бы в результатах, но там были нули.
*/



SELECT YEAR(sI.InvoiceDate)          as 'Год продажи',
       MONTH(sI.InvoiceDate) as 'Месяц продажи',
       sum(sOL.Quantity * sOL.UnitPrice)        as 'Общая сумма продаж'
FROM Sales.Invoices sI 
      INNER JOIN Sales.Orders sO on sO.OrderID = sI.OrderID
         INNER JOIN Sales.OrderLines sOL on sO.OrderID = sOL.OrderID 
GROUP BY YEAR(sI.InvoiceDate), MONTH(sI.InvoiceDate)
HAVING SUM(sOL.Quantity * sOL.UnitPrice) > 4600000
UNION
SELECT y as 'Год продажи', mon as 'Месяц продажи', 0  as 'Общая сумма продаж' FROM
(
SELECT y, mon FROM
(SELECT DISTINCT YEAR(sI.InvoiceDate)   y
FROM Sales.Invoices sI 
      INNER JOIN Sales.Orders sO on sO.OrderID = sI.OrderID
         INNER JOIN Sales.OrderLines sOL on sO.OrderID = sOL.OrderID 
GROUP BY YEAR(sI.InvoiceDate), MONTH(sI.InvoiceDate)
HAVING SUM(sOL.Quantity * sOL.UnitPrice) > 4600000 ) a,
 (SELECT mon from (values (1), (2), (3), (4), (5), (6), (7), (8), (9), (10), (11), (12)) v(mon)) b
 ) c
  LEFT JOIN (SELECT DISTINCT YEAR(sI.InvoiceDate)  as yi, MONTH(sI.InvoiceDate) as moni
FROM Sales.Invoices sI 
      INNER JOIN Sales.Orders sO on sO.OrderID = sI.OrderID
         INNER JOIN Sales.OrderLines sOL on sO.OrderID = sOL.OrderID 
GROUP BY YEAR(sI.InvoiceDate), MONTH(sI.InvoiceDate)
HAVING SUM(sOL.Quantity * sOL.UnitPrice) > 4600000) si ON y=yi AND mon=moni
  WHERE si.yi IS NULL AND si.moni IS NULL 
  ORDER BY 1,2 


SELECT YEAR(sI.InvoiceDate)          as 'Год продажи',
       MONTH(sI.InvoiceDate) as 'Месяц продажи',
       wSI.StockItemName                       as 'Наименование товара',
       SUM(sOL.Quantity * sOl.UnitPrice)        as 'Сумма продаж',
       (SELECT TOP 1 OInn.OrderDate
        FROM Sales.OrderLines solInn
                 INNER JOIN Sales.Orders OInn on OInn.OrderID = solInn.OrderID
        WHERE solInn.StockItemID = wSI.StockItemID
        ORDER BY OInn.OrderDate)			AS 'Дата первой продажи',
		SUM(sOL.Quantity )        as 'Количество проданного'
FROM Sales.Invoices sI
     INNER JOIN Sales.Orders sO on sO.OrderID = sI.OrderID
       INNER JOIN Sales.OrderLines sOL on sO.OrderID = sOL.OrderID
         INNER JOIN Warehouse.StockItems wSI on wSI.StockItemID = sOL.StockItemID
GROUP BY YEAR(sI.InvoiceDate), MONTH(sI.InvoiceDate), wSI.StockItemID, wSI.StockItemName
HAVING SUM(sOL.Quantity) < 50
UNION
SELECT y   as 'Год продажи', mon as 'Месяц продажи', NULL  as 'Наименование товара', 0 as 'Сумма продаж'
, NULL as 'Дата первой продажи', 0 as 'Количество проданного' FROM
(
SELECT y, mon FROM
(  SELECT DISTINCT YEAR(sI.InvoiceDate)          as y
      -- MONTH(sI.InvoiceDate) as mon
FROM Sales.Invoices sI
     INNER JOIN Sales.Orders sO on sO.OrderID = sI.OrderID
       INNER JOIN Sales.OrderLines sOL on sO.OrderID = sOL.OrderID
         INNER JOIN Warehouse.StockItems wSI on wSI.StockItemID = sOL.StockItemID
GROUP BY YEAR(sI.InvoiceDate), MONTH(sI.InvoiceDate), wSI.StockItemID, wSI.StockItemName
HAVING SUM(sOL.Quantity) < 50 ) a,
 (SELECT mon from (values (1), (2), (3), (4), (5), (6), (7), (8), (9), (10), (11), (12)) v(mon)) b
 ) c
  LEFT JOIN (  SELECT DISTINCT YEAR(sI.InvoiceDate)          as yi,
       MONTH(sI.InvoiceDate) as moni
FROM Sales.Invoices sI
     INNER JOIN Sales.Orders sO on sO.OrderID = sI.OrderID
       INNER JOIN Sales.OrderLines sOL on sO.OrderID = sOL.OrderID
         INNER JOIN Warehouse.StockItems wSI on wSI.StockItemID = sOL.StockItemID
GROUP BY YEAR(sI.InvoiceDate), MONTH(sI.InvoiceDate), wSI.StockItemID, wSI.StockItemName
HAVING SUM(sOL.Quantity) < 50) si ON y=yi AND mon=moni
  WHERE si.yi IS NULL AND si.moni IS NULL 
    ORDER BY 1,2 
 