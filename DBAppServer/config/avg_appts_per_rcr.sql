/*
---------------------------------------------------------
sql/go/recruiting/rcr_smy_ytd.sql
CHANGED TO WORK HERE -- YTD_TOTAL = CURRENT YEAR ACTUAL
AVG_CURR_YTD = CURRRENT YEAR AVG - - THE COMPONENTS OF THE
AVG WILL BE USED TO GET THE ZONE AND THEN THE COMPANY 
AVG 
THE COMPONENTS ARE: NUM_RCRS AND NUM_MONTHS(ie.. p.period)
----------------------------------------------------------	*/
  (SELECT 
	     r2.YTD_TOTAL YTD_TOTAL 
   	   , r.AVG_RCRS AVG_CURR_YTD
   FROM
	(
	SELECT count(*) YTD_TOTAL
	FROM ai0101.RCR_MGMT_HISTORY
	where TITLE != '0A'
		  AND YEAR_MO_DT = TO_DATE('01-Nov-2006')
		  AND ALT_ORG_UNIT_CD = 'V56'
	) r2,

	(
	SELECT COUNT(alt_org_unit_cd) NUM_RCRS,
		   p.period NUM_MONTHS,
		   ( COUNT(alt_org_unit_cd) / (p.period) ) AVG_RCRS
	FROM ai0101.RCR_MGMT_HISTORY
	     , (
	   	    SELECT 
	  	 		MONTHS_BETWEEN(ADD_MONTHS(TO_DATE('01-Nov-2006'), 0)
				,TO_DATE('01-Dec-' || TO_CHAR(TO_DATE('01-Nov-2005'), 'YYYY'))) period 
	        FROM dual
		   )p
	WHERE TITLE != '0A'
		  AND alt_org_unit_cd = 'V56'
		  AND YEAR_MO_DT  BETWEEN TO_DATE(TO_CHAR(TO_DATE('01-Nov-2006'), 'YYYY')||'01' , 'yyyymm') AND TO_DATE('01-Nov-2006')
	GROUP BY p.period
	) r,
	
	(	  
	  SELECT COUNT(alt_org_unit_cd) YEAR_TOTAL
	  FROM ai0101.RCR_MGMT_HISTORY
	  WHERE TITLE != '0A'
	  	    AND alt_org_unit_cd = 'V56'
	  		AND YEAR_MO_DT = TO_DATE(TO_CHAR(TO_DATE('01-Nov-2005'), 'YYYY')||'12' , 'yyyymm' )
	) PREV
	-------------------------------------
	Working version of above:
	-------------------------------------
SELECT zone.zone_cd, INITCAP(zone.zone_nm) zone_nm, INITCAP(zone.org_unit_nm) org_unit_nm, RTRIM(zone.org_unit_cd) org_unit_cd, 
    gpa.YTD_AVG_RCR_QY average, 
    actual.YTD_TOTAL actual,
	gpa.YTD_APPT_QY total_appts,
	gpa.AVG_APP_PER_RCR_NO average_appts,	
	gpa.POINTS_6_NO points,
    actual.NUM_RCRS,
	actual.NUM_MONTHS
FROM
 	ai0101.cur_go_zone zone
  , ai0101.gpa_mp gpa
  ,(SELECT 
	   go.ORG_UNIT_CD
	 , r2.YTD_TOTAL YTD_TOTAL
	 , r.NUM_RCRS
	 , r.NUM_MONTHS 
	 FROM
		ai0101.cur_go_zone go,
		(
		 SELECT count(*) YTD_TOTAL,
		   	   	ALT_ORG_UNIT_CD
		 FROM ai0101.RCR_MGMT_HISTORY
		 WHERE TITLE != '0A'
		 AND YEAR_MO_DT = TO_DATE('01-Nov-2006')
		 GROUP BY ALT_ORG_UNIT_CD
	 	) r2,
	 	
	 	(
		SELECT COUNT(alt_org_unit_cd) NUM_RCRS,
		       ALT_ORG_UNIT_CD,
		       p.period NUM_MONTHS
	    FROM ai0101.RCR_MGMT_HISTORY
	       , (
	   	      SELECT 
	  	 		MONTHS_BETWEEN(ADD_MONTHS(TO_DATE('01-Nov-2006'), 0)
				,TO_DATE('01-Dec-' || TO_CHAR(TO_DATE('01-Nov-2005'), 'YYYY'))) period 
	          FROM dual
		     )p
	    WHERE TITLE != '0A'
		AND YEAR_MO_DT  BETWEEN TO_DATE(TO_CHAR(TO_DATE('01-Nov-2006'), 'YYYY')||'01' , 'yyyymm') AND TO_DATE('01-Nov-2006')
	    GROUP BY ALT_ORG_UNIT_CD,p.period
       ) r
	
    WHERE go.ORG_UNIT_CD =   r2.ALT_ORG_UNIT_CD (+)
    AND   go.ORG_UNIT_CD =    r.ALT_ORG_UNIT_CD (+)) actual
WHERE
	zone.ORG_UNIT_CD = gpa.ALT_ORG_UNIT_CD 
AND 
	zone.ORG_UNIT_CD = actual.ORG_UNIT_CD 
AND
  TRIM(zone.ZONE_CD) <> 'XX'
ORDER BY 
--<%=orderBy%>
zone.zone_cd, zone.org_unit_nm