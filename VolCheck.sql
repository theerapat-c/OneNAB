WITH 
CF_ReasonCode AS  --// For table configuration
(
SELECT ReasonCode
FROM SSC_DimReason
WHERE LEFT(ReasonCode,1) <> '6' 
      AND ReasonCode NOT IN (413,451,453,465,470,482,491,493)
	-- AND ReasonCode NOT IN (SELECT Value1 FROM TEST_CONFIGTABLE WHERE Category = 'ReasonCode' AND ActiveStatus = 1)
	-- 
),

CF_Channel AS   --// For table configuration
(
SELECT ChannelMarge,Value2 AS PostMixFlag
FROM SSC_DimChannel CN
     INNER JOIN TEST_CONFIGTABLE CF ON CN.SalesOfficeDesc = CF.Value1
)

SELECT  YM AS YM
     , RO.BranchVL AS BranchCode
	  , LO.BranchDescThai AS BranchName
	  , CONCAT(LO.BranchDescThai,' ', RO.SubBranch) AS BranchDesc
	  , ISNULL(NULLIF(VL,''),INV.Route) AS RouteCode
	--  , Salesman
	--  , INV.ChannelMarge AS ChannelSalesOffice
	--  , CH.SalesOfficeDesc
	--  , Customer AS CustomerCode
	  , ShopType
	--  , DataSource AS DataSource 
	--  , BasicMaterial  AS BasicMaterial 
	  , BrandDesc
	
	--  , MatType1
		, MT.SizingDesc
	--  , SUM(SoldSingle) AS SoldSingle
	  , SUM(SoldCase) AS SoldCase	
	--  , SUM(SoldBaseQty) AS SoldBaseQty
	  , SUM((SoldBaseQty * Millilitre)/1000) AS SoldLitre
	--  , SUM(FreeSingle) AS FreeSingle
	--  , SUM(FreeCase) AS FreeCase	
	--  , SUM(FreeBaseQty) AS FreeBaseQty
	--  , SUM((FreeBaseQty * Millilitre)/1000) AS FreeLitre
      , SUM(NetItemAmt) AS NetItemAmt
	  , SUM(VatAmt) AS VatAmt
	  , SUM(TotalAmt) AS TotalAmount
	  , SUM(Discount) AS Discount

FROM SSC_FactAllDataInvoice INV
     INNER JOIN CF_ReasonCode CR ON INV.ReasonCode = CR.ReasonCode
	 INNER JOIN CF_Channel CC ON INV.ChannelMarge = CC.ChannelMarge    
     LEFT JOIN SSC_DimRoute RO ON ISNULL(NULLIF(VL,''),INV.Route)  = RO.Route
	 LEFT JOIN SSC_DimLocation LO ON RO.BranchVL = LO.BranchCode
     LEFT JOIN SSC_DimMaterial MT ON INV.Material = MT.Material
	 LEFT JOIN SSC_DimChannel CH ON INV.ChannelMarge = CH.ChannelMarge
	 LEFT JOIN SSC_DimCustomer CU ON INV.HANAFlag = CU.HANAFlag AND INV.Customer = CU.Customer
	 LEFT JOIN SSC_DimCustGrp1 CG ON CU.CustGrp1 = CG.CustGrp


WHERE MaterialType = 'Z31' AND MatType1Id IN (1,8) AND PackagingType IN ('NR','RB') AND GroupPostMix <> 'PostMix'
      AND ShopType NOT IN ('CVM','Employee') AND CU.SpecialGrp1 IN ('','Other') 
      AND LEFT(INV.Customer,1) <> 'E' AND CustGrp NOT IN ('-2','131') 

	  AND SUBSTRING(ISNULL(NULLIF(VL,''),INV.Route) ,4,1) NOT IN ('O','R','S','T') 
      AND SUBSTRING((CASE WHEN INV.Branch IN (3403,3400) THEN 'A'                             -- // Route I Condition
	      ELSE ISNULL(NULLIF(VL,''),INV.Route)  END),4,1) <> 'I'                               
      AND NOT (SUBSTRING(ISNULL(NULLIF(VL,''),INV.Route) ,4,1) = 'X' AND PxIncludeFlag = 0)   -- // Route PostMix Condition
      AND NOT (PxIncludeFlag = 0 AND PostMixFlag = 'Post-Mix')                                -- // Channel PostMix Condition
	  AND CASE WHEN INV.Branch IN (3400,3403,3406) AND ISNULL(NULLIF(VL,''),INV.Route)  = '' THEN NULL 
	      ELSE ISNULL(NULLIF(VL,''),INV.Route)  END IS NOT NULL                               -- // Route Blank Condition

	  --AND ( LEFT(DateKey,6) = FORMAT(GETDATE(),'yyyyMM') OR LEFT(DateKey,6) = FORMAT(DATEADD(YEAR,-1,GETDATE()),'yyyyMM'))                                            -- // Date Condition
	  -- CURRENT Month This year and Last year
	  AND YM = 202209
	  --AND INV.Route = '12DD03'
	  

GROUP BY YM 
      , RO.BranchVL
	  , LO.BranchDescThai 
	  , CONCAT(LO.BranchDescThai,' ', RO.SubBranch)
	  , ISNULL(NULLIF(VL,''),INV.Route) 
	--  , Salesman
	--  , INV.ChannelMarge
	--  , CH.SalesOfficeDesc
	--  , Customer 
	  , ShopType
	--  , DataSource 
	--  , BasicMaterial 
	  , BrandDesc
	  
	--  , MatType1
		, MT.SizingDesc
		
			  
ORDER BY YM, RO.BranchVL, ISNULL(NULLIF(VL,''),INV.Route) 

