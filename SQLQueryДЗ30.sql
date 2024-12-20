-- оригинальный запрос
Select ord.CustomerID, det.StockItemID, SUM(det.UnitPrice), SUM(det.Quantity), COUNT(ord.OrderID)    
FROM Sales.Orders AS ord
    JOIN Sales.OrderLines AS det
        ON det.OrderID = ord.OrderID
    JOIN Sales.Invoices AS Inv 
        ON Inv.OrderID = ord.OrderID
    JOIN Sales.CustomerTransactions AS Trans
        ON Trans.InvoiceID = Inv.InvoiceID
    JOIN Warehouse.StockItemTransactions AS ItemTrans
        ON ItemTrans.StockItemID = det.StockItemID
WHERE Inv.BillToCustomerID != ord.CustomerID
    AND (Select SupplierId
         FROM Warehouse.StockItems AS It
         Where It.StockItemID = det.StockItemID) = 12
    AND (SELECT SUM(Total.UnitPrice*Total.Quantity)
        FROM Sales.OrderLines AS Total
            Join Sales.Orders AS ordTotal
                On ordTotal.OrderID = Total.OrderID
        WHERE ordTotal.CustomerID = Inv.CustomerID) > 250000
    AND DATEDIFF(dd, Inv.InvoiceDate, ord.OrderDate) = 0
GROUP BY ord.CustomerID, det.StockItemID
ORDER BY ord.CustomerID, det.StockItemID


-- оптимизированный запрос
-- заменяем запросы из блока условий в join
-- вместо подзапроса в условии использован Exists, а так же Having для фильтрации в группировке
-- отказ от функций Даты 
-- отказ join таблицы (CustomerTransactions)

SELECT ord.CustomerID,
       det.StockItemID,
       SUM(det.UnitPrice),
       SUM(det.Quantity) ,
       COUNT(ord.OrderID)
FROM Sales.Orders AS ord   JOIN Sales.OrderLines AS det      ON det.OrderID = ord.OrderID
         JOIN Sales.Invoices AS Inv      ON Inv.OrderID = ord.OrderID
         JOIN Warehouse.StockItemTransactions AS ItemTrans   ON ItemTrans.StockItemID = det.StockItemID
JOIN Warehouse.StockItems si ON det.StockItemID = si.StockItemID
WHERE Inv.BillToCustomerID != ord.CustomerID
  AND si.SupplierID = 12 
  AND exists (SELECT ordtotal.CustomerID     FROM Sales.OrderLines AS Total      JOIN Sales.Orders AS ordTotal    ON ordTotal.OrderID = Total.OrderID
       WHERE ordTotal.CustomerID = Inv.CustomerID       GROUP BY ordtotal.CustomerID       HAVING SUM(Total.UnitPrice * Total.Quantity)  > 250000)
  AND inv.InvoiceDate = ord.OrderDate
GROUP BY ord.CustomerID, det.StockItemID
ORDER BY ord.CustomerID, det.StockItemID