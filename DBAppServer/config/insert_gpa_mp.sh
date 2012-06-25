#
# insert_gpa_mp.sh
#
sqlplus $DASH_DB_USER_PWD <<exit
set serveroutput on

VARIABLE 	records_inserted	NUMBER	
DECLARE
check_mktr	number(7);
v_cur_date	date;

BEGIN

DELETE from ai0101.gpa_mp;
COMMIT;

-- initialize counter 

:records_inserted := 0;  
SET TRANSACTION USE ROLLBACK SEGMENT RBLARGE1; 

-- Create the mp_gpa table

INSERT INTO AI0101.gpa_mp
(
ALT_ORG_UNIT_CD, 
ACTUAL_FYC_AM, 
PLANNED_FYC_AM, 
CURR_YR_NEW_ORG_PD_CS_AM ,
PRE_YR_NEW_ORG_PD_CS_AM ,
EQ_CDRT_AM ,
FYC_PLN_PC, 
POINTS_1_NO, 
PRE_YR_NEW_ORG_FYC_AM, 
CURR_YR_NEW_ORG_FYC_AM, 
PRE_YR_CURR_MO_NEW_ORG_ENH_AM, 
PRE_YR_CURR_MO_NEW_ORG_SMA_AM, 
PRE_YR_NEW_ORG_EQ_CRDT,
CURR_YR_NEW_ORG_EQ_CRDT,
NEW_ORG_FYC_GROWTH_PC, 
POINTS_2_NO, 
PRE_LF_FYC_AM, 
CURR_LF_FYC_AM, 
LF_FYC_GROWTH_PC, 
POINTS_3_NO, 
PRE_LF_PAID_CASES_QY, 
CURR_LF_PAID_CASES_QY, 
PAID_CASES_GROWTH_PC, 
POINTS_4_NO, 
PRE_YTD_ACT_AGT_QY, 
CURR_YTD_ACT_AGT_QY, 
MNPWR_GROWTH_PC, 
POINTS_5_NO, 
YTD_APPT_QY, 
YTD_AVG_RCR_QY, 
AVG_APP_PER_RCR_NO, 
POINTS_6_NO, 
RETN_3_YR_NEW_ORG_QY, 
POINTS_7_NO,
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
-- gpa scores for managing partners
--

select distinct

b.org_unit_cd ,
nvl(b.actual_fyc,0)  ,
nvl(b.planned_fyc,0) ,

nvl(b.CURR_YR_NEW_ORG_PD_CS_AM,0) ,
nvl(b.PRE_YR_NEW_ORG_PD_CS_AM,0) ,
nvl(b.ou_EQ_CRDT_AM,0) ,
 
(
case when b.planned_fyc > 0 THEN
	( (b.actual_fyc + b.ou_eq_crdt_am) / b.planned_fyc ) * 100
	else 0  
  end
) per_pln ,


(
case when (( ( (b.actual_fyc + b.ou_eq_crdt_am) / b.planned_fyc ) * 100 ) >= 110 ) then 4
     when (( ( (b.actual_fyc + b.ou_eq_crdt_am) / b.planned_fyc ) * 100 ) >= 105 ) then 3.5
     when (( ( (b.actual_fyc + b.ou_eq_crdt_am) / b.planned_fyc ) * 100 ) >= 100 ) then 3
     when (( ( (b.actual_fyc + b.ou_eq_crdt_am) / b.planned_fyc ) * 100 ) >= 95  ) then 2.5
     when (( ( (b.actual_fyc + b.ou_eq_crdt_am) / b.planned_fyc ) * 100 ) >= 90  ) then 2
     when (( ( (b.actual_fyc + b.ou_eq_crdt_am) / b.planned_fyc ) * 100 ) >= 85  ) then 1.5
     when (( ( (b.actual_fyc + b.ou_eq_crdt_am) / b.planned_fyc ) * 100 ) >= 80  ) then 1
     when (( ( (b.actual_fyc + b.ou_eq_crdt_am) / b.planned_fyc ) * 100 ) < 80   ) then 0
	else 0
  end
) points_1 ,


nvl(b.pre_yr_new_org_fyc,0)  ,

nvl(b.curr_yr_new_org_fyc,0) ,

nvl(b.pre_yr_curr_mo_new_org_enh_amt,0),

nvl(b.pre_yr_curr_mo_new_org_sma_amt,0),

b. pre_yr_new_org_eq_crdt ,
b. curr_yr_new_org_eq_crdt  ,

/* comment out the following fields, add to expressions below */

--b.cur_yr_cur_mo_new_org_sma ,

/* end of commented fields */

(
 case when ( (b.pre_yr_new_org_fyc + b.pre_yr_new_org_eq_crdt) - 
	(b.pre_yr_curr_mo_new_org_enh_amt + b.pre_yr_curr_mo_new_org_sma_amt ) ) <> 0 THEN  
  
  ( (b.curr_yr_new_org_fyc + b.curr_yr_new_org_eq_crdt)  - 
	( (b.pre_yr_new_org_fyc + b.pre_yr_new_org_eq_crdt) - (b.pre_yr_curr_mo_new_org_enh_amt + b.pre_yr_curr_mo_new_org_sma_amt ) ) ) 
	/ abs	( (b.pre_yr_new_org_fyc + b.pre_yr_new_org_eq_crdt) - (b.pre_yr_curr_mo_new_org_enh_amt + b.pre_yr_curr_mo_new_org_sma_amt ) ) * 100 
  end
) new_org_fyc_growth ,


(
case when ((( (b.curr_yr_new_org_fyc + b.curr_yr_new_org_eq_crdt) - (b.pre_yr_new_org_fyc + b.pre_yr_new_org_eq_crdt) ) / abs((b.pre_yr_new_org_fyc + b.pre_yr_new_org_eq_crdt)) * 100) >= 20 )  then 4
     when ((( (b.curr_yr_new_org_fyc + b.curr_yr_new_org_eq_crdt) - (b.pre_yr_new_org_fyc + b.pre_yr_new_org_eq_crdt) ) / abs((b.pre_yr_new_org_fyc + b.pre_yr_new_org_eq_crdt)) * 100) >= 15 )  then 3.5
     when ((( (b.curr_yr_new_org_fyc + b.curr_yr_new_org_eq_crdt) - (b.pre_yr_new_org_fyc + b.pre_yr_new_org_eq_crdt) ) / abs((b.pre_yr_new_org_fyc + b.pre_yr_new_org_eq_crdt)) * 100) >= 10 )  then 3
     when ((( (b.curr_yr_new_org_fyc + b.curr_yr_new_org_eq_crdt) - (b.pre_yr_new_org_fyc + b.pre_yr_new_org_eq_crdt) ) / abs((b.pre_yr_new_org_fyc + b.pre_yr_new_org_eq_crdt)) * 100) >= 5 )   then 2.5
     when ((( (b.curr_yr_new_org_fyc + b.curr_yr_new_org_eq_crdt) - (b.pre_yr_new_org_fyc + b.pre_yr_new_org_eq_crdt) ) / abs((b.pre_yr_new_org_fyc + b.pre_yr_new_org_eq_crdt)) * 100) >= 0 )   then 2
     when ((( (b.curr_yr_new_org_fyc + b.curr_yr_new_org_eq_crdt) - (b.pre_yr_new_org_fyc + b.pre_yr_new_org_eq_crdt) ) / abs((b.pre_yr_new_org_fyc + b.pre_yr_new_org_eq_crdt)) * 100) >= -5 )  then 1.5
     when ((( (b.curr_yr_new_org_fyc + b.curr_yr_new_org_eq_crdt) - (b.pre_yr_new_org_fyc + b.pre_yr_new_org_eq_crdt) ) / abs((b.pre_yr_new_org_fyc + b.pre_yr_new_org_eq_crdt)) * 100) >= -10 ) then 1
     when ((( (b.curr_yr_new_org_fyc + b.curr_yr_new_org_eq_crdt) - (b.pre_yr_new_org_fyc + b.pre_yr_new_org_eq_crdt) ) / abs((b.pre_yr_new_org_fyc + b.pre_yr_new_org_eq_crdt)) * 100) < -10 )  then 0
	else 0
  end
) points_2 ,


nvl(b.pre_lf_fyc,0) ,

nvl(b.curr_lf_fyc,0) ,

(
 case when b.pre_lf_fyc <> 0 THEN  
  (  b.curr_lf_fyc - b.pre_lf_fyc )  /  abs(b.pre_lf_fyc) * 100
  end
) lf_fyc_growth ,

(
case when ( ( (  b.curr_lf_fyc - b.pre_lf_fyc )  /  abs(b.pre_lf_fyc) * 100 ) >= 20  )  then 4
     when ( ( (  b.curr_lf_fyc - b.pre_lf_fyc )  /  abs(b.pre_lf_fyc) * 100 ) >= 15  )  then 3.5
     when ( ( (  b.curr_lf_fyc - b.pre_lf_fyc )  /  abs(b.pre_lf_fyc) * 100 ) >= 10  )  then 3
     when ( ( (  b.curr_lf_fyc - b.pre_lf_fyc )  /  abs(b.pre_lf_fyc) * 100 ) >= 5   )  then 2.5
     when ( ( (  b.curr_lf_fyc - b.pre_lf_fyc )  /  abs(b.pre_lf_fyc) * 100 ) >= 0   )  then 2
     when ( ( (  b.curr_lf_fyc - b.pre_lf_fyc )  /  abs(b.pre_lf_fyc) * 100 ) >= -5  )  then 1.5
     when ( ( (  b.curr_lf_fyc - b.pre_lf_fyc )  /  abs(b.pre_lf_fyc) * 100 ) >= -10 )  then 1
     when ( ( (  b.curr_lf_fyc - b.pre_lf_fyc )  /  abs(b.pre_lf_fyc) * 100 ) < -10  )  then 0
	else 0
  end
) points_3 ,

nvl(b.pre_lf_paid_cases,0) ,

nvl(b.curr_lf_paid_cases,0) ,

(
 case when b.pre_lf_paid_cases <> 0 THEN  
  (  b.curr_lf_paid_cases - b.pre_lf_paid_cases)  /  abs(b.pre_lf_paid_cases) * 100
  end
) paid_cases_growth ,

(
case when ( ( (  b.curr_lf_paid_cases - b.pre_lf_paid_cases)  /  abs(b.pre_lf_paid_cases) * 100 ) >= 15  ) then 4
     when ( ( (  b.curr_lf_paid_cases - b.pre_lf_paid_cases)  /  abs(b.pre_lf_paid_cases) * 100 ) >= 10  ) then 3.5
     when ( ( (  b.curr_lf_paid_cases - b.pre_lf_paid_cases)  /  abs(b.pre_lf_paid_cases) * 100 ) >= 5   ) then 3
     when ( ( (  b.curr_lf_paid_cases - b.pre_lf_paid_cases)  /  abs(b.pre_lf_paid_cases) * 100 ) >= 0   ) then 2.5
     when ( ( (  b.curr_lf_paid_cases - b.pre_lf_paid_cases)  /  abs(b.pre_lf_paid_cases) * 100 ) >= -5  ) then 2
     when ( ( (  b.curr_lf_paid_cases - b.pre_lf_paid_cases)  /  abs(b.pre_lf_paid_cases) * 100 ) >= -10 ) then 1.5
     when ( ( (  b.curr_lf_paid_cases - b.pre_lf_paid_cases)  /  abs(b.pre_lf_paid_cases) * 100 ) >= -15 ) then 1
     when ( ( (  b.curr_lf_paid_cases - b.pre_lf_paid_cases)  /  abs(b.pre_lf_paid_cases) * 100 ) <  -15 ) then 0
	else 0
  end
) points_4 ,


nvl(b.pre_ytd_act_agt,0) ,

nvl(b.curr_ytd_act_agt,0) ,

(
 case when b.pre_ytd_act_agt <> 0 THEN  
  (  b.curr_ytd_act_agt - b.pre_ytd_act_agt)  /  abs(b.pre_ytd_act_agt) * 100
  end
) mnpwr_growth ,


(
case when ( ( (  b.curr_ytd_act_agt - b.pre_ytd_act_agt)  /  abs(b.pre_ytd_act_agt) * 100 ) >= 25 )    then 4
     when ( ( (  b.curr_ytd_act_agt - b.pre_ytd_act_agt)  /  abs(b.pre_ytd_act_agt) * 100 ) >= 15 )    then 3.5
     when ( ( (  b.curr_ytd_act_agt - b.pre_ytd_act_agt)  /  abs(b.pre_ytd_act_agt) * 100 ) >= 5 )     then 3
     when ( ( (  b.curr_ytd_act_agt - b.pre_ytd_act_agt)  /  abs(b.pre_ytd_act_agt) * 100 ) >= 0 )     then 2.5
     when ( ( (  b.curr_ytd_act_agt - b.pre_ytd_act_agt)  /  abs(b.pre_ytd_act_agt) * 100 ) >= -5 )    then 2
     when ( ( (  b.curr_ytd_act_agt - b.pre_ytd_act_agt)  /  abs(b.pre_ytd_act_agt) * 100 ) >= -15 )   then 1.5
     when ( ( (  b.curr_ytd_act_agt - b.pre_ytd_act_agt)  /  abs(b.pre_ytd_act_agt) * 100 ) >= -20 )   then 1
     when ( ( (  b.curr_ytd_act_agt - b.pre_ytd_act_agt)  /  abs(b.pre_ytd_act_agt) * 100 ) < -20  )   then 0
	else 0
  end
) points_5 ,

 nvl(b.ytd_appt,0) ,
 
 nvl(b.ytd_avg_rcr,0) ,

(
 case when b.ytd_avg_rcr <> 0 THEN  
  (  b.ytd_appt / b.ytd_avg_rcr )   
  end
) avg_app_per_rcr ,


(
case   when ( (   b.ytd_appt / b.ytd_avg_rcr   ) >= 8 )   then 4
       when ( (   b.ytd_appt / b.ytd_avg_rcr   ) >= 7 )   then 3.5
	 when ( (   b.ytd_appt / b.ytd_avg_rcr   ) >= 6 )   then 3
	 when ( (   b.ytd_appt / b.ytd_avg_rcr   ) >= 5 )   then 2.5
	 when ( (   b.ytd_appt / b.ytd_avg_rcr   ) >= 4 )   then 2
	 when ( (   b.ytd_appt / b.ytd_avg_rcr   ) >= 3 )   then 1
	 when ( (   b.ytd_appt / b.ytd_avg_rcr   ) <  3 )   then 0
	else 0
  end
) points_6  ,


nvl(b.retn_3_yr_new_org,0) ,

(
case 	 when (  b.retn_3_yr_new_org  >= 35   )  then 4
     	 when (  b.retn_3_yr_new_org  >= 30   )  then 3.5
	 when (  b.retn_3_yr_new_org  >= 25   )  then 3
	 when (  b.retn_3_yr_new_org  >= 20   )  then 2.5
	 when (  b.retn_3_yr_new_org  >= 15   )  then 2
	 when (  b.retn_3_yr_new_org  >= 12.5 )  then 1.5
	 when (  b.retn_3_yr_new_org  >= 10   )  then 1
	 when (  b.retn_3_yr_new_org  < 10   )   then 0
	else 0
  end
) points_7 , 

nvl(b.APPT_3RD_PRIOR,0) ,

nvl(b.PRO_RATA_3RD_PRIOR,0) ,

nvl(DECODE((b.APPT_3RD_PRIOR), 0, 0, (b.PRO_RATA_3RD_PRIOR)/ (b.APPT_3RD_PRIOR)) * 100, 0)  PRIOR_3_RET_RATE ,

(
case when ((  DECODE((APPT_3RD_PRIOR), 0, 0, (PRO_RATA_3RD_PRIOR)/ (APPT_3RD_PRIOR)) * 100 )  >= 35   )    then 4
     when ((  DECODE((APPT_3RD_PRIOR), 0, 0, (PRO_RATA_3RD_PRIOR)/ (APPT_3RD_PRIOR)) * 100  ) >= 27.5 )    then 3.5
     when ((  DECODE((APPT_3RD_PRIOR), 0, 0, (PRO_RATA_3RD_PRIOR)/ (APPT_3RD_PRIOR)) * 100  ) >= 20   )    then 3
     when ((  DECODE((APPT_3RD_PRIOR), 0, 0, (PRO_RATA_3RD_PRIOR)/ (APPT_3RD_PRIOR)) * 100  ) >= 15   )    then 2.5
     when ((  DECODE((APPT_3RD_PRIOR), 0, 0, (PRO_RATA_3RD_PRIOR)/ (APPT_3RD_PRIOR)) * 100  ) >= 12.5 )    then 2	 
     when ((  DECODE((APPT_3RD_PRIOR), 0, 0, (PRO_RATA_3RD_PRIOR)/ (APPT_3RD_PRIOR)) * 100  ) >= 10   )    then 1
     when ((  DECODE((APPT_3RD_PRIOR), 0, 0, (PRO_RATA_3RD_PRIOR)/ (APPT_3RD_PRIOR)) * 100  ) <  10   )    then 0
	else 0
  end
) points_71 ,

nvl(b.APPT_2ND_PRIOR,0) ,

nvl(b.PRO_RATA_2ND_PRIOR,0) ,

nvl(DECODE((APPT_2ND_PRIOR), 0, 0, (PRO_RATA_2ND_PRIOR)/ (APPT_2ND_PRIOR)) * 100, 0)  PRIOR_2ND_RET_RATE ,

(
case when ((  DECODE((APPT_2ND_PRIOR), 0, 0, (PRO_RATA_2ND_PRIOR)/ (APPT_2ND_PRIOR)) * 100 ) >= 40   )  then 4
     when ((  DECODE((APPT_2ND_PRIOR), 0, 0, (PRO_RATA_2ND_PRIOR)/ (APPT_2ND_PRIOR)) * 100 ) >= 30   )  then 3.5
     when ((  DECODE((APPT_2ND_PRIOR), 0, 0, (PRO_RATA_2ND_PRIOR)/ (APPT_2ND_PRIOR)) * 100 ) >= 25   )  then 3
     when ((  DECODE((APPT_2ND_PRIOR), 0, 0, (PRO_RATA_2ND_PRIOR)/ (APPT_2ND_PRIOR)) * 100 ) >= 20   )  then 2.5
     when ((  DECODE((APPT_2ND_PRIOR), 0, 0, (PRO_RATA_2ND_PRIOR)/ (APPT_2ND_PRIOR)) * 100 ) >= 15   )  then 2	 
     when ((  DECODE((APPT_2ND_PRIOR), 0, 0, (PRO_RATA_2ND_PRIOR)/ (APPT_2ND_PRIOR)) * 100 ) >= 12.5 )  then 1
     when ((  DECODE((APPT_2ND_PRIOR), 0, 0, (PRO_RATA_2ND_PRIOR)/ (APPT_2ND_PRIOR)) * 100 ) <= 12.5 )  then 0
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
     when ((  DECODE((APPT_1ST_PRIOR), 0, 0, (PRO_RATA_1ST_PRIOR)/ (APPT_1ST_PRIOR)) * 100 )  >= 20  )  then 1
     when ((  DECODE((APPT_1ST_PRIOR), 0, 0, (PRO_RATA_1ST_PRIOR)/ (APPT_1ST_PRIOR)) * 100 )  <= 20  )  then 0
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
     when ((  DECODE((APPT_CURRENT), 0, 0, (ON_ROLL_CURRENT)/ (APPT_CURRENT )) * 100 )  >= 55   )  then 1
     when ((  DECODE((APPT_CURRENT), 0, 0, (ON_ROLL_CURRENT)/ (APPT_CURRENT )) * 100 )  <  55   )  then 0
	else 0
  end
) points_74 


from

(
select  a.org_unit_cd  org_unit_cd,

(
select nvl( sum(ou_fyc_total_am) + sum(ou_adj_amt) + sum(ou_enhance_amt) ,0)
from 
ai0101.ou_mnly_fyc_smy_mv, 
ai0101.data_src_load_ctrl
where ou_fyc_ef_mo_dt between trunc(ld_dt,'YEAR') and ld_dt
and src_sys_nm = 'GENERAL'
and   tgt_sys_nm = 'BATCH_REPORTING'
and alt_org_unit_cd = a.org_unit_cd
) actual_fyc ,


(
select nvl(sum(zone_pln_amt),0) 
from ai0101.ou_zone_pln, 
ai0101.data_src_load_ctrl
where zone_pln_ef_mo_dt between  trunc(ld_dt,'YEAR') and ld_dt
and src_sys_nm = 'GENERAL'
and   tgt_sys_nm = 'BATCH_REPORTING'
and alt_org_unit_cd = a.org_unit_cd
) planned_fyc  ,

/* 
   eq credit must be calc'ed in a separate expression, as the mktrs
   w/eq cr will not appear in fyc table.

   need expression to calc separately all the eq credit for new org go
   and a second exp to calc prior year new org eq cr for the go. Then 
   these can be added in outermost select. 
*/

(
select nvl (sum(mk_shr_fyc_am) + sum(adj_amt) + sum(enhance_amt) ,0)
from ai0101.mk_mnly_fyc_smy fyc ,
     ai0101.mk_cls_hist cls ,
     ai0101.mk_dashbrd dsh ,
     ai0101.data_src_load_ctrl
where dsh.mktr_no = cls.mktr_no
and dsh.mktr_no = fyc.mktr_no 
and cls.mk_cls_tp_cd in ( 1, 2, 3, 4 )
and dsh.alt_org_unit_cd = a.org_unit_cd
and src_sys_nm = 'GENERAL'
and tgt_sys_nm = 'BATCH_REPORTING'
and add_months(ld_dt, -12) between cls.mk_cls_edt and cls.mk_cls_xdt
and fyc.fyc_ef_mo_dt between to_date( '01/01/'|| ( to_char(ld_dt ,'yy') - 1 ) ,'mm/dd/yy')  and 
                       to_date(to_char(ld_dt, 'mm/dd' ) || '/' || (to_char(ld_dt, 'yy') - 1) ,'mm/dd/yy')                         
) pre_yr_new_org_fyc ,


(
select nvl(sum(nvl(eq_crdt_am,0) * nvl(pri_mult_12_no,0)), 0) 
from ai0101.mk_cls_hist cls ,
     ai0101.mk_dashbrd dsh ,
     ai0101.mk_eq_crdt eq ,
     ai0101.data_src_load_ctrl
where dsh.mktr_no = cls.mktr_no
and dsh.mktr_no = eq.mktr_no 
and cls.mk_cls_tp_cd in ( 1, 2, 3, 4 )
and dsh.alt_org_unit_cd = a.org_unit_cd
and src_sys_nm = 'GENERAL'
and tgt_sys_nm = 'BATCH_REPORTING'
and add_months(ld_dt, -12) between cls.mk_cls_edt and cls.mk_cls_xdt                        
) pre_yr_new_org_eq_crdt ,


(
select nvl(sum(mk_shr_ctcp_sld_qy),0)  
from ai0101.mk_mnly_ctcp_prm_smy prm ,
     ai0101.mk_cls_hist cls ,
     ai0101.mk_dashbrd dsh ,
     ai0101.data_src_load_ctrl
where dsh.mktr_no = cls.mktr_no
and dsh.mktr_no = prm.mktr_no
and cls.mk_cls_tp_cd in ( 1, 2, 3, 4 )
and dsh.alt_org_unit_cd = a.org_unit_cd
and src_sys_nm = 'GENERAL'
and tgt_sys_nm = 'BATCH_REPORTING'
and add_months(ld_dt, -12) between cls.mk_cls_edt and cls.mk_cls_xdt
and prm.ctcp_prm_smy_ef_mo_dt between to_date( '01/01/'|| ( to_char(ld_dt ,'yy') - 1 ) ,'mm/dd/yy')  and 
                       to_date(to_char(ld_dt, 'mm/dd' ) || '/' || (to_char(ld_dt, 'yy') - 1) ,'mm/dd/yy')                         
) pre_yr_new_org_pd_cs_am ,


(
select nvl(sum(enhance_amt),0)
from ai0101.mk_mnly_fyc_smy fyc ,
     ai0101.mk_cls_hist cls ,
     ai0101.mk_dashbrd dsh ,
     ai0101.data_src_load_ctrl
where cls.mktr_no = dsh.mktr_no
and fyc.mktr_no = dsh.mktr_no
and cls.mk_cls_tp_cd in ( 1, 2, 3, 4 )
and dsh.alt_org_unit_cd = a.org_unit_cd
and src_sys_nm = 'GENERAL'
and tgt_sys_nm = 'BATCH_REPORTING'
and add_months(ld_dt, -12) between cls.mk_cls_edt and cls.mk_cls_xdt
and to_char(fyc.fyc_ef_mo_dt,'mmyyyy') = 
	to_char(ld_dt, 'mm' ) || (to_char(ld_dt, 'yyyy') - 1)                              
) pre_yr_curr_mo_new_org_enh_amt ,


(
select nvl(sum(mk_shr_fyc_am),0)
from ai0101.mk_mnly_fyc_smy fyc ,
     ai0101.mk_cls_hist cls ,
     ai0101.mk_dashbrd dsh ,
     ai0101.data_src_load_ctrl
where cls.mktr_no = dsh.mktr_no
and fyc.mktr_no = dsh.mktr_no
and fyc.alt_prdt_line_cd = 'SM'
and cls.mk_cls_tp_cd in ( 1, 2, 3, 4 )
and dsh.alt_org_unit_cd = a.org_unit_cd
and src_sys_nm = 'GENERAL'
and tgt_sys_nm = 'BATCH_REPORTING'
and add_months(ld_dt, -12) between cls.mk_cls_edt and cls.mk_cls_xdt
and to_char(fyc.fyc_ef_mo_dt,'mmyyyy') = 
	to_char(ld_dt, 'mm' ) || (to_char(ld_dt, 'yyyy') - 1)                              
) pre_yr_curr_mo_new_org_sma_amt ,


(
select nvl(sum(mk_shr_fyc_am),0)
from ai0101.mk_mnly_fyc_smy fyc ,
     ai0101.mk_cls_hist cls ,
     ai0101.mk_dashbrd dsh ,
     ai0101.data_src_load_ctrl
where cls.mktr_no = dsh.mktr_no
and fyc.mktr_no = dsh.mktr_no
and fyc.alt_prdt_line_cd = 'SM'
and cls.mk_cls_tp_cd in ( 1, 2, 3, 4 )
and dsh.alt_org_unit_cd = a.org_unit_cd
and src_sys_nm = 'GENERAL'
and tgt_sys_nm = 'BATCH_REPORTING'
and ld_dt between cls.mk_cls_edt and cls.mk_cls_xdt
and to_char(fyc.fyc_ef_mo_dt,'mmyyyy') = 
	to_char(ld_dt, 'mm' ) || (to_char(ld_dt, 'yyyy') )                              
) cur_yr_cur_mo_new_org_sma ,



(
select nvl( sum(mk_shr_fyc_am) + sum(adj_amt) + sum(enhance_amt) ,0) 
from ai0101.mk_mnly_fyc_smy fyc ,
     ai0101.mk_cls_hist cls ,
     ai0101.mk_dashbrd dsh ,
     ai0101.data_src_load_ctrl
where dsh.mktr_no = cls.mktr_no
and dsh.mktr_no = fyc.mktr_no 
and cls.mk_cls_tp_cd in ( 1, 2, 3, 4 ) 
and dsh.alt_org_unit_cd = a.org_unit_cd
and src_sys_nm = 'GENERAL'
and tgt_sys_nm = 'BATCH_REPORTING'
and ld_dt between cls.mk_cls_edt and cls.mk_cls_xdt
and fyc.fyc_ef_mo_dt between to_date( '01/01/'|| ( to_char(ld_dt ,'yy')  ) ,'mm/dd/yy')  and ld_dt
) curr_yr_new_org_fyc ,


(
select nvl(sum(nvl(eq_crdt_am,0) * nvl(mult_12_no,0)), 0) 
from ai0101.mk_cls_hist cls ,
     ai0101.mk_dashbrd dsh ,
     ai0101.mk_eq_crdt eq,
     ai0101.data_src_load_ctrl
where dsh.mktr_no = cls.mktr_no
and dsh.mktr_no = eq.mktr_no 
and cls.mk_cls_tp_cd in ( 1, 2, 3, 4 ) 
and dsh.alt_org_unit_cd = a.org_unit_cd
and src_sys_nm = 'GENERAL'
and tgt_sys_nm = 'BATCH_REPORTING'
and ld_dt between cls.mk_cls_edt and cls.mk_cls_xdt
) curr_yr_new_org_eq_crdt ,


(
select nvl(sum(mk_shr_ctcp_sld_qy),0)
from ai0101.mk_mnly_ctcp_prm_smy prm  ,
     ai0101.mk_cls_hist cls ,
     ai0101.mk_dashbrd dsh ,
     ai0101.data_src_load_ctrl
where dsh.mktr_no = cls.mktr_no
and dsh.mktr_no = prm.mktr_no
and cls.mk_cls_tp_cd in ( 1, 2, 3, 4 ) 
and dsh.alt_org_unit_cd = a.org_unit_cd
and src_sys_nm = 'GENERAL'
and tgt_sys_nm = 'BATCH_REPORTING'
and ld_dt between cls.mk_cls_edt and cls.mk_cls_xdt
and prm.ctcp_prm_smy_ef_mo_dt between to_date( '01/01/'|| ( to_char(ld_dt ,'yy')  ) ,'mm/dd/yy')  and ld_dt
) curr_yr_new_org_pd_cs_am ,


(
select nvl(sum(eq_crdt_am * mult_12_no), 0) 
from ai0101.mk_eq_crdt eq ,
     ai0101.mk_dashbrd dsh 
where eq.mktr_no = dsh.mktr_no
and dsh.alt_org_unit_cd = a.org_unit_cd
) ou_eq_crdt_am ,


(
select nvl( sum(ou_fyc_total_am) + sum(ou_adj_amt) + sum(ou_enhance_amt),0)
from 
ai0101.ou_mnly_fyc_smy_mv, 
ai0101.data_src_load_ctrl
where ou_fyc_ef_mo_dt between to_date( '01/01/'|| ( to_char(ld_dt ,'yy') - 1 ) ,'mm/dd/yy')  and 
                      to_date(to_char(ld_dt, 'mm/dd' ) || '/' || (to_char(ld_dt, 'yy') - 1) ,'mm/dd/yy') 
and src_sys_nm = 'GENERAL'
and   tgt_sys_nm = 'BATCH_REPORTING'
and alt_prdt_line_cd in ('LF')
and alt_org_unit_cd = a.org_unit_cd
) pre_lf_fyc,


(
select nvl( sum(ou_fyc_total_am) + sum(ou_adj_amt) + sum(ou_enhance_amt),0) 
from 
ai0101.ou_mnly_fyc_smy_mv, 
ai0101.data_src_load_ctrl
where ou_fyc_ef_mo_dt between trunc(ld_dt,'YEAR') and ld_dt
and src_sys_nm = 'GENERAL'
and   tgt_sys_nm = 'BATCH_REPORTING'
and alt_prdt_line_cd in ('LF')
and alt_org_unit_cd =  a.org_unit_cd
) curr_lf_fyc ,


(
 select nvl(sum(ou_mnly_ctcp_sld_qy),0)
 from ai0101.ou_mnly_all_prm_smy a ,
      ai0101.data_src_load_ctrl
 where ou_prm_ef_mo_dt between to_date( '01/01/'|| ( to_char(ld_dt ,'yy') - 1 ) ,'mm/dd/yy')  and 
                         to_date(to_char(ld_dt, 'mm/dd' ) || '/' || (to_char(ld_dt, 'yy') - 1) ,'mm/dd/yy') 
and src_sys_nm = 'GENERAL'
and   tgt_sys_nm = 'BATCH_REPORTING'
and alt_prdt_line_cd in ('LF')
and alt_org_unit_cd = a.org_unit_cd
) pre_lf_paid_cases ,


(
 select nvl(sum(ou_mnly_ctcp_sld_qy),0)
 from ai0101.ou_mnly_all_prm_smy a ,
      ai0101.data_src_load_ctrl
 where ou_prm_ef_mo_dt between trunc(ld_dt,'YEAR') and ld_dt
 and src_sys_nm = 'GENERAL'
 and   tgt_sys_nm = 'BATCH_REPORTING'
 and alt_prdt_line_cd in ('LF')
 and alt_org_unit_cd =  a.org_unit_cd
) curr_lf_paid_cases ,


(
 SELECT nvl(sum(pri_ytd_mp),0) 
 FROM AI0101.OU_MANPOWER 
 where alt_org_unit_cd =  a.org_unit_cd
) pre_ytd_act_agt ,


(
 SELECT nvl(sum(ytd_mp),0) 
 FROM AI0101.OU_MANPOWER 
 where alt_org_unit_cd =  a.org_unit_cd
) curr_ytd_act_agt ,


(
select  sum(TOTAL_PRO_RATA)/sum(TOTAL_APPT) * 100
from ai0101.ou_retn_smy
where MK_CLS_TP_CD<>1
and orig_org_unit_cd = a.org_unit_cd
AND retn_ef_mo_dt  in    
	  (
	   select to_date(to_char(ld_dt, 'mm' ) || '/01/' || (to_char(ld_dt, 'yy') ) ,'mm/dd/yy')  
	   from   ai0101.data_src_load_ctrl
	   where src_sys_nm = 'GENERAL' and tgt_sys_nm = 'BATCH_REPORTING'
	   )
) retn_3_yr_new_org,

(
SELECT sum(nvl(recruiter.TOT_4APPT, 0)) 
FROM  ai0101.RCR_RETN_SMY recruiter
WHERE  recruiter.alt_org_unit_cd = a.org_unit_cd
) APPT_3RD_PRIOR ,  

(
SELECT  sum(nvl(recruiter.TOT_4PRATA, 0)) 
FROM  ai0101.RCR_RETN_SMY recruiter
WHERE  recruiter.alt_org_unit_cd = a.org_unit_cd
) PRO_RATA_3RD_PRIOR ,
		
(
SELECT sum(nvl(recruiter.TOT_3APPT, 0)) 
FROM  ai0101.RCR_RETN_SMY recruiter
WHERE  recruiter.alt_org_unit_cd = a.org_unit_cd
) APPT_2ND_PRIOR ,  

(
SELECT  sum(nvl(recruiter.TOT_3PRATA, 0)) 
FROM  ai0101.RCR_RETN_SMY recruiter
WHERE  recruiter.alt_org_unit_cd = a.org_unit_cd
) PRO_RATA_2ND_PRIOR ,
		
(
SELECT sum(nvl(recruiter.TOT_2APPT , 0))
FROM  ai0101.RCR_RETN_SMY recruiter
WHERE  recruiter.alt_org_unit_cd = a.org_unit_cd
) APPT_1ST_PRIOR ,  

(
SELECT  sum(nvl(recruiter.TOT_2PRATA , 0))
FROM  ai0101.RCR_RETN_SMY recruiter
WHERE  recruiter.alt_org_unit_cd = a.org_unit_cd
) PRO_RATA_1ST_PRIOR ,
		
(
SELECT sum(nvl(recruiter.TOT_1APPT ,0))
FROM  ai0101.RCR_RETN_SMY recruiter
WHERE  recruiter.alt_org_unit_cd = a.org_unit_cd
) APPT_CURRENT ,  
		
(
SELECT sum(nvl(recruiter.TOT_1ROLL,0))
FROM  ai0101.RCR_RETN_SMY recruiter
WHERE  recruiter.alt_org_unit_cd = a.org_unit_cd
) ON_ROLL_CURRENT  ,

(
SELECT nvl(SUM(h.split),0) 	   
FROM ai0101.mk_history h ,
ai0101.data_src_load_ctrl
where h.RCR_ELIG_DT BETWEEN  trunc(ld_dt,'YEAR') and ld_dt
and src_sys_nm = 'GENERAL'
and tgt_sys_nm = 'BATCH_REPORTING'
and h.orig_org_unit_cd = a.org_unit_cd
)	ytd_appt ,	   

(       select  ( COUNT(alt_org_unit_cd) / (p.period) ) 
		FROM ai0101.RCR_MGMT_HISTORY  , 
			 (
			 SELECT 
		  	 		MONTHS_BETWEEN					
				(					
			    ( 
				select to_date( to_char(ld_dt,'mm') || '/01/'|| to_char(ld_dt,'yyyy') ,'mm/dd/yy')
			    from   ai0101.data_src_load_ctrl
			    where src_sys_nm = 'GENERAL' and tgt_sys_nm = 'BATCH_REPORTING'
				) ,
					
				(select to_date( '12/01/'|| ( to_char(ld_dt ,'yy') - 1 ) ,'mm/dd/yy')  
				from   ai0101.data_src_load_ctrl
				where src_sys_nm = 'GENERAL' and tgt_sys_nm = 'BATCH_REPORTING' 
				)
				
				) period 
						
		        FROM dual
			  ) p
		WHERE TITLE != '0A'
			  AND alt_org_unit_cd =  a.org_unit_cd
			  AND YEAR_MO_DT BETWEEN 			  
			   (
			   select to_date( '01/01/'|| ( to_char(ld_dt ,'yyyy') ) ,'mm/dd/yyyy')  
			   from   ai0101.data_src_load_ctrl
			   where src_sys_nm = 'GENERAL' and tgt_sys_nm = 'BATCH_REPORTING'
			   )		  
			  			  
			  AND 
			  
			  (
			   select to_date( to_char(ld_dt,'mm') || '/01/'|| to_char(ld_dt,'yyyy') ,'mm/dd/yyyy')
			   from   ai0101.data_src_load_ctrl
			   where src_sys_nm = 'GENERAL' and tgt_sys_nm = 'BATCH_REPORTING'
			   )
			  			
		GROUP BY p.period
		
		
) ytd_avg_rcr 


from

(
select distinct org_unit_cd
from ai0101.cur_go_zone  a  
where   a.zone_cd <> 'XX' 

) a

) b

-- end of select 
--
;

COMMIT;

select count(*) into :records_inserted
from ai0101.gpa_mp;

EXCEPTION
    WHEN OTHERS THEN
	DBMS_OUTPUT.PUT_LINE(SQLCODE);
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
        ROLLBACK;

END;
/
PRINT records_inserted
exit
