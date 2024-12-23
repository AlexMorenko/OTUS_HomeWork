/****** Скрипт для команды SelectTopNRows из среды SSMS  ******/
ALTER DATABASE [KARAT_TEST] ADD FILEGROUP YearData

ALTER DATABASE [KARAT_TEST] ADD FILE (
    NAME = N'Years',
    FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\YearData.ndf',
    SIZE = 200000 KB, FILEGROWTH = 60000 KB) TO FILEGROUP YearData


CREATE PARTITION FUNCTION fnYearPartition (Date)
    AS RANGE RIGHT FOR VALUES (  '20240101', '20250101')


CREATE PARTITION SCHEME schYearPartition AS PARTITION fnYearPartition ALL TO ( [YearData] )

-- ДАННЫЕ
CREATE TABLE TransactionPartitionedT(
	[lbId] [int]  NOT NULL,
    [Date]   DATE NOT NULL,
	[lbCode] [nvarchar](150) NOT NULL
 )
 ON schYearPartition
(
    [Date]
)


-- СЕКЦИОНИРОВАНИЕ
ALTER TABLE [TransactionPartitionedT]
    ADD CONSTRAINT pk_TransctionT PRIMARY KEY CLUSTERED ([Date]) ON schYearPartition ([Date])

--  ВВОД ДАННЫХ
INSERT INTO dbo.TransactionPartitionedT
VALUES (1, '20220201', 'CJ1')
INSERT INTO dbo.TransactionPartitionedT
VALUES (2, '20230201', 'CJ2')
INSERT INTO dbo.TransactionPartitionedT
VALUES (4, '20230601', 'BOPC21')
INSERT INTO dbo.TransactionPartitionedT
VALUES (5, '20240201', 'XX1')
INSERT INTO dbo.TransactionPartitionedT
VALUES (6, '20250201', 'ABC')
INSERT INTO dbo.TransactionPartitionedT
VALUES (7, '20260201', 'BM2')

-- проверка секционирования
SELECT $PARTITION.fnYearPartition([Date]) AS Partition,    COUNT(*) AS countRows,    min([Date]), max([Date])
FROM TransactionPartitionedT tpt
GROUP BY $PARTITION.fnYearPartition(tpt.[Date])
ORDER BY PARTITION

ALTER PARTITION SCHEME schYearPartition
NEXT USED [PRIMARY];

-- НОВАЯ СЕКЦИЯ 
ALTER PARTITION FUNCTION fnYearPartition() split RANGE ('20200201')

INSERT INTO dbo.TransactionPartitionedT
VALUES (8, '20180201', 'D1F')
INSERT INTO dbo.TransactionPartitionedT
VALUES (9, '200201', 'VM0')



-- АРХИВ
create TABLE TransactionPartitionedTA
(
	[lbId] [int]  NOT NULL,
    [Date]   DATE NOT NULL,
	[lbCode] [nvarchar](150) NOT NULL
 )
 ON schYearPartition
(
    [Date]
)



ALTER TABLE TransactionPartitionedTA
    ADD CONSTRAINT pk_TransctionTA PRIMARY KEY CLUSTERED ([Date])  ON schYearPartition ([Date])

--перенос секции в архивную таблицу
ALTER TABLE dbo.TransactionPartitionedT SWITCH PARTITION 1 TO dbo.TransactionPartitionedTableA PARTITION 1
-- проверка наличия данных
SELECT * from TransactionPartitionedTA tpta

ALTER PARTITION SCHEME schYearPartition
NEXT USED [PRIMARY];

-- добавление новой секции 
alter PARTITION FUNCTION fnYearPartition() SPLIT RANGE ('20270101')
