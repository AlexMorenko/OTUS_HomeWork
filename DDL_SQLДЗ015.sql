-- Создать базу данных.
CREATE DATABASE KARAT_TEST;
GO;

USE KARAT_TEST;
GO

CREATE TABLE [dbo].[Karat_Labels](
	[lbId] [int] IDENTITY(1,1) NOT NULL,
	[lbCode_CHAR4] [char](4) NOT NULL,
	[lbCode] [nvarchar](150) NOT NULL,
	[lbMaterial] [nvarchar](150) NOT NULL,
	[lbProducer] [nvarchar](50) NULL,
	[lbType] [char](10) NOT NULL,
	[lbOption] [varchar](50) NULL,
	[lbModLocCode] [char](6) NULL,
	[lbGroup] [char](10) NULL,
	[lbDestinationCode] [char](4) NULL,
	[lbFixedChar] [tinyint] NULL,
	[lbWastedChar] [tinyint] NULL,
	[lbName] [nvarchar](150) NULL,
	[lbParent] [varchar](50) NULL,
	[lbFact_Place] [nvarchar](50) NULL,
	[lbDate] [datetime] NULL,
	[lbStatus] [char](16) NULL,
 CONSTRAINT [PK_Karat_Labels] PRIMARY KEY CLUSTERED 
(
	[lbCode] ASC,
	[lbMaterial] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Karat_Labels] ADD  CONSTRAINT [DF_Karat_Labels_lbMaterial]  DEFAULT (N'КОД') FOR [lbMaterial]
GO
-------------------------------
ALTER TRIGGER [dbo].[trgUpd_KARAT_LABELS]
 ON [KARAT_TEST].[dbo].[Karat_Labels] 	--INSTEAD OF UPDATE
 AFTER     INSERT, DELETE, UPDATE 
AS 
BEGIN
INSERT INTO KARAT_TEST.dbo.Karat_labels_History (
		[lbId]
      ,[lbCode_CHAR4]
      ,[lbCode]
      ,[lbMaterial]
      ,[lbProducer]
      ,[lbType]
      ,[lbOption]
      ,[lbModLocCode]
      ,[lbGroup]
      ,[lbDestinationCode]
      ,[lbFixedChar]
      ,[lbWastedChar]
      ,[lbName]
      ,[lbParent]
      ,[lbFact_Place]
      ,[lbDate]
      ,[lbStatus])
  SELECT 
		[lbId]
      ,[lbCode_CHAR4]
      ,[lbCode]
      ,[lbMaterial]
      ,[lbProducer]
      ,[lbType]
      ,[lbOption]
      ,[lbModLocCode]
      ,[lbGroup]
      ,[lbDestinationCode]
      ,[lbFixedChar]
      ,[lbWastedChar]
      ,[lbName]
      ,[lbParent]
      ,[lbFact_Place]
      ,getDate() --[lbDate]
      ,[lbStatus]
	  FROM 	  inserted

END

-------------------------------

CREATE TABLE [dbo].[Karat_Labels_History](
	[lbhId] [int] IDENTITY(1,1) NOT NULL,
	[lbId] [int] NOT NULL,
	[lbCode_CHAR4] [char](4) NOT NULL,
	[lbCode] [nvarchar](150) NOT NULL,
	[lbMaterial] [nvarchar](150) NULL,
	[lbProducer] [nvarchar](50) NULL,
	[lbType] [char](10) NOT NULL,
	[lbOption] [varchar](50) NULL,
	[lbModLocCode] [char](6) NULL,
	[lbGroup] [char](10) NULL,
	[lbDestinationCode] [char](4) NULL,
	[lbFixedChar] [tinyint] NULL,
	[lbWastedChar] [tinyint] NULL,
	[lbName] [nvarchar](150) NULL,
	[lbParent] [varchar](50) NULL,
	[lbFact_Place] [nvarchar](50) NULL,
	[lbDate] [datetime] NULL,
	[lbStatus] [char](16) NULL,
 CONSTRAINT [PK_Karat_Labels_History] PRIMARY KEY CLUSTERED 
(
	[lbhId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Karat_Labels_History] ADD  CONSTRAINT [DF_Karat_Labels_History_lbCode_CHAR4]  DEFAULT ((0)) FOR [lbCode_CHAR4]
GO

ALTER TABLE [dbo].[Karat_Labels_History] ADD  CONSTRAINT [DF_Karat_Labels_History_lbMaterial]  DEFAULT (N'КОД') FOR [lbMaterial]
GO

ALTER TABLE [dbo].[Karat_Labels_History]  WITH CHECK ADD  CONSTRAINT [FK_Karat_Labels_History_Karat_Labels] FOREIGN KEY([lbCode], [lbMaterial])
REFERENCES [dbo].[Karat_Labels] ([lbCode], [lbMaterial])
GO

ALTER TABLE [dbo].[Karat_Labels_History] CHECK CONSTRAINT [FK_Karat_Labels_History_Karat_Labels]
GO
------------------------------------

---- Представления для проверки ассоциации
CREATE VIEW [dbo].[Karat_VIEW_Labels] AS
  SELECT DISTINCT
		 IIF(a.[lbType]='LOT', a.[lbCode],
		     IIF(b.[lbType]='LOT', b.[lbCode],
			     IIF(c.[lbType]='LOT', c.[lbCode], NULL))) AS lbCodeLOT
		,IIF(b.[lbType]='CST', b.[lbCode],
		     IIF(c.[lbType]='CST', c.[lbCode],
			     IIF(d.[lbType]='CST', d.[lbCode], NULL))) AS lbCodeCST
		,IIF(c.[lbType]='POD', c.[lbCode],
		     IIF(d.[lbType]='POD', d.[lbCode],
			     IIF(e.[lbType]='POD', e.[lbCode], NULL))) AS lbCodePOD
		,IIF(a.[lbType]='LOT', IIF(LEN(a.[lbOption])>4,SUBSTRING(a.[lbOption], 5, LEN(a.[lbOption])-4), a.[lbOption]), 
		     IIF(b.[lbType]='LOT', IIF(LEN(b.[lbOption])>4,SUBSTRING(b.[lbOption], 5, LEN(b.[lbOption])-4), b.[lbOption]),
			     IIF(c.[lbType]='LOT', IIF(LEN(c.[lbOption])>4,SUBSTRING(c.[lbOption], 5, LEN(c.[lbOption])-4), c.[lbOption]), NULL))) AS lbProtocolLOT
		,IIF(b.[lbType]='CST', IIF(LEN(b.[lbOption])>4,SUBSTRING(b.[lbOption], 5, LEN(b.[lbOption])-4), b.[lbOption]), 
		     IIF(c.[lbType]='CST', IIF(LEN(c.[lbOption])>4,SUBSTRING(c.[lbOption], 5, LEN(c.[lbOption])-4), c.[lbOption]),
			     IIF(d.[lbType]='CST', IIF(LEN(d.[lbOption])>4,SUBSTRING(d.[lbOption], 5, LEN(d.[lbOption])-4), d.[lbOption]), NULL))) AS lbProtocolCST
		,IIF(c.[lbType]='POD', IIF(LEN(c.[lbOption])>4,SUBSTRING(c.[lbOption], 5, LEN(c.[lbOption])-4), c.[lbOption]), 
		     IIF(d.[lbType]='POD', IIF(LEN(d.[lbOption])>4,SUBSTRING(d.[lbOption], 5, LEN(d.[lbOption])-4), d.[lbOption]),
			     IIF(e.[lbType]='POD', IIF(LEN(e.[lbOption])>4,SUBSTRING(e.[lbOption], 5, LEN(e.[lbOption])-4), e.[lbOption]), NULL))) AS lbProtocolPOD
	    ,IIF(a.[lbType]='LOT', a.[lbFact_Place],
		     IIF(b.[lbType]='LOT', b.[lbFact_Place],
			     IIF(c.[lbType]='LOT', c.[lbFact_Place], NULL))) AS lbFact_PlaceLOT
	    ,IIF(b.[lbType]='CST', b.[lbFact_Place],
		     IIF(c.[lbType]='CST', c.[lbFact_Place],
			     IIF(d.[lbType]='CST', d.[lbFact_Place], NULL))) AS lbFact_PlaceCST
	    ,IIF(c.[lbType]='POD', c.[lbFact_Place],
		     IIF(d.[lbType]='POD', d.[lbFact_Place],
			     IIF(e.[lbType]='POD', e.[lbFact_Place], NULL))) AS lbFact_PlacePOD

      ,c.[lbCode] AS ClbCode
      ,c.[lbType] AS ClbType
      ,IIF(LEN(c.[lbOption])>4,SUBSTRING(c.[lbOption], 5, LEN(c.[lbOption])-4), c.[lbOption]) AS CProtocol

  FROM   [Karat_TEST].[dbo].[Karat_labels] c 
  LEFT JOIN [Karat_TEST].[dbo].[Karat_labels] d ON d.[LbCode] = c.[LbParent] 
  LEFT JOIN [Karat_TEST].[dbo].[Karat_labels] e ON e.[LbCode] = d.[LbParent] 
  LEFT JOIN [Karat_TEST].[dbo].[Karat_labels] b ON c.[LbCode] = b.[lbParent]
  LEFT JOIN [Karat_TEST].[dbo].[Karat_labels] a ON b.[LbCode] = a.[lbParent]
GO

------------------------------------
CREATE TABLE [dbo].[Karat_Labels_Log](
	[CommandId] [bigint] IDENTITY(1,1) NOT NULL,
	[CommandString] [nvarchar](1024) NULL,
	[CommandDate] [datetime] NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Karat_Labels_Log] ADD  CONSTRAINT [DF_Karat_Labels_Command_History_CommandDate]  DEFAULT (getdate()) FOR [CommandDate]
GO
------------------------------------

--ТАБЛИЦЫ БД MES соответствуют реальным, так как требуется интеграция на уровне БД
CREATE TABLE [dbo].[E_CS_MFDUNIT_CUSTOM](
	[MFDUNIT_ID] [nvarchar](150) NOT NULL,
	[MFD_REF_1] [nvarchar](150) NULL,
	[MFD_REF_2] [nvarchar](150) NULL,
	[MFD_REF_3] [nvarchar](150) NULL,
	[MFD_REF_4] [nvarchar](150) NULL,
	[MFD_REF_5] [nvarchar](150) NULL,
	[MFD_REF_6] [nvarchar](150) NULL,
	[MFD_REF_7] [nvarchar](150) NULL,
	[MFD_REF_8] [nvarchar](150) NULL,
	[MFD_REF_9] [nvarchar](150) NULL,
	[MFD_REF_10] [nvarchar](150) NULL,
	[MFD_REF_11] [nvarchar](150) NULL,
	[MFD_REF_12] [nvarchar](150) NULL,
	[MFD_REF_13] [nvarchar](150) NULL,
	[MFD_REF_14] [nvarchar](150) NULL,
	[MFD_REF_15] [nvarchar](150) NULL,
	[MFD_REF_16] [nvarchar](150) NULL,
	[MFD_REF_17] [nvarchar](150) NULL,
	[MFD_REF_18] [nvarchar](150) NULL,
	[MFD_REF_19] [nvarchar](150) NULL,
	[MFD_REF_20] [nvarchar](150) NULL,
	[MFD_REF_21] [nvarchar](150) NULL,
	[MFD_REF_22] [nvarchar](150) NULL,
	[MFD_REF_23] [nvarchar](150) NULL,
	[MFD_REF_24] [nvarchar](150) NULL,
	[MFD_REF_25] [nvarchar](150) NULL,
	[MFD_REF_26] [nvarchar](150) NULL,
	[MFD_REF_27] [nvarchar](150) NULL,
	[MFD_REF_28] [nvarchar](150) NULL,
	[MFD_REF_29] [nvarchar](150) NULL,
	[MFD_REF_30] [nvarchar](150) NULL,
	[MFD_REF_31] [nvarchar](150) NULL,
	[MFD_REF_32] [nvarchar](150) NULL,
	[MFD_REF_33] [nvarchar](150) NULL,
	[MFD_REF_34] [nvarchar](150) NULL,
	[MFD_REF_35] [nvarchar](150) NULL,
	[MFD_REF_36] [nvarchar](150) NULL,
	[MFD_REF_37] [nvarchar](150) NULL,
	[MFD_REF_38] [nvarchar](150) NULL,
	[MFD_REF_39] [nvarchar](150) NULL,
	[MFD_REF_40] [nvarchar](150) NULL,
	[MFD_REF_41] [nvarchar](150) NULL,
	[MFD_REF_42] [nvarchar](150) NULL,
	[MFD_REF_43] [nvarchar](150) NULL,
	[MFD_REF_44] [nvarchar](150) NULL,
	[MFD_REF_45] [nvarchar](150) NULL,
	[MFD_REF_46] [nvarchar](150) NULL,
	[MFD_REF_47] [nvarchar](150) NULL,
	[MFD_REF_48] [nvarchar](150) NULL,
	[MFD_REF_49] [nvarchar](150) NULL,
	[MFD_REF_50] [nvarchar](150) NULL,
	[MFDUNIT_CUSTOM_IDENT] [bigint] NOT NULL,
	[CUSTOM_ATTR_SEQ_ID] [bigint] NULL,
 CONSTRAINT [PK_E_CS_MFDUNIT_CUSTOM] PRIMARY KEY CLUSTERED 
(
	[MFDUNIT_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
------------------------------------

CREATE TABLE [dbo].[E_CS_OBJECT_DETAILS](
	[OBJECT_TYPE] [nvarchar](150) NOT NULL,
	[OBJECT_ID] [nvarchar](150) NOT NULL,
	[VERSION] [int] NOT NULL,
	[DESCRIPTION] [nvarchar](4000) NULL,
	[FROZEN] [nchar](1) NULL,
	[COST_OVERRIDE] [nchar](1) NULL,
	[CHECKED_OUT] [nchar](1) NULL,
	[CHECKED_OUT_BY] [nvarchar](150) NULL,
	[CREATED_BY] [nvarchar](150) NULL,
	[CREATED_DATE] [datetime] NULL,
	[UPDATED_BY] [nvarchar](150) NULL,
	[UPDATED_DATE] [datetime] NULL,
	[REUSABLE] [nvarchar](4000) NULL,
	[ACTIVE] [nchar](1) NULL,
	[OBSOLETE] [nchar](1) NULL,
	[SEQ_ID] [bigint] NULL,
	[RECNO] [bigint] NULL,
	[ALIAS] [nvarchar](150) NULL,
	[DETAIL_IDENT] [bigint] NOT NULL,
	[ARCHIVE_STATUS] [nchar](1) NULL,
	[ATTR_SEQ_ID] [bigint] NULL,
	[VAR_SEQ_ID] [bigint] NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[E_CS_OBJECT_DETAILS] ADD  CONSTRAINT [DF_E_CS_OBJECT_DETAILS_OBJECT_TYPE]  DEFAULT (N'MFDUNIT') FOR [OBJECT_TYPE]
GO

ALTER TABLE [dbo].[E_CS_OBJECT_DETAILS]  WITH CHECK ADD  CONSTRAINT [FK_E_CS_OBJECT_DETAILS_E_CS_MFDUNIT_CUSTOM] FOREIGN KEY([OBJECT_ID])
REFERENCES [dbo].[E_CS_MFDUNIT_CUSTOM] ([MFDUNIT_ID])
GO

ALTER TABLE [dbo].[E_CS_OBJECT_DETAILS] CHECK CONSTRAINT [FK_E_CS_OBJECT_DETAILS_E_CS_MFDUNIT_CUSTOM]
GO
------------------------------------

CREATE TABLE [dbo].[E_CS_VARIABLE_DETAILS](
	[OBJECT_TYPE] [nvarchar](150) NOT NULL,
	[OBJECT_ID] [nvarchar](150) NOT NULL,
	[VERSION] [int] NOT NULL,
	[VAR_NAME] [nvarchar](150) NOT NULL,
	[VAR_VALUE] [nvarchar](2000) NULL,
	[DESCRIPTION] [nvarchar](128) NULL,
	[VAR_IDENT] [bigint] NOT NULL,
 CONSTRAINT [PK__E_CS_VAR__A4E36CE2742CB603] PRIMARY KEY NONCLUSTERED 
(
	[OBJECT_TYPE] ASC,
	[OBJECT_ID] ASC,
	[VERSION] ASC,
	[VAR_NAME] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[E_CS_VARIABLE_DETAILS]  WITH CHECK ADD  CONSTRAINT [FK_E_CS_VARIABLE_DETAILS_E_CS_MFDUNIT_CUSTOM] FOREIGN KEY([OBJECT_ID])
REFERENCES [dbo].[E_CS_MFDUNIT_CUSTOM] ([MFDUNIT_ID])
GO

ALTER TABLE [dbo].[E_CS_VARIABLE_DETAILS] CHECK CONSTRAINT [FK_E_CS_VARIABLE_DETAILS_E_CS_MFDUNIT_CUSTOM]
GO
------------------------------------------

CREATE TABLE [dbo].[E_CS_MFDUNIT_DETAILS](
	[MFDUNIT_ID] [nvarchar](150) NOT NULL,
	[PRODUCT_ID] [nvarchar](150) NULL,
	[PRODUCT_VERSION] [int] NULL,
	[MATERIAL] [nvarchar](150) NOT NULL,
	[SUB_QTY] [float] NULL,
	[SUB_MATERIAL] [nvarchar](150) NULL,
	[WIP_TYPE] [nvarchar](150) NOT NULL,
	[STATE] [nvarchar](150) NULL,
	[PRIORITY] [int] NULL,
	[RELEASE_DATE] [datetime] NOT NULL,
	[DUE_DATE] [datetime] NOT NULL,
	[NOTIFY_ON_RELEASE] [nchar](1) NULL,
	[NOTIFY_ON_DUE] [nchar](1) NULL,
	[ANY_EXCEPTION] [nchar](1) NULL,
	[CURRENT_POSITION] [nvarchar](2000) NULL,
	[EXCEPTION_POSITION] [nvarchar](2000) NULL,
	[CURRENT_STEP] [nvarchar](150) NULL,
	[CURRENT_STEP_VERSION] [int] NULL,
	[CURRENT_OPERATION] [nvarchar](150) NULL,
	[CURRENT_OPERATION_VERSION] [int] NULL,
	[EXCEPTION_STEP] [nvarchar](150) NULL,
	[EXCEPTION_STEP_VERSION] [int] NULL,
	[EXCEPTION_OPERATION] [nvarchar](150) NULL,
	[EXCEPTION_OPERATION_VERSION] [int] NULL,
	[CHILD_LOT_COUNTER] [int] NULL,
	[CURRENT_MFG_STAGE] [nvarchar](150) NULL,
	[NEXT_STAGE] [nvarchar](150) NULL,
	[SEQ_ID] [bigint] NOT NULL,
	[TRANSITION_RECNO] [bigint] NULL,
	[NEXT_STEP] [nvarchar](150) NULL,
	[NEXT_STEP_VERSION] [int] NULL,
	[PARENT] [nvarchar](150) NULL,
	[SCRAP_COUNT] [float] NULL,
	[IDENT] [nchar](1) NULL,
	[FACILITY_TYPE] [nvarchar](150) NULL,
	[FACILITY] [nvarchar](150) NULL,
	[DEVICE_ID] [nvarchar](150) NULL,
	[DEVICE_RUN_ID] [nvarchar](150) NULL,
	[REF_1] [nvarchar](150) NULL,
	[REF_2] [nvarchar](150) NULL,
	[REF_3] [nvarchar](150) NULL,
	[RECIPE_ID] [nvarchar](150) NULL,
	[RECIPE_VERSION] [int] NULL,
	[BATCH] [nchar](1) NOT NULL,
	[STEP_SEQ_ID] [bigint] NULL,
	[EXCEPTION_STEP_SEQ_ID] [bigint] NULL,
	[EXCEPTION_MFG_STAGE] [nvarchar](150) NULL,
	[REUSABLE] [nvarchar](150) NULL,
	[CASSETTE_ID] [nvarchar](150) NULL,
	[GRADE] [nvarchar](150) NULL,
	[MEASUREMENT_TYPE] [nvarchar](150) NULL,
	[SPLIT_CHILD_COUNTER] [float] NOT NULL,
	[STATETRANSITION] [datetime] NULL,
	[UOM] [nvarchar](150) NULL,
	[DYNAMIC_MFDUNIT] [nchar](1) NULL,
	[CUSTOM_ATTR_SEQ_ID] [bigint] NULL,
	[NEXT_OPERATION] [nvarchar](150) NULL,
	[NEXT_OPERATION_VERSION] [int] NULL,
	[PARENT_TEMP_BATCH] [nvarchar](150) NULL,
	[TEMP_BATCH] [nchar](1) NULL,
	[NON_TRACKABLE] [nchar](1) NULL,
	[SERIAL_NO] [nvarchar](150) NULL,
	[SPLIT_COUNTER] [int] NULL,
	[AUTO_ASSIGNED] [nchar](1) NOT NULL,
	[CRITICAL_RATIO] [float] NULL,
	[RESIDENCY_TIME] [float] NULL,
	[EXPECTED_COMPLETION_DATE] [datetime] NULL,
	[BATCH_SEQ_ID] [bigint] NULL,
	[CLASS_VALUE] [nvarchar](150) NULL,
	[CUSTOM_REF1] [nvarchar](150) NULL,
	[CUSTOM_REF2] [nvarchar](150) NULL,
	[CUSTOM_REF3] [nvarchar](150) NULL,
	[CUSTOM_REF4] [nvarchar](150) NULL,
	[CUSTOM_REF5] [nvarchar](150) NULL,
	[IN_SWR] [nchar](1) NOT NULL,
	[SWR_ID] [nvarchar](150) NULL,
	[TEST_W] [nchar](1) NULL,
	[HAS_ACTIVE_TIMER] [nchar](1) NOT NULL,
	[COMPONENT_SEQ_ID] [bigint] NULL,
	[MOVE_DATE] [datetime] NULL,
	[PHYSICAL_LOCATION] [nvarchar](150) NULL,
	[EARLIEST_TIMER_EXPIRATION] [float] NULL,
	[LAST_TIMER_EXPIRATION] [float] NULL,
	[STEP_ENTRY_TIME] [datetime] NULL,
	[SHIPPABLE] [nchar](1) NULL,
	[SIM_LOT_PRIORITY] [int] NULL,
	[MT_TO_SHIP] [float] NULL,
	[MT_TO_BTLN_STEP] [float] NULL,
	[BTLN_CRITICAL_RATIO] [float] NULL,
	[LOT_RANK_VALUE] [float] NULL,
	[WIP_DELTA] [float] NULL,
	[CST_FLOW_FACTOR] [float] NULL,
	[IPQ] [float] NULL,
	[ACTUAL_MOVES] [float] NULL,
	[CURRENT_WIP] [int] NULL,
	[FAB_COMMIT_DATE] [datetime] NULL,
	[AWAITING_MERGE] [char](1) NULL,
	[PP_POSITION] [nvarchar](2000) NULL,
	[PP_STEP] [nvarchar](150) NULL,
	[PP_STEP_VERSION] [int] NULL,
	[PP_OPERATION] [nvarchar](150) NULL,
	[PP_OPERATION_VERSION] [int] NULL,
	[PP_STEP_SEQ_ID] [bigint] NULL,
	[WAITING] [nchar](1) NULL,
 CONSTRAINT [PK_E_CS_MFDUNIT_DETAILS_1] PRIMARY KEY CLUSTERED 
(
	[MFDUNIT_ID] ASC,
	[MATERIAL] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[E_CS_MFDUNIT_DETAILS]  WITH CHECK ADD  CONSTRAINT [FK_E_CS_MFDUNIT_DETAILS_E_CS_MFDUNIT_CUSTOM] FOREIGN KEY([MFDUNIT_ID])
REFERENCES [dbo].[E_CS_MFDUNIT_CUSTOM] ([MFDUNIT_ID])
GO

ALTER TABLE [dbo].[E_CS_MFDUNIT_DETAILS] CHECK CONSTRAINT [FK_E_CS_MFDUNIT_DETAILS_E_CS_MFDUNIT_CUSTOM]
GO

ALTER TABLE [dbo].[E_CS_MFDUNIT_DETAILS]  WITH CHECK ADD  CONSTRAINT [FK_E_CS_MFDUNIT_DETAILS_Karat_Labels] FOREIGN KEY([MFDUNIT_ID], [MATERIAL])
REFERENCES [dbo].[Karat_Labels] ([lbCode], [lbMaterial])
GO

ALTER TABLE [dbo].[E_CS_MFDUNIT_DETAILS] CHECK CONSTRAINT [FK_E_CS_MFDUNIT_DETAILS_Karat_Labels]
GO
