Select TRIM(dash.ORG_UNIT_CD) goCode, 
       INITCAP(TRIM(dash.ORG_UNIT_NM)) goName, 
       TRIM(dash.ZONE_CD) zoneCode, 
       SUM(CASE WHEN plan.ALT_PRDT_LINE_CD = 'LF' THEN plan.PAID_CS_QY ELSE 0 END) lifecases, 
       SUM(CASE WHEN plan.ALT_PRDT_LINE_CD = 'LF' THEN plan.FYC_AM ELSE 0 END) lifefyc, 
       SUM(CASE WHEN plan.ALT_PRDT_LINE_CD = 'LI' THEN plan.PAID_CS_QY ELSE 0 END) glicases, 
       SUM(CASE WHEN plan.ALT_PRDT_LINE_CD = 'LI' THEN plan.FYC_AM ELSE 0 END) glifyc, 
       SUM(CASE WHEN plan.ALT_PRDT_LINE_CD = 'LT' THEN plan.PAID_CS_QY ELSE 0 END) ltccases, 
       SUM(CASE WHEN plan.ALT_PRDT_LINE_CD = 'LT' THEN plan.FYC_AM ELSE 0 END) ltcfyc, 
       SUM(CASE WHEN plan.ALT_PRDT_LINE_CD = 'AN' THEN plan.PAID_CS_QY ELSE 0 END) invanncases, 
       SUM(CASE WHEN plan.ALT_PRDT_LINE_CD = 'AN' THEN plan.FYC_AM ELSE 0 END) invannfyc, 
       SUM(CASE WHEN plan.ALT_PRDT_LINE_CD = 'MF' THEN plan.PAID_CS_QY ELSE 0 END) mfcases, 
       SUM(CASE WHEN plan.ALT_PRDT_LINE_CD = 'MF' THEN plan.FYC_AM ELSE 0 END) mffyc, 
       SUM(CASE WHEN plan.ALT_PRDT_LINE_CD = 'SM' THEN plan.PAID_CS_QY ELSE 0 END) smacases, 
       SUM(CASE WHEN plan.ALT_PRDT_LINE_CD = 'SM' THEN plan.FYC_AM ELSE 0 END) smafyc, 
       NVL(SUM(plan.PAID_CS_QY),0) totcases, 
       NVL(SUM(plan.FYC_AM),0) totfyc 
 FROM YP0101.ap4_ou_cls_pl_fyc_pln plan, 
      AI0101.CUR_GO_ZONE dash 
 WHERE dash.ORG_UNIT_CD = plan.ALT_ORG_UNIT_CD (+) 
 AND '2010' = to_char(plan.PLAN_YR (+), 'yyyy') 
 GROUP BY dash.ORG_UNIT_CD, 
          INITCAP(TRIM(dash.ORG_UNIT_NM)), 
          dash.ZONE_CD 
 ORDER BY dash.ZONE_CD, INITCAP(TRIM(dash.ORG_UNIT_NM))
 
