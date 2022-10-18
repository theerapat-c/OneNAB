WITH 
CF_Channel AS
(
SELECT ChannelMarge,Value2 AS PostMixFlag
FROM SSC_DimChannel CN
     INNER JOIN TEST_CONFIGTABLE CF ON CN.SalesOfficeDesc = CF.Value1
),

MergeDimension AS
(
SELECT [DateKey],[BranchCode],[RouteCode]
FROM [SCC_AggInvVolByBrandYM] INV
     INNER JOIN CF_Channel CC ON INV.ChannelSalesOffice = CC.ChannelMarge
	 LEFT JOIN SSC_DimCustomer CU ON INV.HANAFlag = CU.HANAFlag AND INV.CustomerCode = CU.Customer
	 LEFT JOIN SSC_DimCustGrp1 CG ON CU.CustGrp1 = CG.CustGrp
WHERE ShopType NOT IN ('CVM','Employee') AND CU.SpecialGrp1 IN ('','Other') 
      AND LEFT(INV.CustomerCode,1) <> 'E' AND CustGrp NOT IN ('-2','131') AND CustType = 'Customer store'
  --    AND SalesOfficeDesc IN ('Direct Sales','Presales','Online','Post-Mix','Vending')
GROUP BY [DateKey],[BranchCode],[RouteCode]

UNION SELECT [DateKey],[BranchCode],[RouteCode] FROM [dbo].[SSC_AggVisitCallYM] GROUP BY [DateKey],[BranchCode],[RouteCode]

UNION SELECT [DateKey],[BranchCode],[RouteCode] FROM [dbo].[SCC_AggActOutletYM] GROUP BY [DateKey],[BranchCode],[RouteCode]

UNION

SELECT  DateKey, BranchCode, ISNULL(RouteCode,'') AS RouteCode
FROM SCC_AggAssetCoolerYM CO
     LEFT JOIN SSC_DimCustomer CU ON CO.CustomerCode = CU.Customer AND CU.HANAFlag = 1
	 LEFT JOIN SSC_DimCustGrp1 CG ON CU.CustGrp1 = CG.CustGrp
WHERE CG.ShopType IN ('FSR','Provision','Other')  
GROUP BY DateKey,BranchCode,ISNULL(RouteCode,'')
),

AGG_Volume AS
(
SELECT  [DateKey],[BranchCode],[RouteCode]
       , CASE WHEN PostMixFlag ='Post-Mix' THEN 1 ELSE 0 END AS PostMixFlag
       , SUM(CASE WHEN Brand = 'Est' THEN SoldCase ELSE 0 END) AS EstCase
	   , SUM(CASE WHEN Brand = 'Est' THEN SoldCaseLastDay ELSE 0 END) AS EstCaseLastDay
	   , SUM(CASE WHEN Brand = 'Est' THEN SoldLitre ELSE 0 END) AS EstLitre
	   , SUM(CASE WHEN Brand = 'Est' THEN NetItemAmt ELSE 0 END) AS EstNetAmount
	   , SUM(CASE WHEN Brand = 'Est' THEN TotalAmount ELSE 0 END) AS EstTotalAmount
       , SUM(CASE WHEN Brand = 'Crystal' THEN SoldCase ELSE 0 END) AS CrystalCase
	   , SUM(CASE WHEN Brand = 'Crystal' THEN SoldCaseLastDay ELSE 0 END) AS CrystalCaseLastDay
	   , SUM(CASE WHEN Brand = 'Crystal' THEN SoldLitre ELSE 0 END) AS CrystalLitre
	   , SUM(CASE WHEN Brand = 'Crystal' THEN NetItemAmt ELSE 0 END) AS CrystalNetAmount
	   , SUM(CASE WHEN Brand = 'Crystal' THEN TotalAmount ELSE 0 END) AS CrystalTotalAmount
	   , SUM(CASE WHEN Brand = 'Oishi' THEN SoldCase ELSE 0 END) AS OishiCase
	   , SUM(CASE WHEN Brand = 'Oishi' THEN SoldCaseLastDay ELSE 0 END) AS OishiCaseLastDay
	   , SUM(CASE WHEN Brand = 'Oishi' THEN SoldLitre ELSE 0 END) AS OishiLitre
	   , SUM(CASE WHEN Brand = 'Oishi' THEN NetItemAmt ELSE 0 END) AS OishiNetAmount
	   , SUM(CASE WHEN Brand = 'Oishi' THEN TotalAmount ELSE 0 END) AS OishiTotalAmount
	   , SUM(CASE WHEN Brand = 'Wrangyer' THEN SoldCase ELSE 0 END) AS WrangyerCase
	   , SUM(CASE WHEN Brand = 'Wrangyer' THEN SoldCaseLastDay ELSE 0 END) AS WrangyerCaseLastDay
	   , SUM(CASE WHEN Brand = 'Wrangyer' THEN SoldLitre ELSE 0 END) AS WrangyerLitre
	   , SUM(CASE WHEN Brand = 'Wrangyer' THEN NetItemAmt ELSE 0 END) AS WrangyerNetAmount
	   , SUM(CASE WHEN Brand = 'Wrangyer' THEN TotalAmount ELSE 0 END) AS WrangyerTotalAmount
	   , SUM(CASE WHEN Brand = 'Other Brand' THEN SoldCase ELSE 0 END) AS OtherBrandCase
	   , SUM(CASE WHEN Brand = 'Other Brand' THEN SoldCaseLastDay ELSE 0 END) AS OtherBrandCaseLastDay
	   , SUM(CASE WHEN Brand = 'Other Brand' THEN SoldLitre ELSE 0 END) AS OtherBrandLitre
	   , SUM(CASE WHEN Brand = 'Other Brand' THEN NetItemAmt ELSE 0 END) AS OtherBrandNetAmount
	   , SUM(CASE WHEN Brand = 'Other Brand' THEN TotalAmount ELSE 0 END) AS OtherBrandTotalAmount
	   , SUM(SoldCase) AS TotalBrandCase
	   , SUM(SoldCaseLastDay) AS TotalBrandCaseLastDay
	   , SUM(SoldLitre) AS TotalBrandLitre
	   , SUM(NetItemAmt) AS TotalBrandNetAmount
	   , SUM(TotalAmount) AS TotalBrandTotalAmount

	--   SELECT DISTINCT SalesOfficeDesc
FROM [SCC_AggInvVolByBrandYM] INV
     INNER JOIN CF_Channel CC ON INV.ChannelSalesOffice = CC.ChannelMarge
	 LEFT JOIN SSC_DimCustomer CU ON INV.HANAFlag = CU.HANAFlag AND INV.CustomerCode = CU.Customer
	 LEFT JOIN SSC_DimCustGrp1 CG ON CU.CustGrp1 = CG.CustGrp

WHERE ShopType NOT IN ('CVM','Employee') AND CU.SpecialGrp1 IN ('','Other') 
      AND LEFT(INV.CustomerCode,1) <> 'E' AND CustGrp NOT IN ('-2','131') AND CustType = 'Customer store'
     -- AND SalesOfficeDesc IN ('Direct Sales','Presales','Online','Post-Mix','Vending')

GROUP BY [DateKey],[BranchCode],[RouteCode],CASE WHEN PostMixFlag ='Post-Mix' THEN 1 ELSE 0 END
),

AGG_VisitCall AS
(
SELECT  [DateKey],[BranchCode],[RouteCode]
      , SUM(NoOfPlanVisit) AS NoOfPlanVisit
	  , SUM(NoOfActualVisit) AS NoOfActualVisit

FROM [dbo].[SSC_AggVisitCallYM]

GROUP BY [DateKey],[BranchCode],[RouteCode]
),

AGG_BrandBill AS
(
SELECT  [DateKey],[BranchCode],[RouteCode]
	   , SUM(NoOfBill - NoOfBillCN) AS NoOfBill
	   , SUM(NoOfBrand - NoOfBrandCN) AS NoOfBrand
-- SELECT *	
FROM [dbo].[SSC_AggInvBillBrandYM] INV
     INNER JOIN CF_Channel CC ON INV.ChannelSalesOffice = CC.ChannelMarge
	 LEFT JOIN SSC_DimCustomer CU ON INV.HANAFlag = CU.HANAFlag AND INV.CustomerCode = CU.Customer
	 LEFT JOIN SSC_DimCustGrp1 CG ON CU.CustGrp1 = CG.CustGrp

WHERE ShopType NOT IN ('CVM','Employee') AND CU.SpecialGrp1 IN ('','Other')
      AND LEFT(INV.CustomerCode,1) <> 'E' AND CustGrp NOT IN ('-2','131') AND CustType = 'Customer store'
      -- AND SalesOfficeDesc IN ('Direct Sales','Presales','Online','Post-Mix','Vending')

GROUP BY [DateKey],[BranchCode],[RouteCode]
),

AGG_ActiveOutlet AS
(
SELECT [DateKey],[BranchCode],[RouteCode]
      , SUM(TotalOutlet) AS TotalOutlet
	  , SUM(ActiveOutlet) AS ActiveOutlet
	  , SUM(EstActiveOutlet) AS EstActiveOutlet
      , SUM(CrystalActiveOutlet) AS CrystalActiveOutlet
      , SUM(FSRRBActiveOutlet) AS FSRRBActiveOutlet
	  , SUM(ActiveBrandOutlet) AS ActiveBrandOutlet
	  , SUM(NoOfBrandOutlet) AS NoOfBrandOutlet

FROM [dbo].[SCC_AggActOutletYM]

GROUP BY [DateKey],[BranchCode],[RouteCode]
)


SELECT  MAIN.DateKey,MAIN.BranchCode,MAIN.RouteCode
      , MAX(ISNULL(PostMixFlag,0)) AS PostMixFlag

      , SUM(EstCase) AS EstCase
	  , SUM(EstCaseLastDay) AS EstCaseLastDay
	  , SUM(EstLitre) AS EstLitre
	  , SUM(EstNetAmount) AS EstNetAmount
	  , SUM(EstTotalAmount) AS EstTotalAmount

	  , SUM(CrystalCase) AS CrystalCase
	  , SUM(CrystalCaseLastDay) AS CrystalCaseLastDay
	  , SUM(CrystalLitre) AS CrystalLitre
	  , SUM(CrystalNetAmount) AS CrystalNetAmount
	  , SUM(CrystalTotalAmount) AS CrystalTotalAmount

	  , SUM(OishiCase) AS OishiCase
	  , SUM(OishiCaseLastDay) AS OishiCaseLastDay
	  , SUM(OishiLitre) AS OishiLitre
	  , SUM(OishiNetAmount) AS OishiNetAmount
	  , SUM(OishiTotalAmount) AS OishiTotalAmount

	  , SUM(WrangyerCase) AS WrangyerCase
	  , SUM(WrangyerCaseLastDay) AS WrangyerCaseLastDay
	  , SUM(WrangyerLitre) AS WrangyerLitre
	  , SUM(WrangyerNetAmount) AS WrangyerNetAmount
	  , SUM(WrangyerTotalAmount) AS WrangyerTotalAmount

	  , SUM(OtherBrandCase) AS OtherBrandCase
	  , SUM(OtherBrandCaseLastDay) AS OtherBrandCaseLastDay
	  , SUM(OtherBrandLitre) AS OtherBrandLitre
	  , SUM(OtherBrandNetAmount) AS OtherBrandNetAmount
	  , SUM(OtherBrandTotalAmount) AS OtherBrandTotalAmount

	  , SUM(TotalBrandCase) AS TotalBrandCase
	  , SUM(TotalBrandCaseLastDay) AS TotalBrandCaseLastDay
	  , SUM(TotalBrandLitre) AS TotalBrandLitre
	  , SUM(TotalBrandNetAmount) AS TotalBrandNetAmount 
	  , SUM(TotalBrandTotalAmount) AS TotalBrandTotalAmount

	  , SUM(TotalOutlet) AS TotalOutlet
	  , SUM(ActiveOutlet) AS ActiveOutlet
	  , SUM(EstActiveOutlet) AS EstActiveOutlet
      , SUM(CrystalActiveOutlet) AS CrystalActiveOutlet
      , SUM(FSRRBActiveOutlet) AS FSRRBActiveOutlet
	  , SUM(ActiveBrandOutlet) AS ActiveBrandOutlet
	  , SUM(NoOfBrandOutlet) AS NoOfBrandOutlet
	
	  , SUM(NoOfPlanVisit) AS NoOfPlanVisit
	  , SUM(NoOfActualVisit) AS NoOfActualVisit 

	  , SUM(NoOfBill) AS NoOfBill
	  , SUM(NoOfBrand) AS NoOfBrand

	  , GETDATE() AS PYLoadDate

-- DROP TABLE TEST_AggInvAllDataYM
-- INTO TEST_AggInvAllDataYM

FROM MergeDimension MAIN
     LEFT JOIN AGG_Volume VL ON MAIN.BranchCode = VL.BranchCode AND MAIN.RouteCode = VL.RouteCode  AND MAIN.DateKey = VL.DateKey
     LEFT JOIN AGG_VisitCall VC ON MAIN.BranchCode = VC.BranchCode AND MAIN.RouteCode = VC.RouteCode  AND MAIN.DateKey = VC.DateKey
     LEFT JOIN AGG_BrandBill BB ON MAIN.BranchCode = BB.BranchCode AND MAIN.RouteCode = BB.RouteCode  AND MAIN.DateKey = BB.DateKey
	 LEFT JOIN AGG_ActiveOutlet AO ON MAIN.BranchCode = AO.BranchCode AND MAIN.RouteCode = AO.RouteCode  AND MAIN.DateKey = AO.DateKey
	

-- WHERE MAIN.DateKey = '20220801' AND MAIN.BranchCode = 3400

GROUP BY MAIN.DateKey,MAIN.BranchCode,MAIN.RouteCode
ORDER BY MAIN.DateKey,MAIN.BranchCode,MAIN.RouteCode