WITH 
AOP AS
(
SELECT  CONCAT(YM,'01') AS DateKey,CONCAT(Branch,SubBranch) AS SubBranch
      , SUM(CASE WHEN Brand = 'Est' THEN AOP ELSE 0 END) AS EstCaseAOP
	  , SUM(CASE WHEN Brand = 'Crystal' THEN AOP ELSE 0 END) AS CrystalCaseAOP
	  , SUM(CASE WHEN Brand = 'Oishi' THEN AOP ELSE 0 END) AS OishiCaseAOP
	  , SUM(CASE WHEN Brand = 'Wrangyer' THEN AOP ELSE 0 END) AS WrangyerCaseAOP
	  , SUM(CASE WHEN Brand = 'Other Brand' THEN AOP ELSE 0 END) AS OtherBrandCaseAOP
	  , SUM(AOP) AS TotalBrandCaseAOP
	  , SUM(CASE WHEN Brand = 'Est' THEN AOPLY ELSE 0 END) AS EstCaseAOPLY
	  , SUM(CASE WHEN Brand = 'Crystal' THEN AOPLY ELSE 0 END) AS CrystalCaseAOPLY
	  , SUM(CASE WHEN Brand = 'Oishi' THEN AOPLY ELSE 0 END) AS OishiCaseAOPLY
	  , SUM(CASE WHEN Brand = 'Wrangyer' THEN AOPLY ELSE 0 END) AS WrangyerCaseAOPLY
	  , SUM(CASE WHEN Brand = 'Other Brand' THEN AOPLY ELSE 0 END) AS OtherBrandCaseAOPLY
	  , SUM(AOPLY) AS TotalBrandCaseAOPLY
FROM SSC_AOP
GROUP BY CONCAT(YM,'01'),CONCAT(Branch,SubBranch)
),

ACT AS
(
SELECT  [DateKey]
      , CONVERT(date, CONVERT(varchar(10), [DateKey])) AS InvoiceDate
	  , CONCAT( INV.[BranchCode],RO.SubBranch) AS SubBranch
      , INV.[BranchCode]
	  , LO.BranchDescThai AS BranchName
	  , CONCAT(LO.BranchDescThai,' ', RO.SubBranch) AS BranchDesc
	  , LO.RegionSSC AS Region
	  , LO.League
      , SUM([EstCase]) AS [EstCase]
      , SUM([EstLitre]) AS [EstLitre]
      , SUM(EstNetAmount) AS EstNetAmount
	  , SUM(EstTotalAmount) AS EstTotalAmount
      , SUM([CrystalCase]) AS [CrystalCase]
      , SUM([CrystalLitre]) AS  [CrystalLitre]
      , SUM(CrystalNetAmount) AS CrystalNetAmount
	  , SUM(CrystalTotalAmount) AS CrystalTotalAmount
      , SUM([OishiCase]) AS  [OishiCase]
      , SUM([OishiLitre]) AS [OishiLitre]
      , SUM(OishiNetAmount) AS  OishiNetAmount
	  , SUM(OishiTotalAmount) AS  OishiTotalAmount
      , SUM([WrangyerCase]) AS [WrangyerCase]
      , SUM([WrangyerLitre]) AS [WrangyerLitre]
      , SUM(WrangyerNetAmount) AS WrangyerNetAmount
	  , SUM(WrangyerTotalAmount) AS WrangyerTotalAmount
      , SUM([OtherBrandCase]) AS [OtherBrandCase]
      , SUM([OtherBrandLitre]) AS [OtherBrandLitre]
      , SUM([OtherBrandNetAmount] ) AS OtherBrandNetAmount
	  , SUM(OtherBrandTotalAmount ) AS OtherBrandTotalAmount
      , SUM([TotalBrandCase]) AS [TotalBrandCase]
      , SUM([TotalBrandLitre]) AS [TotalBrandLitre]
      , SUM(TotalBrandNetAmount) AS TotalBrandNetAmount
	  , SUM(TotalBrandTotalAmount) AS TotalBrandTotalAmount
      , SUM([TotalOutletVP]) AS TotalOutletVP
      , SUM([ActiveOutletVP]) AS ActiveOutletVP
	  , SUM(NoOfBrandOutletVL) AS NoOfBrandOutletVL
	  , SUM(ActiveBrandOutletVL) AS ActiveBrandOutletVL
      , SUM([NoOfPlanVisit]) AS [NoOfPlanVisit]
      , SUM([NoOfActualVisit]) AS [NoOfActualVisit]
      , SUM([NoOfBill]) AS [NoOfBill]
      , SUM([NoOfBrand]) AS [NoOfBrand]


FROM SSC_AggInvAllDataYM INV
     LEFT JOIN SSC_DimLocation LO ON INV.BranchCode = LO.BranchCode
     LEFT JOIN (SELECT Route,SubBranch FROM SSC_DimRoute GROUP BY Route,SubBranch) RO ON INV.RouteCode = RO.Route

WHERE SUBSTRING(RouteCode,4,1) NOT IN ('O','R','S','T') 
      AND SUBSTRING((CASE WHEN INV.BranchCode IN (3403,3400) THEN 'A'   -- // Route I Condition
	      ELSE RouteCode END),4,1) <> 'I'                               
      AND NOT (SUBSTRING(RouteCode,4,1) = 'X' AND PxIncludeFlag = 0)    -- // Route PostMix Condition
      AND NOT (PxIncludeFlag = 0 AND PostMixFlag = 1)                   -- // Channel PostMix Condition
	  AND CASE WHEN INV.BranchCode IN (3400,3403,3406) AND RouteCode = '' THEN NULL 
	      ELSE RouteCode END IS NOT NULL                                 --// Route Blank Condition
  --    AND DateKey = 20220701

GROUP BY [DateKey]
      , INV.[BranchCode], CONCAT( INV.[BranchCode],RO.SubBranch)
	  , LO.BranchDescThai , CONCAT(LO.BranchDescThai,' ', RO.SubBranch)
	  , LO.RegionSSC
	  , LO.League
)

SELECT  ACT.DateKey
      , InvoiceDate
	  , BranchCode
	  , BranchName
	  , BranchDesc
	  , Region
	  , League
	  , EstCase
	  , EstCaseAOP
	  , EstCaseAOPLY
	  , EstLitre
	  , EstNetAmount
	  , EstTotalAmount
	  , CrystalCase
	  , CrystalCaseAOP
	  , CrystalCaseAOPLY
	  , CrystalLitre
	  , CrystalNetAmount
	  , CrystalTotalAmount
	  , OishiCase
	  , OishiCaseAOP
	  , OishiCaseAOPLY
	  , OishiLitre
	  , OishiNetAmount
	  , OishiTotalAmount
	  , WrangyerCase
	  , WrangyerCaseAOP
	  , WrangyerCaseAOPLY
	  , WrangyerLitre
	  , WrangyerNetAmount
	  , WrangyerTotalAmount
	  , OtherBrandCase
	  , OtherBrandCaseAOP
	  , OtherBrandCaseAOPLY
	  , OtherBrandLitre
	  , OtherBrandNetAmount
	  , OtherBrandTotalAmount
	  , TotalBrandCase
	  , TotalBrandCaseAOP
	  , TotalBrandCaseAOPLY
	  , TotalBrandLitre
	  , TotalBrandNetAmount
	  , TotalBrandTotalAmount
	  , TotalOutletVP
	  , ActiveOutletVP
	  , NoOfBrandOutletVL
	  , ActiveBrandOutletVL
	  , NoOfPlanVisit
	  , NoOfActualVisit
	  , NoOfBill
	  , NoOfBrand


FROM ACT LEFT JOIN AOP ON ACT.DateKey = AOP.DateKey AND ACT.SubBranch = AOP.SubBranch

ORDER BY ACT.DateKey, BranchCode