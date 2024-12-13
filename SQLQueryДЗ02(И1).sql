/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, JOIN".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД WideWorldImporters можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------


USE WideWorldImporters

/*
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/

SELECT StockItemID, StockItemName
FROM Warehouse.StockItems
WHERE StockItemName like 'Animal%' OR StockItemName like '%urgent%'
  


/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/
SELECT ps.SupplierID, ps.SupplierName
FROM Purchasing.Suppliers ps LEFT JOIN Purchasing.PurchaseOrders ppo ON ps.SupplierID = ppo.SupplierID
WHERE ppo.PurchaseOrderID IS NULL

/*
3. Заказы (Orders) с ценой товара (UnitPrice) более 100$ 
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ
* название месяца, в котором был сделан заказ
* номер квартала, в котором был сделан заказ
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.

Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).

Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/


SELECT so.OrderID,
       OrderDate,
       CONVERT(NVARCHAR(12), OrderDate, 104)    as 'Дата заказа',
       FORMAT(OrderDate, 'MMMM', 'ru-ru') as 'Название месяца',
       DATEPART(Quarter, OrderDate)       as 'Номер квартала',
       (MONTH(OrderDate)-1) / 4 + 1         as 'Треть года',
       CustomerName 
FROM Sales.Orders so
         INNER JOIN Sales.OrderLines sOL on so.OrderID = sOL.OrderID
         INNER JOIN Sales.Customers sC on sC.CustomerID = so.CustomerID
WHERE so.PickingCompletedWhen IS NOT NULL AND 
(UnitPrice > 100  OR Quantity > 20)
ORDER BY 5, 6, 3

SELECT so.OrderID,
       OrderDate,
       CONVERT(NVARCHAR(12), OrderDate, 104)    as 'Дата заказа',
       FORMAT(OrderDate, 'MMMM', 'ru-ru') as 'Название месяца',
       DATEPART(Quarter, OrderDate)       as 'Номер квартала',
       (MONTH(OrderDate)-1) / 4 + 1         as 'Треть года',
       CustomerName 
FROM Sales.Orders so
         INNER JOIN Sales.OrderLines sOL on so.OrderID = sOL.OrderID
         INNER JOIN Sales.Customers sC on sC.CustomerID = so.CustomerID
WHERE so.PickingCompletedWhen IS NOT NULL AND 
(UnitPrice > 100  OR Quantity > 20)
ORDER BY 5, 6, 3
OFFSET 1000 rows FETCH NEXT 100 rows only


/*
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)

Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

SELECT aDM.DeliveryMethodName, pPO.ExpectedDeliveryDate, ps.SupplierName, ap.FullName AS ContactPerson
FROM Purchasing.Suppliers ps
     INNER JOIN Purchasing.PurchaseOrders pPO on ps.SupplierID = pPO.SupplierID
      INNER JOIN Application.People ap on pPO.ContactPersonID = ap.PersonID
       INNER JOIN Application.DeliveryMethods aDM on aDM.DeliveryMethodID = ps.DeliveryMethodID
WHERE YEAR(pPO.ExpectedDeliveryDate) = 2013 AND MONTH(pPO.ExpectedDeliveryDate) = 1
  AND aDM.DeliveryMethodName in ('Air Freight', 'Refrigerated Air Freight')
  AND pPO.IsOrderFinalized = 1


/*
5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
*/
SELECT TOP 10 sC.CustomerName, aP.FullName
FROM Sales.Orders sO INNER JOIN Sales.Customers sC on sC.CustomerID = sO.CustomerID
         INNER JOIN Application.People aP on sO.SalespersonPersonID = aP.PersonID
ORDER BY OrderDate DESC


/*
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems.
*/

SELECT DISTINCT sC.CustomerID, sC.CustomerName, sC.PhoneNumber
FROM Sales.Orders so INNER JOIN Sales.OrderLines OL on so.OrderID = OL.OrderID
        INNER JOIN Sales.Customers sC on sC.CustomerID = so.CustomerID
         INNER JOIN Warehouse.StockItems SI on SI.StockItemID = OL.StockItemID
WHERE SI.StockItemName = 'Chocolate frogs 250g'
