#
# insert_gpa_ptn.sh
#
sqlplus $DASH_DB_USER_PWD <<exit
set serveroutput on

VARIABLE 	records_inserted	NUMBER	
DECLARE
check_mktr	number(7);
v_cur_date	date;

BEGIN

DELETE from ai0101.gpa_ptn;
COMMIT;

-- initialize counter 

:records_inserted := 0;  
SET TRANSACTION USE ROLLBACK SEGMENT RBLARGE1; 

-- Create the gpa_ptn table

INSERT INTO AI0101.gpa_ptn
(
MKTR_NO, 
YTD_CP_PASSED_QY, 
YTD_MNTH_ACT_QY, 
PT_QY, 
POINTS_1_NO, 
NEW_AGT_APPT_QY, 
POINTS_2_NO, 
QUALITY_AGT_QY, 
POINTS_3_NO, 
AVG_LF_CASES_QY, 
POINTS_4_NO, 
MNPWR_DEV_QY, 
POINTS_5_NO, 
POP_PC, 
POINTS_6_NO, 
APPT_3RD_PRIOR_QY, 
PRO_RATA_3RD_PRIOR_QY, 
PRIOR_3_RET_RT, 
POINTS_71_NO, 
APPT_2ND_PRIOR_QY, 
PRO_RATA_2ND_PRIOR_QY, 
PRIOR_2ND_RET_RT, 
POINTS_72_NO, 
APPT_1ST_PRIOR_QY, 
PRO_RATA_1ST_PRIOR_QY, 
PRIOR_1ST_RET_RT, 
POINTS_73_NO, 
APPT_CURRENT_QY, 
ON_ROLL_CURRENT_QY, 
ON_ROLL_RET_RT, 
POINTS_74_NO
)

--
-- gpa scores for partners
--

select distinct 

--- Partners 
b.rcr_no ,


--- point_1 

nvl(b.ytd_cp_passed,0) ,
nvl(b.ytd_mnth_act,0) , 
nvl(b.pt_ct,0) ,

(
case when ( DECODE((b.ytd_mnth_act),0,0 ,(b.ytd_cp_passed + pt_ct) / b.ytd_mnth_act)  >= 8  )   then 4
     when ( DECODE((b.ytd_mnth_act),0,0 ,(b.ytd_cp_passed + pt_ct) / b.ytd_mnth_act) >= 7   )   then 3.5
     when ( DECODE((b.ytd_mnth_act),0,0 ,(b.ytd_cp_passed + pt_ct) / b.ytd_mnth_act) >= 6   )   then 3
     when ( DECODE((b.ytd_mnth_act),0,0 ,(b.ytd_cp_passed + pt_ct) / b.ytd_mnth_act) >= 5   )   then 2.5
     when ( DECODE((b.ytd_mnth_act),0,0 ,(b.ytd_cp_passed + pt_ct) / b.ytd_mnth_act) >= 4   )   then 2
     when ( DECODE((b.ytd_mnth_act),0,0 ,(b.ytd_cp_passed + pt_ct) / b.ytd_mnth_act) >= 3.5 )   then 1.5
     when ( DECODE((b.ytd_mnth_act),0,0 ,(b.ytd_cp_passed + pt_ct) / b.ytd_mnth_act) >= 3.0 )   then 1.0
     when ( DECODE((b.ytd_mnth_act),0,0 ,(b.ytd_cp_passed + pt_ct) / b.ytd_mnth_act)  < 3.0 )   then 0
	else 0
 end
) points_1 ,

--- point_2

nvl(b.new_agt_appt,0) ,

(
case when ((  b.new_agt_appt ) >= 8   )   then 4
     when ((  b.new_agt_appt ) >= 7   )   then 3.5
     when ((  b.new_agt_appt ) >= 6   )   then 3
     when ((  b.new_agt_appt ) >= 5   )   then 2.5
     when ((  b.new_agt_appt ) >= 4   )   then 2
     when ((  b.new_agt_appt ) <  4   )   then 0
	else 0
  end
) points_2 ,

--- point_3

nvl(b.quality_agt_ct,0) , 

(
case when ((  b.quality_agt_ct ) >= 6   )   then 4
     when ((  b.quality_agt_ct ) >= 5   )   then 3.5
     when ((  b.quality_agt_ct ) >= 4   )   then 3
     when ((  b.quality_agt_ct ) >= 2   )   then 2.5
     when ((  b.quality_agt_ct ) <  1   )   then 0
	else 0 
 end
)points_3 ,

--- point_4

--b.qty ,
--b.no_month ,


nvl(DECODE( b.no_month,0,0,b.qty / b.no_month ), 0) avg_lf_cases ,

(
case when ((  DECODE(b.no_month,0,0,b.qty / b.no_month)  ) >= 6   )   then 4
     when ((  DECODE(b.no_month,0,0,b.qty / b.no_month)  ) >= 5   )   then 3.5
     when ((  DECODE(b.no_month,0,0,b.qty / b.no_month)  ) >= 4   )   then 3
     when ((  DECODE(b.no_month,0,0,b.qty / b.no_month)  ) >= 3   )   then 2.5
     when ((  DECODE(b.no_month,0,0,b.qty / b.no_month)  ) >= 2.5 )   then 2
     when ((  DECODE(b.no_month,0,0,b.qty / b.no_month)  ) >= 2.0 )   then 1.5
     when ((  DECODE(b.no_month,0,0,b.qty / b.no_month)  ) >= 1.0 )   then 1.0
     when ((  DECODE(b.no_month,0,0,b.qty / b.no_month)  ) < 1    )   then 0
	else 0
  end

) points_4 ,

--- point_5

nvl(b.mnpwr_dev_ct,0) ,

(
case when ((  b.mnpwr_dev_ct ) >= 2   )   then 4
     when ((  b.mnpwr_dev_ct ) >= 1   )   then 3.5
     when ((  b.mnpwr_dev_ct ) >= 0   )   then 3
     when ((  b.mnpwr_dev_ct ) >= -1  )   then 2.5
     when ((  b.mnpwr_dev_ct ) >= -2  )   then 2
     when ((  b.mnpwr_dev_ct ) >= -3  )   then 1.5
     when ((  b.mnpwr_dev_ct ) >= -4  )   then 1.0
     when ((  b.mnpwr_dev_ct ) < -4   )   then 0
	else 0
  end
) points_5 ,

--- point_6

nvl(b.per_pop,0) ,

(
case when ((  b.per_pop ) >= 165   )    then 4
     when ((  b.per_pop ) >= 135   )    then 3.5
     when ((  b.per_pop ) >= 100   )    then 3
     when ((  b.per_pop ) >=  90   )    then 2.5
     when ((  b.per_pop ) >=  80   )    then 2
     when ((  b.per_pop ) >=  70   )    then 1.5
     when ((  b.per_pop ) >=  60   )    then 1
     when ((  b.per_pop ) <=  60   )    then 0
	else 0
  end
) points_6 ,

--- point_7

nvl(b.APPT_3RD_PRIOR,0) ,

nvl(b.PRO_RATA_3RD_PRIOR,0) ,

nvl(DECODE((b.APPT_3RD_PRIOR), 0, 0, (b.PRO_RATA_3RD_PRIOR)/ (b.APPT_3RD_PRIOR)) * 100, 0)  PRIOR_3_RET_RATE ,

(
case when ((  DECODE((APPT_3RD_PRIOR), 0, 0, (PRO_RATA_3RD_PRIOR)/ (APPT_3RD_PRIOR)) * 100 )  >= 35   )    then 4
     when ((  DECODE((APPT_3RD_PRIOR), 0, 0, (PRO_RATA_3RD_PRIOR)/ (APPT_3RD_PRIOR)) * 100  ) >= 27.5 )    then 3.5
     when ((  DECODE((APPT_3RD_PRIOR), 0, 0, (PRO_RATA_3RD_PRIOR)/ (APPT_3RD_PRIOR)) * 100  ) >= 20   )    then 3
     when ((  DECODE((APPT_3RD_PRIOR), 0, 0, (PRO_RATA_3RD_PRIOR)/ (APPT_3RD_PRIOR)) * 100  ) >= 15   )    then 2.5
     when ((  DECODE((APPT_3RD_PRIOR), 0, 0, (PRO_RATA_3RD_PRIOR)/ (APPT_3RD_PRIOR)) * 100  ) >= 12.5 )    then 2	 
     when ((  DECODE((APPT_3RD_PRIOR), 0, 0, (PRO_RATA_3RD_PRIOR)/ (APPT_3RD_PRIOR)) * 100  ) >=  10  )    then 1
     when ((  DECODE((APPT_3RD_PRIOR), 0, 0, (PRO_RATA_3RD_PRIOR)/ (APPT_3RD_PRIOR)) * 100  ) <  10   )    then 0
	else 0
  end
) points_71 ,

nvl(b.APPT_2ND_PRIOR,0) ,

nvl(b.PRO_RATA_2ND_PRIOR,0) ,

nvl(DECODE((APPT_2ND_PRIOR), 0, 0, (PRO_RATA_2ND_PRIOR)/ (APPT_2ND_PRIOR)) * 100, 0)  PRIOR_2ND_RET_RATE ,

(
case when ((  DECODE((APPT_2ND_PRIOR), 0, 0, (PRO_RATA_2ND_PRIOR)/ (APPT_2ND_PRIOR)) * 100 )  >= 40  )  then 4
     when ((  DECODE((APPT_2ND_PRIOR), 0, 0, (PRO_RATA_2ND_PRIOR)/ (APPT_2ND_PRIOR)) * 100 ) >= 30   )  then 3.5
     when ((  DECODE((APPT_2ND_PRIOR), 0, 0, (PRO_RATA_2ND_PRIOR)/ (APPT_2ND_PRIOR)) * 100 ) >= 25   )  then 3
     when ((  DECODE((APPT_2ND_PRIOR), 0, 0, (PRO_RATA_2ND_PRIOR)/ (APPT_2ND_PRIOR)) * 100 ) >= 20   )  then 2.5
     when ((  DECODE((APPT_2ND_PRIOR), 0, 0, (PRO_RATA_2ND_PRIOR)/ (APPT_2ND_PRIOR)) * 100 ) >= 15   )  then 2	 
     when ((  DECODE((APPT_2ND_PRIOR), 0, 0, (PRO_RATA_2ND_PRIOR)/ (APPT_2ND_PRIOR)) * 100 ) >=  12.5 ) then 1
     when ((  DECODE((APPT_2ND_PRIOR), 0, 0, (PRO_RATA_2ND_PRIOR)/ (APPT_2ND_PRIOR)) * 100 ) <=  12.5 ) then 0
	else 0
  end
) points_72 ,

nvl(b.APPT_1ST_PRIOR,0) ,

nvl(b.PRO_RATA_1ST_PRIOR,0) ,

nvl(DECODE((APPT_1ST_PRIOR), 0, 0, (PRO_RATA_1ST_PRIOR)/ (APPT_1ST_PRIOR)) * 100, 0)  PRIOR_1ST_RET_RATE ,

(
case when ((  DECODE((APPT_1ST_PRIOR), 0, 0, (PRO_RATA_1ST_PRIOR)/ (APPT_1ST_PRIOR)) * 100 )  >= 50  )  then 4
     when ((  DECODE((APPT_1ST_PRIOR), 0, 0, (PRO_RATA_1ST_PRIOR)/ (APPT_1ST_PRIOR)) * 100 )  >= 40  )  then 3.5
     when ((  DECODE((APPT_1ST_PRIOR), 0, 0, (PRO_RATA_1ST_PRIOR)/ (APPT_1ST_PRIOR)) * 100 )  >= 35  )  then 3
     when ((  DECODE((APPT_1ST_PRIOR), 0, 0, (PRO_RATA_1ST_PRIOR)/ (APPT_1ST_PRIOR)) * 100)   >= 30  )  then 2.5
     when ((  DECODE((APPT_1ST_PRIOR), 0, 0, (PRO_RATA_1ST_PRIOR)/ (APPT_1ST_PRIOR)) * 100 )  >= 25  )  then 2	 
     when ((  DECODE((APPT_1ST_PRIOR), 0, 0, (PRO_RATA_1ST_PRIOR)/ (APPT_1ST_PRIOR)) * 100 )  >=  20 ) then 1
     when ((  DECODE((APPT_1ST_PRIOR), 0, 0, (PRO_RATA_1ST_PRIOR)/ (APPT_1ST_PRIOR)) * 100 )  <=  20 ) then 0
	else 0
  end
) points_73 ,

nvl(b.APPT_CURRENT,0) ,

nvl(b.ON_ROLL_CURRENT,0) ,

nvl(DECODE((APPT_CURRENT), 0, 0, (ON_ROLL_CURRENT)/ (APPT_CURRENT )) * 100, 0)  ON_ROLL_RET_RATE ,

(
case when ((  DECODE((APPT_CURRENT), 0, 0, (ON_ROLL_CURRENT)/ (APPT_CURRENT )) * 100 )  >= 87.5 )  then 4
     when ((  DECODE((APPT_CURRENT), 0, 0, (ON_ROLL_CURRENT)/ (APPT_CURRENT )) * 100 )  >= 85   )  then 3.5
     when ((  DECODE((APPT_CURRENT), 0, 0, (ON_ROLL_CURRENT)/ (APPT_CURRENT )) * 100 )  >= 80   )  then 3
     when ((  DECODE((APPT_CURRENT), 0, 0, (ON_ROLL_CURRENT)/ (APPT_CURRENT )) * 100 )  >= 75   )  then 2.5
     when ((  DECODE((APPT_CURRENT), 0, 0, (ON_ROLL_CURRENT)/ (APPT_CURRENT )) * 100 )  >= 65   )  then 2	 
     when ((  DECODE((APPT_CURRENT), 0, 0, (ON_ROLL_CURRENT)/ (APPT_CURRENT )) * 100 )  >=  55  )  then 1
     when ((  DECODE((APPT_CURRENT), 0, 0, (ON_ROLL_CURRENT)/ (APPT_CURRENT )) * 100 )  <  55  )   then 0
	else 0
  end
) points_74 

---

from

(
select a.rcr_no ,
	   
(
select nvl(sum(cp_passed), 0) 
from ai0101.rcr_cp_smy ,
     ai0101.data_src_load_ctrl
where rcr_mk_no = a.rcr_no  
and cp_period between trunc(ld_dt,'YEAR') and ld_dt
and src_sys_nm = 'GENERAL'
and tgt_sys_nm = 'BATCH_REPORTING'
) ytd_cp_passed ,

(
select nvl(sum(hist.split), 0)
from  ai0101.marketer mktr, 
      ai0101.mk_history hist, 
      ai0101.data_src_load_ctrl 
where hist.mktr_no = mktr.mktr_no 
and 	hist.rel_mktr_no = a.rcr_no 
AND 	mktr.ea_pgm_ind in ('P','T')
AND 	hist.rcr_elig_dt between trunc(ld_dt,'YEAR') and ld_dt
and 	src_sys_nm = 'GENERAL'
and 	tgt_sys_nm = 'BATCH_REPORTING'
) pt_ct,
	   
( 	   
select  distinct 

	( case when to_char(mk_ttl_edt,'yyyy') = to_char(ld_dt,'yyyy') 
			then  months_between( last_day(ld_dt) , last_day(mk_ttl_edt) )
	       when to_char(ld_dt,'yyyy') > to_char(mk_ttl_edt,'yyyy') 
			then  months_between( last_day(ld_dt) , last_day(trunc(ld_dt ,'YEAR') - 1 ) )
	  end 
	) no_month
		
FROM AI0101.MK_DASHBRD D,
     AI0101.MK_TTL_ATV T,
     AI0101.mk_org_hist_v G,
     AI0101.MK_STS_ATV S,
     ai0101.data_src_load_ctrl
WHERE D.MK_TTL_TP_CD IN ('0F')  
AND S.MK_STS_TP_CD IN ('01', '04') 
AND T.MKTR_NO = D.MKTR_NO
AND T.MKTR_NO = G.MKTR_NO 
AND T.MKTR_NO = S.MKTR_NO 
AND ld_dt BETWEEN T.MK_TTL_EDT AND  T.MK_TTL_XDT 
AND ld_dt BETWEEN G.MK_ORG_EDT AND  G.MK_ORG_XDT
AND ld_dt BETWEEN S.MK_STS_ATV_EDT AND  S.MK_STS_ATV_XDT  
and src_sys_nm = 'GENERAL'
and tgt_sys_nm = 'BATCH_REPORTING' 
and d.mktr_no =  a.rcr_no  	     
) ytd_mnth_act, 
   

(
Select nvl(sum(hist.split), 0) 
FROM  ai0101.MK_DASHBRD dash, 
      ai0101.MK_HISTORY hist ,
      ai0101.data_src_load_ctrl 
WHERE  hist.rcr_elig_dt BETWEEN trunc(ld_dt,'YEAR') and ld_dt
and src_sys_nm = 'GENERAL'
and tgt_sys_nm = 'BATCH_REPORTING' 
AND hist.rel_mktr_no = dash.mktr_no
AND dash.ALT_ORG_UNIT_CD = hist.orig_org_unit_cd
AND hist.rel_mktr_no = a.rcr_no 
) new_agt_appt  ,

	   
-- count all the agents, not just those in the GO
(
select nvl(sum(hist.split), 0)  
from ai0101.mk_manpower mp, 
     ai0101.mk_history hist
where hist.MKTR_NO = mp.MKTR_NO
and hist.REL_MKTR_NO = a.rcr_no 
and mp.QA_IND = '1'
) quality_agt_ct ,


-- only count agents hired since rcr started in GO
(
select nvl(sum(hist.split), 0)  
from  ai0101.mk_history hist,
      ai0101.mk_manpower mp
where hist.MKTR_NO = mp.MKTR_NO
and   hist.REL_MKTR_NO = a.rcr_no
and   hist.ORIG_APPT_DT >= 
	(select max(mk_org_edt) from ai0101.mk_org_hist_v where mktr_no = a.rcr_no) 
and mp.MD_IND = '1'
) mnpwr_dev_ct ,
	   
  
(
select  (pop.ytd_fyc / pop.prort_perf_tgt ) * 100
from ai0101.rcr_pop_score pop 
where pop.rcr_no = a.rcr_no 
) per_pop ,
			
	
(
SELECT nvl(recruiter.TOT_4APPT, 0) 
FROM  ai0101.RCR_RETN_SMY recruiter
WHERE  recruiter.RCR_MK_NO = a.rcr_no 
) APPT_3RD_PRIOR ,  

(
SELECT  nvl(recruiter.TOT_4PRATA, 0) 
FROM  ai0101.RCR_RETN_SMY recruiter
WHERE  recruiter.RCR_MK_NO = a.rcr_no 
) PRO_RATA_3RD_PRIOR ,
		
(
SELECT nvl(recruiter.TOT_3APPT, 0) 
FROM  ai0101.RCR_RETN_SMY recruiter
WHERE  recruiter.RCR_MK_NO = a.rcr_no 
) APPT_2ND_PRIOR ,  

(
SELECT  nvl(recruiter.TOT_3PRATA, 0) 
FROM  ai0101.RCR_RETN_SMY recruiter
WHERE  recruiter.RCR_MK_NO = a.rcr_no 
) PRO_RATA_2ND_PRIOR ,
		
(
SELECT nvl(recruiter.TOT_2APPT , 0)
FROM  ai0101.RCR_RETN_SMY recruiter
WHERE  recruiter.RCR_MK_NO = a.rcr_no 
) APPT_1ST_PRIOR ,  

(
SELECT  nvl(recruiter.TOT_2PRATA , 0)
FROM  ai0101.RCR_RETN_SMY recruiter
WHERE  recruiter.RCR_MK_NO = a.rcr_no 
) PRO_RATA_1ST_PRIOR ,
		
(
SELECT nvl(recruiter.TOT_1APPT ,0)
FROM  ai0101.RCR_RETN_SMY recruiter
WHERE  recruiter.RCR_MK_NO = a.rcr_no 
) APPT_CURRENT ,  
		
(
SELECT nvl(recruiter.TOT_1ROLL,0)
FROM  ai0101.RCR_RETN_SMY recruiter
WHERE  recruiter.RCR_MK_NO = a.rcr_no 
) ON_ROLL_CURRENT  ,

(
select nvl (sum(nvl(mp.ytd_cntr_mo_ct,0)), 0)        
from  ai0101.mk_history hist ,
      ai0101.mk_manpower mp 
where hist.REL_MKTR_NO = a.rcr_no
and   ( hist.mktr_no = mp.mktr_no )
and   ( hist.orig_appt_dt >=  
	  	( select max(mk_org_edt) from   ai0101.mk_org_hist_v where mktr_no = a.rcr_no ) )  
) no_month ,

(
select nvl( sum(nvl(mp.ytd_lf_cs_ct,0)), 0)        
from  ai0101.mk_history hist ,
      ai0101.mk_manpower mp 
where hist.REL_MKTR_NO = a.rcr_no
and   ( hist.mktr_no = mp.mktr_no )
and   ( hist.orig_appt_dt >=  
	  	( select max(mk_org_edt) from   ai0101.mk_org_hist_v where mktr_no = a.rcr_no ) )  
) qty 

from 

----- Partner inline view 

(
SELECT distinct D.MKTR_NO rcr_no
FROM AI0101.MK_DASHBRD D,
     AI0101.MK_TTL_ATV T,    
     AI0101.MK_STS_ATV S ,
     ai0101.data_src_load_ctrl
WHERE     
       D.MK_TTL_TP_CD IN ('0F')  
       AND S.MK_STS_TP_CD IN ('01', '04') 
       AND T.MKTR_NO = D.MKTR_NO
       AND T.MKTR_NO = S.MKTR_NO 
       AND ld_dt BETWEEN T.MK_TTL_EDT AND  T.MK_TTL_XDT 
       AND ld_dt BETWEEN S.MK_STS_ATV_EDT AND  S.MK_STS_ATV_XDT  
       and src_sys_nm = 'GENERAL'
       and tgt_sys_nm = 'BATCH_REPORTING' 
) a 

) b

-- end of select 
--
;

COMMIT;

select count(*) into :records_inserted
from ai0101.gpa_ptn;

EXCEPTION
    WHEN OTHERS THEN
	DBMS_OUTPUT.PUT_LINE(SQLCODE);
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
        ROLLBACK;

END;
/
PRINT records_inserted
exit
