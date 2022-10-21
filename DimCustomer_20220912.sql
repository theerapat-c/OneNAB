SELECT 0 AS HANAFlag 
	  ,'' AS [OldCustomer]
      ,[Customer]
      ,[CustomerDesc]
      ,CONCAT([Customer],' - ', [CustomerDesc]) AS [CustomerDescription]
     -- ,CAST([CustType] AS varchar) AS [CustType]
	  , CASE WHEN CustType = 0 THEN 'Customer store' WHEN CustType = 1 THEN 'Employee store' END AS CustType
      ,[Consent]
      ,[ConsentDate]
      ,NULL AS [VP]
      ,[CustAdj]
      ,NULL AS [CustAdjDesc]
      ,NULL AS [CustAdjDescription]
      ,[SpecialGrp1]
      ,[SpecialGrp2]
      ,[BillSubDistrict]
      ,[BillDistrict]
      ,[BillProvince]
      ,[BillZipCode]
      ,[WorkSubDistrict]
      ,[WorkDistrict]
      ,[WorkProvince]
      ,[WorkZipCode]
      ,[LONGITUDE]
      ,[LATITUDE]
      ,[CustGrp1]
      ,NULL AS [CustGroup]
      ,[ThaiBevGroup]
      ,[TaxNo]
      ,NULL AS [FirstBillingDate]
      ,NULL AS [FirstBillingMonth]
      ,NULL AS [FirstBillingYear]
      ,[ETLLoadData]
	  ,GETDATE() AS PYLoadDate
FROM [STAGE].[dbo].[SSC_DimCustomerOld]

UNION ALL

SELECT  1 AS HANAFlag 
	  ,[OldCustomer]
      ,[Customer]
      ,[CustomerDesc]
      ,[CustomerDescription]
      ,[CustType]
      ,[Consent]
      ,[ConsentDate]
      ,[VP]
      ,[CustAdj]
      ,[CustAdjDesc]
      ,[CustAdjDescription]
      ,[SpecialGrp1]
      ,[SpecialGrp2]
      ,[BillSubDistrict]
      ,[BillDistrict]
      ,[BillProvince]
      ,[BillZipCode]
      ,[WorkSubDistrict]
      ,[WorkDistrict]
      ,[WorkProvince]
      ,[WorkZipCode]
      ,[LONGITUDE]
      ,[LATITUDE]
      ,[CustGrp1]
      ,[CustGroup]
      ,[ThaiBevGroup]
      ,[TaxNo]
      ,[FirstBillingDate]
      ,[FirstBillingMonth]
      ,[FirstBillingYear]
      ,[ETLLoadData]
	  ,GETDATE() AS PYLoadDate
  FROM [STAGE].[dbo].[SSC_DimCustomer]



