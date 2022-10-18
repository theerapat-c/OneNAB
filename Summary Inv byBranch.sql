SELECT  [DateKey]
      , CONVERT(date, CONVERT(varchar(10), [DateKey])) AS InvoiceDate
      , INV.[BranchCode]
	  , LO.BranchDescThai AS BranchName
	  , CONCAT(LO.BranchDescThai,' ', RO.SubBranch) AS BranchDesc
	  , LO.RegionSSC AS Region
	  , LO.League
      , SUM([EstCase]) AS [EstCase]
      , SUM([EstLitre]) AS [EstLitre]
      , SUM([EstTotalAmount]) AS [EstTotalAmount]
      , SUM([CrystalCase]) AS [CrystalCase]
      , SUM([CrystalLitre]) AS  [CrystalLitre]
      , SUM([CrystalTotalAmount]) AS [CrystalTotalAmount]
      , SUM([OishiCase]) AS  [OishiCase]
      , SUM([OishiLitre]) AS [OishiLitre]
      , SUM([OishiTotalAmount]) AS  [OishiTotalAmount]
      , SUM([WrangyerCase]) AS [WrangyerCase]
      , SUM([WrangyerLitre]) AS [WrangyerLitre]
      , SUM([WrangyerTotalAmount]) AS [WrangyerTotalAmount]
      , SUM([OtherBrandCase]) AS [OtherBrandCase]
      , SUM([OtherBrandLitre]) AS [OtherBrandLitre]
      , SUM([OtherBrandTotalAmount]) AS [OtherBrandTotalAmount]
      , SUM([TotalBrandCase]) AS [TotalBrandCase]
      , SUM([TotalBrandLitre]) AS [TotalBrandLitre]
      , SUM([TotalBrandTotalAmount]) AS [TotalBrandTotalAmount]
      , SUM([TotalOutletVP]) AS [TotalOutletVP]
      , SUM([ActiveOutletVP]) AS [ActiveOutletVP]
      , SUM([NoOfPlanVisit]) AS [NoOfPlanVisit]
      , SUM([NoOfActualVisit]) AS [NoOfActualVisit]
      , SUM([NoOfBill]) AS [NoOfBill]
      , SUM([NoOfBrand]) AS [NoOfBrand]

FROM SSC_AggInvAllDataYM INV
     LEFT JOIN SSC_DimLocation LO ON INV.BranchCode = LO.BranchCode
     LEFT JOIN SSC_DimRoute RO ON INV.RouteCode = RO.Route

WHERE SUBSTRING(RouteCode,4,1) <> 'O'                  -- // Exclude Chevron
	  AND NOT(PxIncludeFlag = 0 AND PostMixFlag = 1)   -- // PostMix Condition

GROUP BY [DateKey]
      , INV.[BranchCode]
	  , LO.BranchDescThai , CONCAT(LO.BranchDescThai,' ', RO.SubBranch)
	  , LO.RegionSSC
	  , LO.League

ORDER BY DateKey, BranchCode