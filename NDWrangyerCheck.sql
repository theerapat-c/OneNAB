SELECT [DateKey]
      ,[BranchCode]
      ,[RouteCode]
      ,sum(WrangyerActiveOutletVL) AS Wrangyer
      
  FROM SCC_AggActOutletYM
  WHERE DateKey = 20220901 
  
GROUP BY DateKey,
 RouteCode,BranchCode