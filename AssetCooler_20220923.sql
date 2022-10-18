WITH 
AssetSubType AS
(
SELECT 'PC240'  AS AssetSubType, 2500 AS BaseAmount UNION
SELECT 'PC250'  AS AssetSubType, 2500 AS BaseAmount UNION
SELECT 'PC400'  AS AssetSubType, 4000 AS BaseAmount UNION
SELECT 'PC500'  AS AssetSubType, 4000 AS BaseAmount UNION
SELECT 'PC1000' AS AssetSubType, 6000 AS BaseAmount UNION
SELECT 'อื่นๆ'    AS AssetSubType, 4000 AS BaseAmount UNION
SELECT ''       AS AssetSubType, 4000 AS BaseAmount 

),
AssetSubTypeOtherCase AS 
(
SELECT 4000 AS OtherBaseAmount
),
BreakEvenPoint AS
(
SELECT 600 AS BreakEvenPoint
)

SELECT  CO.DateKey
      , CO.BranchCode
	  , CO.RouteCode
	 -- , CO.CustomerCode
	 -- , CO.AssetSubType
	  , SUM(CO.NoOfCooler) AS NoOfCooler
      , CASE WHEN ISNULL(AmountByAsset,0) = 0 THEN '0 บาท'
	         WHEN AmountByAsset < BreakEvenPoint THEN CONCAT('<',BreakEvenPoint,' บาท')
			 WHEN AmountByAsset < ISNULL(BaseAmount,OtherBaseAmount) THEN 'ต่ำเกณฑ์'
	         WHEN AmountByAsset >= ISNULL(BaseAmount,OtherBaseAmount) THEN 'ตามเกณฑ์' 
		END AS CoolerKPI

	 

FROM SCC_AggAssetCoolerYM CO
     LEFT JOIN AssetSubType ST ON CO.AssetSubType = ST.AssetSubType
	 CROSS JOIN AssetSubTypeOtherCase 
	 CROSS JOIN BreakEvenPoint BE
     LEFT JOIN SSC_DimCustomer CU ON CO.CustomerCode = CU.Customer AND CU.HANAFlag = 1
	 LEFT JOIN SSC_DimCustGrp1 CG ON CU.CustGrp1 = CG.CustGrp
	 LEFT JOIN SSC_DimLocation LO ON CO.BranchCode = LO.BranchCode
     LEFT JOIN SSC_DimRoute RO ON CO.RouteCode = RO.Route


WHERE CG.ShopType IN ('FSR','Provision','Other')
      AND SUBSTRING(RouteCode,4,1) NOT IN ('O','R','S','T') 
      AND SUBSTRING((CASE WHEN CO.BranchCode IN (3403,3400) THEN 'A'   -- // Route I Condition
	      ELSE RouteCode END),4,1) <> 'I'                               
      AND NOT (SUBSTRING(RouteCode,4,1) = 'X' AND PxIncludeFlag = 0)    -- // Route PostMix Condition
	--  AND CASE WHEN CO.BranchCode IN (3400,3403,3406) AND RouteCode = '' THEN NULL ELSE RouteCode END IS NOT NULL 
	--  AND CO.BranchCode = 3406
	--  AND CO.DateKey = 20220701

GROUP BY CO.DateKey
      , CO.BranchCode
	  , CO.RouteCode
	--  , CO.CustomerCode
	--  , CO.AssetSubType
	--  , CO.AmountByAsset
      , CASE WHEN ISNULL(AmountByAsset,0) = 0 THEN '0 บาท'
	         WHEN AmountByAsset < BreakEvenPoint THEN CONCAT('<',BreakEvenPoint,' บาท')
			 WHEN AmountByAsset < ISNULL(BaseAmount,OtherBaseAmount) THEN 'ต่ำเกณฑ์'
	         WHEN AmountByAsset >= ISNULL(BaseAmount,OtherBaseAmount) THEN 'ตามเกณฑ์' END

ORDER BY DateKey,CO.BranchCode,ISNULL(RouteCode,''),CoolerKPI;
