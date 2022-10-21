WITH 
AssetType AS
(
SELECT YM, Customer, AssetSubType ,COUNT(*) AS NoOfCooler
FROM SSC_FactDataAsset
WHERE AssetType = 'ตู้แช่'
GROUP BY YM, Customer, AssetSubType
),

InvoiceAmount AS
(
SELECT  DateKey
	  , CustomerCode
	  , SUM(TotalAmount) AS TotalAmount
	   
FROM [dbo].[SCC_AggInvVolByBrandYM] INV  

WHERE  ISNULL(BrandDesc,'0') <> 'F&N'
GROUP BY DateKey, CustomerCode
),

TotalAssetAmount AS
(
SELECT  DA.YM
      , ISNULL(DA.BranchByVP, DA.BranchByAsset) AS BranchCode
	  , DA.VPRoute AS RouteCode
	  , DA.Customer AS CustomerCode
	  , COUNT(*) AS TotalCooler
	  , MAX(TotalAmount) AS TotalAmount
	  , MAX(TotalAmount)/ COUNT(*) AS AmountPerCooler

FROM SSC_FactDataAsset DA
     LEFT JOIN InvoiceAmount INV ON DA.YM = LEFT(DateKey,6) AND DA.Customer = INV.CustomerCode 
 
WHERE AssetType = 'ตู้แช่'

GROUP BY DA.YM
      , ISNULL(DA.BranchByVP, DA.BranchByAsset)
	  , DA.VPRoute, DA.Customer -- , AST.AssetSubType,AST.NoOfCooler
)


SELECT  CONCAT(TAA.YM,'01') AS DateKey
      , BranchCode
	  , ISNULL(RouteCode,'') AS RouteCode
	  , CustomerCode
	  , AssetSubType
	  , NoOfCooler
	  , AmountPerCooler * NoOfCooler AS AmountByAsset
	  , GETDATE() AS  PYLoadDate

-- INTO TEST_AggAssetCoolerYM

FROM TotalAssetAmount TAA
     LEFT JOIN AssetType AST ON TAA.YM = AST.YM AND TAA.CustomerCode = AST.Customer

--	 WHERE BranchCode = 3406 AND TAA.YM = 202207



ORDER BY CONCAT(TAA.YM,'01') 
      , BranchCode
	  , ISNULL(RouteCode,'')

