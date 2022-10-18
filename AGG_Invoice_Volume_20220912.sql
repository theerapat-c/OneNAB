WITH 
CF_ReasonCode AS
(
SELECT ReasonCode
FROM SSC_DimReason
WHERE LEFT(ReasonCode,1) <> '6' 
      AND ReasonCode NOT IN (413,451,453,465,470,482,491,493)
	-- AND ReasonCode NOT IN (SELECT Value1 FROM TEST_CONFIGTABLE WHERE Category = 'ReasonCode' AND ActiveStatus = 1)
),

LastDayOfMonth AS
(
SELECT  MAX(DateKey) AS LastDayOfMonth
FROM SSC_FactAllDataInvoice
GROUP BY YM
)

SELECT  HANAFlag
      , CONCAT(INV.YM,'01') AS DateKey
      , INV.Branch AS BranchCode
	  , INV.Route AS RouteCode
	  , Salesman
	  , ChannelMarge AS ChannelSalesOffice
	  , Customer AS CustomerCode
	  , DataSource AS DataSource 
	  , BasicMaterial  AS BasicMaterial 
	  , BrandDesc
	  , CASE WHEN BrandDesc = 'Crystal' THEN  'Crystal'
	         WHEN BrandDesc = 'Est' THEN  'Est'
			 WHEN BrandDesc = 'Oishi' THEN  'Oishi'
			 WHEN BrandDesc = 'Wrangyer' THEN  'Wrangyer' 
			 ELSE 'Other Brand' END AS Brand
	  , MatType1
	  , BType AS BillType
	  , SUM(SoldSingle) AS SoldSingle
	  , SUM(SoldCase) AS SoldCase
	  , SUM(CASE WHEN LD.LastDayOfMonth IS NOT NULL THEN SoldCase ELSE 0 END) AS SoldCaseLastDay
	  , SUM(SoldBaseQty) AS SoldBaseQty
	  , SUM((SoldBaseQty * Millilitre)/1000) AS SoldLitre
	  , SUM(FreeSingle) AS FreeSingle
	  , SUM(FreeCase) AS FreeCase
	  , SUM(CASE WHEN LD.LastDayOfMonth IS NOT NULL THEN FreeCase ELSE 0 END) AS FreeCaseLastDay
	  , SUM(FreeBaseQty) AS FreeBaseQty
	  , SUM((FreeBaseQty * Millilitre)/1000) AS FreeLitre
      , SUM(NetItemAmt) AS NetItemAmt
	  , SUM(VatAmt) AS VatAmt
	  , SUM(TotalAmt) AS TotalAmount
	  , SUM(Discount) AS Discount
	  , GETDATE() AS PYLoadDate

-- DROP TABLE TEST_AggInvVolByBrandYM
-- INTO TEST_AggInvVolByBrandYM
-- SELECT *

FROM SSC_FactAllDataInvoice INV
     INNER JOIN CF_ReasonCode CR ON INV.ReasonCode = CR.ReasonCode
     LEFT JOIN SSC_DimMaterial MT ON INV.Material = MT.Material
	 LEFT JOIN LastDayOfMonth LD ON INV.DateKey = LD.LastDayOfMonth

WHERE MaterialType = 'Z31' AND MatType1Id IN (1,8) AND PackagingType IN ('NR','RB') AND GroupPostMix <> 'PostMix'
	  -- AND YM = '202207'  AND Branch = '3402'

GROUP BY HANAFlag, CONCAT(YM,'01'), Branch, Route, Salesman, Customer, ChannelMarge, DataSource, BType, BasicMaterial, MatType1,BrandDesc
       , CASE WHEN BrandDesc = 'Crystal' THEN  'Crystal'
	          WHEN BrandDesc = 'Est' THEN  'Est'
			  WHEN BrandDesc = 'Oishi' THEN  'Oishi'
		 	  WHEN BrandDesc = 'Wrangyer' THEN  'Wrangyer' 
			  ELSE 'Other Brand' END 
ORDER BY CONCAT(YM,'01'), Branch, Route, Salesman, Customer, ChannelMarge, DataSource, BasicMaterial

