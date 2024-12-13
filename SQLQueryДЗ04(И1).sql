/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "03 - Подзапросы, CTE, временные таблицы".

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
-- Для всех заданий, где возможно, сделайте два варианта запросов:
--  1) через вложенный запрос
--  2) через WITH (для производных таблиц)
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson),
и не сделали ни одной продажи 04 июля 2015 года.
Вывести ИД сотрудника и его полное имя.
Продажи смотреть в таблице Sales.Invoices.
*/
SELECT DISTINCT p.PersonID, p.FullName
FROM Application.People p
WHERE p.IsSalesperson = 1 AND NOT(p.PersonID =  ANY
  (select i.SalespersonPersonID
             from Sales.Invoices i
             where i.InvoiceDate = '20150704' ))



/*
2. Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса.
Вывести: ИД товара, наименование товара, цена.
*/
SELECT s.StockItemID, s.StockItemName, s.UnitPrice
FROM Warehouse.StockItems s
WHERE UnitPrice = (SELECT TOP 1 s2.UnitPrice
                   from Warehouse.StockItems s2
				   ORDER BY s2.UnitPrice ASC)

SELECT s.StockItemID, s.StockItemName, s.UnitPrice
FROM Warehouse.StockItems s
WHERE UnitPrice = (SELECT MIN(s2.UnitPrice)
                   from Warehouse.StockItems s2)

;WITH MinItemPrice (ItemId) AS (SELECT TOP  1 s2.StockItemID FROM Warehouse.StockItems s2  ORDER BY s2.UnitPrice)
SELECT s.StockItemID, s.StockItemName, s.UnitPrice
FROM Warehouse.StockItems s   INNER JOIN  MinItemPrice ON MinItemPrice.ItemId = s.StockItemID


/*
3. Выберите информацию по клиентам, которые перевели компании пять максимальных платежей
из Sales.CustomerTransactions.
Представьте несколько способов (в том числе с CTE).
*/

SELECT top (5) * FROM Sales.CustomerTransactions c
ORDER BY c.TransactionAmount DESC


;WITH top5 as (select top 5 c.CustomerID from Sales.CustomerTransactions c order by c.TransactionAmount desc)
SELECT *
FROM Application.People p
         inner join top5 t on t.CustomerID = p.PersonID

/*
4. Выберите города (ид и название), в которые были доставлены товары,
входящие в тройку самых дорогих товаров, а также имя сотрудника,
который осуществлял упаковку заказов (PackedByPersonID).
*/

SELECT Ci.CityID, Ci.CityName  , o.PickedByPersonID
FROM Sales.OrderLines ol
         inner join (select top 3 si.UnitPrice
                     from Warehouse.StockItems si
                     order by si.UnitPrice desc) topItems on topItems.UnitPrice = ol.UnitPrice
         inner join Sales.Orders O on O.OrderID = ol.OrderID
         inner join Sales.Customers c on O.CustomerID = c.CustomerID
         inner join Application.Cities ci on c.DeliveryCityID = Ci.CityID

---		 WHERE CityName Like 'Zu%'

;with topItems as (select top 3 si.UnitPrice
                     from Warehouse.StockItems si
                     order by si.UnitPrice desc)
select Cities.CityID, Cities.CityName, o.PickedByPersonID 
from Sales.OrderLines ol
         inner join Sales.Orders O on O.OrderID = ol.OrderID
         inner join topItems on topItems.UnitPrice = ol.UnitPrice
         inner join Sales.Customers c on O.CustomerID = c.CustomerID
         inner join Application.Cities on c.DeliveryCityID = Cities.CityID
WHERE CityName Like 'Zu%'
-- ---------------------------------------------------------------------------
-- Опциональное задание
-- ---------------------------------------------------------------------------
-- Можно двигаться как в сторону улучшения читабельности запроса,
-- так и в сторону упрощения плана\ускорения.
-- Сравнить производительность запросов можно через SET STATISTICS IO, TIME ON.
-- Если знакомы с планами запросов, то используйте их (тогда к решению также приложите планы).
-- Напишите ваши рассуждения по поводу оптимизации.

-- 5. Объясните, что делает и оптимизируйте запрос
SELECT Invoices.InvoiceID,
       Invoices.InvoiceDate,
       (SELECT People.FullName
        FROM Application.People
        WHERE People.PersonID = Invoices.SalespersonPersonID)                 AS SalesPersonName,
       SalesTotals.TotalSumm                                                  AS TotalSummByInvoice,
       (SELECT SUM(OrderLines.PickedQuantity * OrderLines.UnitPrice)
        FROM Sales.OrderLines
        WHERE OrderLines.OrderId = (SELECT Orders.OrderId
                                    FROM Sales.Orders
                                    WHERE Orders.PickingCompletedWhen IS NOT NULL
                                      AND Orders.OrderId = Invoices.OrderId)) AS TotalSummForPickedItems
FROM Sales.Invoices
         JOIN
     (SELECT InvoiceId, SUM(Quantity * UnitPrice) AS TotalSumm
      FROM Sales.InvoiceLines
      GROUP BY InvoiceId
      HAVING SUM(Quantity * UnitPrice) > 27000) AS SalesTotals
     ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC

-- --

--Запрос ищет счета выставвленные клиенту, которые превышают сумму 27000
--оотбражает данные по счету, продажнику, общую сумму счета,уже полученные товары клиентом на сумму

-- для улучшение читабельности убраны подзапросы, сложные запросы перемещены в CTE, добавлены псевданимы таблиц
-- для ускорения выполнения убраны подзапросы в select и объеденены 2 запроса на получение данных о общей суммы счета и оплаченного
-- большого прироста производительности не наблиюдается. Ускорение всего на 4%
/*;
with SalesTotals as (SELECT InvoiceId, SUM(Quantity * UnitPrice) AS TotalSumm
                     FROM Sales.InvoiceLines il
                     GROUP BY InvoiceId),
     pickedItemsSum as (SELECT SUM(ol.PickedQuantity * ol.UnitPrice) as pickedTotalSum, ol.OrderId
                        FROM Sales.Orders o
                                 inner join Sales.OrderLines OL on o.OrderID = OL.OrderID
                        where o.PickingCompletedWhen is not null
                        group by ol.OrderID)
SELECT i.InvoiceID,
       i.InvoiceDate,
       p.FullName         AS SalesPersonName,
       st.TotalSumm       AS TotalSummByInvoice,
       pis.pickedTotalSum AS TotalSummForPickedItems
FROM Sales.Invoices i
         inner join SalesTotals st ON st.InvoiceID = i.InvoiceID
         inner join Application.People p on p.PersonID = i.SalespersonPersonID
         inner join pickedItemsSum pis on pis.OrderID = i.OrderID
where st.TotalSumm > 27000
ORDER BY TotalSumm DESC*/


with SalesTotals as (SELECT SUM(ol.PickedQuantity * ol.UnitPrice) as pickedTotalSum,
                            ol.OrderId,
                            SUM(Quantity * UnitPrice)             AS TotalSumm
                     FROM Sales.Orders o
                              inner join Sales.OrderLines OL on o.OrderID = OL.OrderID
                              inner join Sales.Invoices I2 on o.OrderID = I2.OrderID
                     where o.PickingCompletedWhen is not null
                     group by ol.OrderID
                     having SUM(ol.PickedQuantity * ol.UnitPrice) > 27000
                     )
SELECT i.InvoiceID,
       i.InvoiceDate,
       p.FullName        AS SalesPersonName,
       st.TotalSumm      AS TotalSummByInvoice,
       st.pickedTotalSum AS TotalSummForPickedItems
FROM Sales.Invoices i
         inner join Application.People p on p.PersonID = i.SalespersonPersonID
         inner join SalesTotals st on st.OrderID = i.OrderID
--where st.TotalSumm > 27000
ORDER BY TotalSumm DESC