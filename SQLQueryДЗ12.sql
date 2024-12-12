/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "12 - Хранимые процедуры, функции, триггеры, курсоры".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

USE WideWorldImporters

/*
Во всех заданиях написать хранимую процедуру / функцию и продемонстрировать ее использование.
*/

/*
1) Написать функцию возвращающую Клиента с наибольшей суммой покупки.
*/

CREATE FUNCTION dbo.CustomerIdMaxSumPrice() RETURNS int
BEGIN RETURN
(SELECT TOP 1 p.CustomerID
FROM (    SELECT c.CustomerID, SUM(il.UnitPrice * il.Quantity) as SumPrice
    FROM [WideWorldImporters].[Sales].[InvoiceLines] il
             INNER JOIN [WideWorldImporters].[Sales].[Invoices]  i  ON il.InvoiceID = i.InvoiceID
			 INNER JOIN [WideWorldImporters].[Sales].[Customers] c ON i.CustomerID = c.CustomerID
                            GROUP BY c.CustomerID)  p
    ORDER BY p.SumPrice DESC);
END;

SELECT dbo.CustomerIdMaxSumPrice() AS CustomerIdMaxSumPrice;

/*
2) Написать хранимую процедуру с входящим параметром СustomerID, выводящую сумму покупки по этому клиенту.
Использовать таблицы :
Sales.Customers
Sales.Invoices
Sales.InvoiceLines
*/

CREATE PROCEDURE [dbo].SPCustomerSumPrice @CustomerId float
AS
BEGIN

    SELECT SUM(il.UnitPrice * il.Quantity) AS SumPrice
    FROM [WideWorldImporters].[Sales].[InvoiceLines] il
             INNER JOIN [WideWorldImporters].[Sales].[Invoices]  i  ON il.InvoiceID = i.InvoiceID
			 INNER JOIN [WideWorldImporters].[Sales].[Customers] c ON i.CustomerID = c.CustomerID
    WHERE c.CustomerID = @CustomerId;

END

EXEC dbo.SPCustomerSumPrice @CustomerId=149;


/*
3) Создать одинаковую функцию и хранимую процедуру, посмотреть в чем разница в производительности и почему.
*/
-- берем процедуру из предыдущего задания и дописываем к ней функцию
CREATE FUNCTION dbo.FuncCustomerSumPrice(@customerId int) RETURNS float
BEGIN RETURN
( SELECT SUM(il.UnitPrice * il.Quantity) as SumPrice
    FROM [WideWorldImporters].[Sales].[InvoiceLines] il
             INNER JOIN [WideWorldImporters].[Sales].[Invoices]  i  ON il.InvoiceID = i.InvoiceID
			 INNER JOIN [WideWorldImporters].[Sales].[Customers] c ON i.CustomerID = c.CustomerID
    WHERE c.CustomerID = @CustomerId)
    END;

    
EXEC SPCustomerSumPrice 149;
    
SELECT dbo.FuncCustomerSumPrice(149);

    -- функция выполняется быстрее из-за того, что не создаются временные таблицы

/*
4) Создайте табличную функцию покажите как ее можно вызвать для каждой строки result set'а без использования цикла.
*/

CREATE FUNCTION FuncTableCustomerSumPrice(@CustomerId int)
 RETURNS @CustomerSumPrice  TABLE  (  SumPrice float ) AS
BEGIN
   INSERT INTO @CustomerSumPrice (SumPrice)
   SELECT SUM(il.UnitPrice * il.Quantity) as SumPrice
    FROM [WideWorldImporters].[Sales].[InvoiceLines] il
             INNER JOIN [WideWorldImporters].[Sales].[Invoices]  i  ON il.InvoiceID = i.InvoiceID
			 INNER JOIN [WideWorldImporters].[Sales].[Customers] c ON i.CustomerID = c.CustomerID
    WHERE c.CustomerID = @CustomerId;
RETURN;
END;


SELECT c.CustomerID, t.SumPrice
FROM Sales.Customers c
         CROSS APPLY dbo.FuncTableCustomerSumPrice(c.CustomerID) t 
ORDER BY 2 DESC	;

/*
5) Опционально. Во всех процедурах укажите какой уровень изоляции транзакций вы бы использовали и почему.
*/
