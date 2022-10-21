SELECT DA.[YM]
      ,[BranchByAsset]
	  ,VP.Branch AS BranchByVP
	  ,VP.Route AS VPRoute
      ,DA.[Customer]
      ,[AssetType]
      ,[AssetSubType]
      ,[AssetStatus]
      ,[ActiveStatus]
      ,[AssetQRCode]
      ,[AssetCode]
      ,[AssetDesc]
      ,[AssetEquipmentNo]
      ,[AssetSerialNo]
	  ,DA.ETLLoadData
	  ,GETDATE() AS PYLoadDate

FROM [STAGE].[dbo].[SSC_DataAsset] DA
     LEFT JOIN [STAGE].[dbo].[SSC_SumCustomerPerMonth_Plan]  VP ON VP.YM = DA.YM AND VP.Customer = DA.Customer