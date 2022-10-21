WITH 

CF_Channel AS
(
SELECT ChannelMarge
FROM SSC_DimChannel
WHERE SalesOfficeDesc IN ('Direct Sales','Presales','Online','Post-Mix','Vending')
     -- SalesOfficeDesc IN ( SELECT Value1 FROM TEST_CONFIGTABLE WHERE Category = 'ChannelSalesOffice' AND ActiveStatus = 1)
),

CF_ReasonCode AS
(
SELECT ReasonCode
FROM SSC_DimReason
WHERE LEFT(ReasonCode,1) <> '6' 
      AND ReasonCode NOT IN (413,451,453,465,470,482,491,493)
	-- AND ReasonCode NOT IN (SELECT Value1 FROM TEST_CONFIGTABLE WHERE Category = 'ReasonCode')
),

TotalOutlet AS
(
SELECT FORMAT(DATEADD(MONTH,+1,(CONVERT(date, CONCAT(YM,'01')))),'yyyyMM') AS YM, Branch, Route,ShopType
	 , COUNT(DISTINCT VP.CUSTOMER)  AS TotalOutlet

FROM SSC_FactCustPerMonPlan VP
     LEFT JOIN SSC_DimCustomer CU ON HANAFlag = 1 AND VP.Customer = CU.Customer
	 LEFT JOIN SSC_DimCustGrp1 CG ON CU.CustGrp1 = CG.CustGrp

GROUP BY FORMAT(DATEADD(MONTH,+1,(CONVERT(date, CONCAT(YM,'01')))),'yyyyMM'),Branch,Route,ShopType
),

ActiveCustomer AS
(
SELECT  YM,INV.Customer,ShopType, PackagingType,Branch
      , CASE WHEN BrandDesc = 'Crystal' THEN  'Crystal'
	         WHEN BrandDesc = 'Est' THEN  'Est'
			 WHEN BrandDesc = 'Oishi' THEN  'Oishi'
			 WHEN BrandDesc = 'Wrangyer' THEN  'Wrangyer' 
			 ELSE 'Other Brand' END AS Brand
	  
FROM SSC_FactAllDataInvoice INV 
     INNER JOIN CF_ReasonCode CR ON INV.ReasonCode = CR.ReasonCode
	 INNER JOIN CF_Channel CC ON INV.ChannelMarge = CC.ChannelMarge
	 LEFT JOIN SSC_DimMaterial MT ON INV.Material = MT.Material 
	 LEFT JOIN SSC_DimCustomer CU ON INV.HANAFlag = CU.HANAFlag AND INV.Customer = CU.Customer
	 LEFT JOIN SSC_DimCustGrp1 CG ON CU.CustGrp1 = CG.CustGrp
	
WHERE BType = 'TaxInv'
      AND MaterialType = 'Z31' AND MatType1Id IN (1,8) AND PackagingType IN ('NR','RB') AND GroupPostMix <> 'PostMix'
	  AND ShopType NOT IN ('CVM','Employee') AND CU.SpecialGrp1 IN ('','Other') 
	  AND LEFT(INV.Customer,1) <> 'E' AND CustGrp NOT IN ('-2','131')

GROUP BY YM,INV.Customer,ShopType,PackagingType,Branch
       ,CASE WHEN BrandDesc = 'Crystal' THEN  'Crystal'
	         WHEN BrandDesc = 'Est' THEN  'Est'
			 WHEN BrandDesc = 'Oishi' THEN  'Oishi'
			 WHEN BrandDesc = 'Wrangyer' THEN  'Wrangyer' 
			 ELSE 'Other Brand' END
),

BrandOutlet AS
(
SELECT  CONCAT(YM,'01') AS DateKey
      , Branch AS BranchCode
	  , ISNULL(INV.VL,'') AS RouteCode
	  , ShopType
	  , COUNT(DISTINCT (CASE WHEN BrandDesc = 'Est' THEN INV.Customer END)) AS EstActiveOutletVL
	  , COUNT(DISTINCT (CASE WHEN BrandDesc = 'Crystal' THEN INV.Customer END))  AS CrystalActiveOutletVL
	  , COUNT(DISTINCT (CASE WHEN BrandDesc = 'Oishi' THEN INV.Customer END)) AS OishiActiveOutletVL
	  , COUNT(DISTINCT (CASE WHEN BrandDesc = 'Wrangyer' THEN INV.Customer END)) AS WrangyerActiveOutletVL
	  , COUNT(DISTINCT (CASE WHEN CG.ShopType = 'FSR' AND PackagingType = 'RB' THEN INV.Customer END)) AS FSRRBActiveOutletVL
	  , COUNT(DISTINCT INV.Customer) AS ActiveBrandOutletVL
	  , COUNT(DISTINCT CONCAT(INV.Customer,BrandDesc)) AS NoOfBrandOutletVL
	
FROM SSC_FactAllDataInvoice INV  
     INNER JOIN CF_Channel CC ON INV.ChannelMarge = CC.ChannelMarge
	 LEFT JOIN SSC_DimMaterial MT ON INV.Material = MT.Material 
	 LEFT JOIN SSC_DimChannel CH ON INV.ChannelMarge = CH.ChannelMarge
	 LEFT JOIN SSC_DimCustomer CU ON INV.HANAFlag = CU.HANAFlag AND INV.Customer = CU.Customer
	 LEFT JOIN SSC_DimCustGrp1 CG ON CU.CustGrp1 = CG.CustGrp
	
WHERE BType = 'TaxInv'
      AND MaterialType = 'Z31' AND MatType1Id IN (1,8) AND PackagingType IN ('NR','RB') AND GroupPostMix <> 'PostMix'
      AND ReasonCode = ''
	  AND ShopType NOT IN ('CVM','Employee') AND CU.SpecialGrp1 IN ('','Other') 
	  AND LEFT(INV.Customer,1) <> 'E' AND CustGrp NOT IN ('-2','131')
	  
GROUP BY YM, Branch, ISNULL(INV.VL,''),ShopType
),

ActiveOutlet AS
(
SELECT  CONCAT(COALESCE(VP.YM,OL.YM,INV.YM),'01') AS DateKey
      , COALESCE(VP.Branch,OL.Branch,INV.Branch) AS BranchCode
	  , CASE WHEN VP.Customer IS NOT NULL THEN ISNULL(VP.Route,OL.Route) ELSE '' END AS RouteCode, INV.ShopType
	  , MAX(TotalOutlet) AS TotalOutletVP  
	  , COUNT(DISTINCT INV.Customer) AS ActiveOutletVP

FROM SSC_FactCustPerMonPlan VP    
     LEFT JOIN SSC_DimCustomer CU ON HANAFlag = 1 AND VP.Customer = CU.Customer
	 FULL JOIN ActiveCustomer INV ON VP.YM = INV.YM AND INV.Customer = VP.Customer  
	 FULL JOIN TotalOutlet OL ON VP.YM = OL.YM AND VP.Branch = OL.Branch AND VP.Route = OL.Route AND INV.ShopType = OL.ShopType

WHERE INV.ShopType IS NOT NULL OR OL.ShopType IS NOT NULL

GROUP BY CONCAT(COALESCE(VP.YM,OL.YM,INV.YM),'01')
       , COALESCE(VP.Branch,OL.Branch,INV.Branch)
	   , CASE WHEN VP.Customer IS NOT NULL THEN ISNULL(VP.Route,OL.Route) ELSE '' END, INV.ShopType

),

MergeDimension AS
(
SELECT DateKey,BranchCode,RouteCode,ShopType FROM ActiveOutlet
UNION
SELECT DateKey,BranchCode,RouteCode,ShopType FROM BrandOutlet
)

SELECT MAIN.DateKey, MAIN.BranchCode, MAIN.RouteCode,MAIN.ShopType
     , TotalOutletVP
	 , ActiveOutletVP
	 , EstActiveOutletVL
	 , CrystalActiveOutletVL
	 , OishiActiveOutletVL
	 , WrangyerActiveOutletVL
	 , FSRRBActiveOutletVL
	 , ActiveBrandOutletVL
	 , NoOfBrandOutletVL
	 , GETDATE() AS PYLoadDate

FROM MergeDimension MAIN
     LEFT JOIN ActiveOutlet AO ON MAIN.DateKey = AO.DateKey AND MAIN.BranchCode = AO.BranchCode AND MAIN.RouteCode = AO.RouteCode AND MAIN.ShopType = AO.ShopType
	 LEFT JOIN BrandOutlet BO  ON MAIN.DateKey = BO.DateKey AND MAIN.BranchCode = BO.BranchCode AND MAIN.RouteCode = BO.RouteCode AND MAIN.ShopType = BO.ShopType

-- WHERE MAIN.DateKey = 20220901 AND MAIN.RouteCode = '12NF03'

ORDER BY MAIN.DateKey, MAIN.BranchCode, MAIN.RouteCode,MAIN.ShopType



