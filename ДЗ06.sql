
/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "06 - Оконные функции".

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
1. Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года
(в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки).
Выведите: id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом

Пример:
-------------+----------------------------
Дата продажи | Нарастающий итог по месяцу
-------------+----------------------------
 2015-01-29   | 4801725.31
 2015-01-30	 | 4801725.31
 2015-01-31	 | 4801725.31
 2015-02-01	 | 9626342.98
 2015-02-02	 | 9626342.98
 2015-02-03	 | 9626342.98
Продажи можно взять из таблицы Invoices.
Нарастающий итог должен быть без оконной функции.
*/

;WITH datesInv AS (SELECT i1.InvoiceDate, FORMAT(i1.InvoiceDate, 'yyyyMM') AS dateGroup
               FROM Sales.Invoices i1
               GROUP BY i1.InvoiceDate),
     totalMonth AS ((SELECT i2.InvoiceDate, FORMAT(i2.InvoiceDate, 'yyyyMM') AS dateGroup
					,SUM(ol.Quantity * ol.UnitPrice) monSum
					 FROM Sales.Invoices i2 INNER JOIN Sales.OrderLines ol ON i2.OrderID = ol.OrderID
					 GROUP BY i2.InvoiceDate))
SELECT d.InvoiceDate, (SELECT SUM(t.monSum)   FROM totalMonth t
						WHERE t.InvoiceDate >='20150101' AND t.InvoiceDate <=EOMONTH(d.InvoiceDate)) AS SUMItog
FROM datesInv d
WHERE d.InvoiceDate > '20150101'
ORDER BY d.InvoiceDate;


/*
2. Сделайте расчет суммы нарастающим итогом в предыдущем запросе с помощью оконной функции.
   Сравните производительность запросов 1 и 2 с помощью set statistics time, io on
*/
;WITH datesInv AS (SELECT i1.InvoiceDate, FORMAT(i1.InvoiceDate, 'yyyyMM') AS dateGroup
				FROM Sales.Invoices i1  GROUP BY i1.InvoiceDate),
    datesGroup AS (SELECT 	FORMAT(i2.InvoiceDate, 'yyyyMM') dateMon,
					SUM(ol.Quantity * ol.UnitPrice) MonSum
					FROM Sales.Invoices i2 INNER JOIN Sales.OrderLines ol ON i2.OrderID = ol.OrderID
					WHERE i2.InvoiceDate >= '20150101'
					GROUP BY FORMAT(i2.InvoiceDate, 'yyyyMM')),
     sumTotal AS (SELECT dg.dateMon,  dg.MonSum,
                               SUM(dg.MonSum) OVER ( ORDER BY dg.dateMon) SumItog
                        FROM datesGroup dg)

SELECT d.InvoiceDate, st.SumItog
FROM datesInv d  LEFT JOIN sumTotal st ON d.dategroup = st.dateMon
WHERE d.InvoiceDate >= '20150101'
ORDER BY InvoiceDate;
---
/*
3. Вывести список 2х самых популярных продуктов (по количеству проданных)
в каждом месяце за 2016 год (по 2 самых популярных продукта в каждом месяце).
*/
;WITH soldItems AS (SELECT i.InvoiceDate, FORMAT(i.InvoiceDate, 'yyyyMM') AS dateGroup,
                          ol.Quantity, ol.StockItemID, 
						  SUM(ol.Quantity) OVER ( PARTITION BY ol.StockItemID, FORMAT(i.InvoiceDate, 'yyyyMM') ) AS SumQtySold
                   FROM Sales.Invoices i INNER JOIN Sales.OrderLines ol ON i.OrderID = ol.OrderID
                   WHERE i.InvoiceDate >= '20160101' AND  i.InvoiceDate < '20170101'),
     soldItemsR AS (SELECT *, DENSE_RANK() OVER ( PARTITION BY si.dateGroup ORDER BY si.SumQtySold DESC ) Soldrank
                        FROM soldItems si)
SELECT DISTINCT si.dateGroup, si.StockItemID, s.StockItemName, si.SumQtySold, si.Soldrank
FROM soldItemsR si   LEFT JOIN Warehouse.StockItems s ON s.StockItemID = si.StockItemID
WHERE si.Soldrank < 3
ORDER BY dateGroup, si.SumQtySold DESC;

/*
4. Функции одним запросом
Посчитайте по таблице товаров (в вывод также должен попасть ид товара, название, брэнд и цена):
* пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
* посчитайте общее количество товаров и выведете полем в этом же запросе
* посчитайте общее количество товаров в зависимости от первой буквы названия товара
* отобразите следующий id товара исходя из того, что порядок отображения товаров по имени
* предыдущий ид товара с тем же порядком отображения (по имени)
* названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
* сформируйте 30 групп товаров по полю вес товара на 1 шт

Для этой задачи НЕ нужно писать аналог без аналитических функций.
*/
SELECT COUNT(*) OVER ( ) AS QtyItems,
       COUNT(*) OVER (PARTITION BY LEFT(SI.StockItemName, 1) ORDER BY LEFT(SI.StockItemName, 1)) AS QtyItemsFirstLetter,
	   LEFT(SI.StockItemName, 1) AS Firstletter,
	   SI.StockItemID,  SI.StockItemName, SI.Brand, SI.UnitPrice,
       LAG(SI.StockItemID, 1) OVER (ORDER BY SI.StockItemName)  AS PreStocksItem,
       ISNULL(LAG(SI.StockItemName, 2) OVER (ORDER BY SI.StockItemName), 'No items') AS Pre2PreStocksItem,
       NTILE(30) OVER (ORDER BY si.TypicalWeightPerUnit) AS TypicalWeight
FROM Warehouse.StockItems SI

/*
5. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал.
   В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки.
*/

;WITH customersOrders AS (SELECT o.SalespersonPersonID, o.CustomerID, o.OrderID,
                                DENSE_RANK() OVER (PARTITION BY o.CustomerID ORDER BY o.OrderDate DESC ) AS LastOrder
                                FROM Sales.Orders o)
SELECT c.SalespersonPersonID,  p.FullName,   c.CustomerID, c2.CustomerName, o2.OrderDate,
    (SELECT SUM(ol.UnitPrice * ol.Quantity) FROM Sales.OrderLines ol WHERE ol.OrderID = o2.OrderID) AS OrderSum
		FROM customersOrders c
         LEFT JOIN Application.People p ON p.PersonID = c.SalespersonPersonID
         LEFT JOIN Sales.Customers c2 ON c2.CustomerID = c.CustomerID
         LEFT JOIN Sales.Orders o2 ON o2.OrderID = c.OrderID
WHERE c.LastOrder = 1;
/*
6. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/
;WITH CustomerItems AS (SELECT ol.OrderID, ol.StockItemID,  ol.UnitPrice, o.CustomerID,
                                  ROW_NUMBER() OVER ( PARTITION BY o.CustomerID ORDER BY ol.UnitPrice DESC ) AS SumRank
                           FROM Sales.OrderLines ol  INNER JOIN Sales.Orders o ON ol.OrderID = o.OrderID)
SELECT ci.CustomerID,  c.CustomerName, ci.SumRank,   ci.StockItemID, ci.UnitPrice,
       (SELECT TOP 1 o.OrderDate FROM Sales.Orders o WHERE o.OrderID = ci.OrderID) AS OrderDate
FROM CustomerItems ci INNER JOIN Sales.Customers c ON c.CustomerID = ci.CustomerID
WHERE ci.SumRank <= 2
ORDER BY CustomerID;
