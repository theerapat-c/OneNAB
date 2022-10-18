SELECT 0 AS HANAFlag
      ,[Branch]
      ,LEFT([YM],6) AS YM
	  ,FORMAT([BillingDate],'yyyyMMdd') AS DateKey
      ,[BillingDate]
      ,[Route]
      ,CASE WHEN Channel IN (10,11,12,13) THEN 72 
	        WHEN Channel = 14 THEN 10
	        WHEN Channel = 20 THEN 10
			WHEN Channel = 90 THEN 60
			ELSE Channel
			END AS Channel
      ,CASE WHEN Channel = 10 THEN 2
	        WHEN Channel = 11 THEN 4 
			WHEN Channel = 12 THEN 7 
			WHEN Channel = 13 THEN 6
			WHEN Channel IN (14,20,90) THEN 0 
	        END AS [ChannelVSMS]
      ,CASE WHEN Channel = 10 THEN 72310102
	        WHEN Channel = 11 THEN 72310304
			WHEN Channel = 12 THEN 72310407 
			WHEN Channel = 13 THEN 72310506 
			WHEN Channel = 14 THEN 10312200 
			WHEN Channel = 20 THEN 10000000
			WHEN Channel = 90 THEN 60000000 
	        END AS [ChannelMarge]
      ,CASE WHEN Channel = 10 THEN 3101 
	        WHEN Channel = 11 THEN 3103
			WHEN Channel = 12 THEN 3104 
			WHEN Channel = 13 THEN 3105 
			WHEN Channel = 14 THEN 3122
			WHEN Channel IN (20,90) THEN 0
	        END AS [SalesOffice]
      ,[BType]
      ,[Salesman]
      ,[Customer]
      ,[Documents]
      ,ISNULL(MT.[Material],OLD.Material) AS Material
      ,SoldBaseQty/(ISNULL(MN.CubeConvert,MO.PackageQty)) AS SoldCase
      ,[SoldSingle]
      ,[SoldBaseQty]
      ,FreeBaseQty/(ISNULL(MN.CubeConvert,MO.PackageQty)) AS FreeCase
      ,[FreeSingle]
      ,[FreeBaseQty]
      ,[NetItemAmt]
      ,[VatAmt]
      ,[TotalAmt]
      ,[Discount]
      ,[SoldTo]
      ,[BillTo]
      ,[Payer]
      ,[ShipTo]
      ,[DataSource]
      ,CASE WHEN [PromotionCode] = '-' THEN '' ELSE PromotionCode END [PromotionCode]
      ,CASE WHEN [ReasonCode] = '-' THEN '' ELSE ReasonCode END [ReasonCode]
      ,[DOCUMENT_NUMBER]
      ,NULL AS [VL]
	  ,OLD.ETLLoadData
	  ,GETDATE() AS PYLoadDate

FROM [STAGE].[dbo].[SSC_DataInvoiceOld] OLD
	 LEFT JOIN SSC_DimMaterial MT ON OLD.Material = MT.OldMaterial
	 LEFT JOIN SSC_DimMaterial MN ON OLD.Material = MN.Material
	 LEFT JOIN SSC_DimMaterialOld MO ON OLD.Material = MO.Material

UNION ALL

SELECT 1 AS HANAFlag
      ,[Branch]
      ,[YM]
	  ,FORMAT([BillingDate],'yyyyMMdd') AS DateKey
      ,[BillingDate]
      ,[Route]
      ,[Channel]
      ,[ChannelVSMS]
      ,[ChannelMarge]
      ,[SalesOffice]
      ,[BType]
      ,[Salesman]
      ,[Customer]
      ,[Documents]
      ,NEW.[Material]
      ,SoldBaseQty/CubeConvert AS SoldCase
      ,[SoldSingle]
      ,[SoldBaseQty]
      ,FreeBaseQty/CubeConvert AS FreeCase
      ,[FreeSingle]
      ,[FreeBaseQty]
      ,[NetItemAmt]
      ,[VatAmt]
      ,[TotalAmt]
      ,[Discount]
      ,[SoldTo]
      ,[BillTo]
      ,[Payer]
      ,[ShipTo]
      ,[DataSource]
      ,[PromotionCode]
      ,[ReasonCode]
      ,[DOCUMENT_NUMBER]
      ,[VL]
	  ,NEW.ETLLoadData
	  ,GETDATE() AS PYLoadDate

FROM [STAGE].[dbo].[SSC_DataInvoice] NEW
     LEFT JOIN SSC_DimMaterial MAT ON NEW.Material = MAT.Material
