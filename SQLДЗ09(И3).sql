/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "10 - Операторы изменения данных".

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
1. Довставлять в базу пять записей используя insert в таблицу Customers или Suppliers
*/
SELECT * FROM Purchasing.Suppliers s

INSERT INTO Purchasing.Suppliers (SupplierID, SupplierName, SupplierCategoryID, PrimaryContactPersonID, AlternateContactPersonID, DeliveryMethodID, DeliveryCityID, PostalCityID, SupplierReference, BankAccountName, BankAccountBranch, BankAccountCode, BankAccountNumber, BankInternationalCode, PaymentDays, InternalComments, PhoneNumber, FaxNumber, WebsiteURL, DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode, DeliveryLocation, PostalAddressLine1, PostalAddressLine2, PostalPostalCode, LastEditedBy)
  VALUES
    (NEXT VALUE FOR Sequences.SupplierID, N'SupplierName1', 2, 21, 22, 7, 38171, 38171, N'', N'', N'', N'', N'', N'', 0, N'', N'', N'', N'', N'', N'', N'', NULL, N'', N'', N'',1)
  , (NEXT VALUE FOR Sequences.SupplierID, N'SupplierName2', 2, 21, 22, 7, 38171, 38171, N'', N'', N'', N'', N'', N'', 0, N'', N'', N'', N'', N'', N'', N'', NULL, N'', N'', N'',1)
  , (NEXT VALUE FOR Sequences.SupplierID, N'SupplierName3', 2, 21, 22, 7, 38171, 38171, N'', N'', N'', N'', N'', N'', 0, N'', N'', N'', N'', N'', N'', N'', NULL, N'', N'', N'',1)
  , (NEXT VALUE FOR Sequences.SupplierID, N'SupplierName4', 2, 21, 22, 7, 38171, 38171, N'', N'', N'', N'', N'', N'', 0, N'', N'', N'', N'', N'', N'', N'', NULL, N'', N'', N'',1)
  , (NEXT VALUE FOR Sequences.SupplierID, N'SupplierName5', 2, 21, 22, 7, 38171, 38171, N'', N'', N'', N'', N'', N'', 0, N'', N'', N'', N'', N'', N'', N'', NULL, N'', N'', N'',1)

/*
2. Удалите одну запись из Customers, которая была вами добавлена
*/
--удаляем SupplierName4
DELETE FROM Purchasing.Suppliers WHERE SupplierID = 20


/*
3. Изменить одну запись, из добавленных через UPDATE
*/

--меняем SupplierName5 на SupplierName6
UPDATE Purchasing.Suppliers SET SupplierName = 'SupplierName6'
WHERE SupplierID = 21
/*
4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть
*/

SELECT * FROM Sales.Customers c
MERGE Sales.Customers c USING (SELECT 1064 AS CustomerId, N'NewCustomerAfterMerge' AS CustomerName) s
ON (c.CustomerID = s.CustomerId)
WHEN MATCHED THEN UPDATE SET c.CustomerName = s.CustomerName
WHEN NOT MATCHED THEN INSERT (CustomerId, CustomerName) VALUES (s.CustomerId, s.CustomerName);

/*
5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert
*/

SELECT * FROM Sales.Orders c
--создать пустую таблицу Sales.Orders2
SELECT * INTO Sales.Orders2 FROM Sales.Orders o WHERE 0=1

-- CMD
bcp WideWorldImporters.Sales.Orders out c:\OTUS\Orders.txt -S otusSqlServer -t"," -c -b1000 -U userName -P mySecuredpassword

BULK INSERT  WideWorldImporters.Sales.Orders2 FROM 'c:\OTUS\Orders.txt'  with ( FIELDTERMINATOR = ',', ROWTERMINATOR = '\n');
SELECT top 1000 * FROM Sales.Orders2 
