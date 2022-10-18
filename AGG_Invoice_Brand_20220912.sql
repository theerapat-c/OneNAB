WITH 
CF_ReasonCode AS
(
SELECT ReasonCode
FROM SSC_DimReason
WHERE LEFT(ReasonCode,1) <> '6' 
      AND ReasonCode NOT IN (413,451,453,465,470,482,491,493)
	-- AND ReasonCode NOT IN (SELECT Value1 FROM TEST_CONFIGTABLE WHERE Category = 'ReasonCode' AND ActiveStatus = 1)
)

SELECT  HANAFlag
      , CONCAT(YM,'01') AS DateKey
      , Branch AS BranchCode
	  , Route AS RouteCode
	  , Salesman
	  , ChannelMarge AS ChannelSalesOffice
	  , Customer AS CustomerCode
	  , DataSource AS DataSource 
	  , BType AS BillType
	  , BrandDescription
	  , CASE WHEN BrandDesc = 'Crystal' THEN  'Crystal'
	         WHEN BrandDesc = 'Est' THEN  'Est'
			 WHEN BrandDesc = 'Oishi' THEN  'Oishi'
			 WHEN BrandDesc = 'Wrangyer' THEN  'Wrangyer' 
			 ELSE 'Other Brand' END AS Brand
	  , CASE WHEN BType = 'TaxInv' THEN COUNT(DISTINCT Documents) ELSE 0 END AS NoOfBrandBill
	  , CASE WHEN BType <> 'TaxInv' THEN COUNT(DISTINCT Documents) ELSE 0 END AS NoOfBrandBillCN
	  , SUM(SoldSingle) AS SoldSingle
	  , SUM(SoldCase) AS SoldCase
	  , SUM(SoldBaseQty) AS SoldBaseQty
	  , SUM((SoldBaseQty * Millilitre)/1000) AS SoldLitre
	  , SUM(FreeCase) AS FreeCase
	  , SUM(FreeBaseQty) AS FreeBaseQty
	  , SUM((FreeBaseQty * Millilitre)/1000) AS FreeLitre
      , SUM(NetItemAmt) AS NetItemAmt
	  , SUM(VatAmt) AS VatAmt
	  , SUM(TotalAmt) AS TotalAmount
	  , SUM(Discount) AS Discount
	  , GETDATE() AS PYLoadDate

-- DROP TABLE SSC_AGG_Invoice_Brand
-- INTO SSC_AGG_Invoice_Brand

FROM SSC_FactAllDataInvoice INV
     INNER JOIN CF_ReasonCode CR ON INV.ReasonCode = CR.ReasonCode
     LEFT JOIN SSC_DimMaterial MT ON INV.Material = MT.Material

WHERE MaterialType = 'Z31' AND MatType1Id IN (1,8) AND PackagingType IN ('NR','RB') AND GroupPostMix <> 'PostMix'
     -- AND LEFT(ReasonCode,1) <> '6' AND ReasonCode NOT IN (413,451,453,465,470,482,491,493)
	  AND YM = '202207' AND Branch = '3402'

GROUP BY  HANAFlag,  CONCAT(YM,'01'), Branch, Route, Salesman, Customer, ChannelMarge, DataSource, BType, BrandDescription
        , CASE WHEN BrandDesc = 'Crystal' THEN  'Crystal'
	           WHEN BrandDesc = 'Est' THEN  'Est'
		       WHEN BrandDesc = 'Oishi' THEN  'Oishi'
			   WHEN BrandDesc = 'Wrangyer' THEN  'Wrangyer' 
			   ELSE 'Other Brand' END 

ORDER BY CONCAT(YM,'01'), Branch, Route, Salesman, Customer, ChannelMarge, DataSource, BrandDescription

