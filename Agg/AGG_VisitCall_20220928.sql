WITH
PlanVisit AS
(
SELECT  CASE WHEN SalesType1 = 'PS' THEN FORMAT(DATEADD(DAY,1,AssignedDate),'yyyyMM')
	         ELSE FORMAT(AssignedDate,'yyyyMM')
			 END AS DateKey
      , Branch, VP.Route, VP.Salesman, Customer
	  , COUNT(*) AS NoOfVisit

FROM SSC_FactVisitList VP
     LEFT JOIN SSC_DimRoute RO ON VP.Route = RO.Route
-- WHERE FORMAT(DATEADD(DAY,1,AssignedDate),'yyyyMM') IN ('202204','202205','202206') AND VP.Route IN ('12AK04','12AI04')


GROUP BY CASE WHEN SalesType1 = 'PS' THEN FORMAT(DATEADD(DAY,1,AssignedDate),'yyyyMM')
	         ELSE FORMAT(AssignedDate,'yyyyMM') END 
       , Branch, VP.Route, VP.Salesman, Customer
),

ActualVisit AS
(
SELECT  CASE WHEN SalesType1 = 'PS' THEN FORMAT(DATEADD(DAY,1,VisitDate),'yyyyMM')
	         ELSE FORMAT(VisitDate,'yyyyMM')
			 END AS DateKey
      , Branch, AV.Route, AV.Salesman, Customer
	  , COUNT(*) AS NoOfVisit

FROM SSC_FactActualVisit AV
     LEFT JOIN SSC_DimRoute RO ON AV.Route = RO.Route
-- WHERE FORMAT(DATEADD(DAY,1,VisitDate),'yyyyMM') IN ('202204','202205','202206') AND AV.Route IN ('12AK04','12AI04')


GROUP BY CASE WHEN SalesType1 = 'PS' THEN FORMAT(DATEADD(DAY,1,VisitDate),'yyyyMM')
	         ELSE FORMAT(VisitDate,'yyyyMM') END 
       , Branch, AV.Route, AV.Salesman, Customer
),

AllList AS
( SELECT Branch, Route, Salesman, Customer, DateKey FROM ActualVisit 
  UNION 
  SELECT Branch, Route, Salesman, Customer, DateKey FROM PlanVisit )

SELECT AL.Branch AS BranchCode, AL.Route AS RouteCode, AL.Salesman, CONCAT(AL.DateKey,'01') AS DateKey
     , COUNT(DISTINCT PV.Customer) AS CustomerPlanVisit
	 , COUNT(DISTINCT AV.Customer) AS CustomerActualVisit
	 , COUNT(DISTINCT CASE WHEN PV.Customer IS NOT NULL AND AV.Customer IS NOT NULL THEN AL.Customer END) CustomerVisitOnPlan
	 , SUM(ISNULL(PV.NoOfVisit,0)) AS NoOfPlanVisit
	 , SUM(ISNULL(AV.NoOfVisit,0)) AS NoOfActualVisit
	 , GETDATE() AS PYLoadDate

-- DROP TABLE TEST_AggVisitCallYM
--  INTO TEST_AggVisitCallYM
	
FROM AllList AL
     LEFT JOIN PlanVisit PV ON AL.DateKey=PV.DateKey AND AL.Branch=PV.Branch AND AL.Customer=PV.Customer AND AL.Route=PV.Route AND AL.Salesman=PV.Salesman
     LEFT JOIN ActualVisit AV ON AL.DateKey=AV.DateKey AND AL.Branch=AV.Branch AND AL.Customer=AV.Customer AND AL.Route=AV.Route AND AL.Salesman=AV.Salesman

-- WHERE AL.Branch = 3402

GROUP BY AL.Branch, AL.Route, AL.Salesman ,AL.DateKey
ORDER BY AL.Branch, AL.Route, AL.Salesman ,AL.DateKey
	 

