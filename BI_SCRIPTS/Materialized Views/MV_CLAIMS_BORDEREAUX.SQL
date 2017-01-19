SET SERVEROUTPUT ON
SET FEEDBACK  OFF  


BEGIN  
 DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------------------------'); 
 DBMS_OUTPUT.PUT_LINE('##Processing Materialized Views-Production##');
 DBMS_OUTPUT.PUT_LINE('Dropping Materialized Views...');  
END;   
/

BEGIN
process_object('bi_claims_brdrx_mv',  'MATERIALIZED VIEW','DROP');
process_object('bi_claims_brdrx_fact_tmp_mv',  'MATERIALIZED VIEW','DROP');
process_object('bi_claims_brdrx_take_up',  'MATERIALIZED VIEW','DROP');
process_object('bi_claims_brdrx_take_up_f_mv',  'MATERIALIZED VIEW','DROP');
process_object('bi_claims_brdrx_dist_os_mv',  'MATERIALIZED VIEW','DROP');
process_object('bi_claims_brdrx_dist_lp_mv',  'MATERIALIZED VIEW','DROP');
END;
/


CREATE MATERIALIZED VIEW BI_CLAIMS_BRDRX_MV 
AS 
SELECT ROWNUM rec_count, a.claim_id, a.item_no, a.peril_cd, b.loss_cat_cd, b.ann_tsi_amt, b.close_date, b.close_date2, g.currency_rate,
                                                                                                                                       /*(b.ann_tsi_amt * NVL (g.currency_rate, 1) ) ann_tsi_amt, */
                                                                                                                                       a.dist_sw, a.loss_reserve, a.losses_paid,
       a.expense_reserve, a.expenses_paid, a.convert_rate, a.tran_id, a.grouped_item_no,
       a.clm_res_hist_id, a.cancel_date, a.cancel_tag, e.grouped_item_title, e.control_cd, e.control_type_cd, c.iss_cd, c.ri_cd, c.line_cd, c.subline_cd,
       TO_NUMBER (TO_CHAR (c.loss_date, 'YYYY')) loss_year, c.assd_no, get_claim_number (c.claim_id) claim_no,
       (c.line_cd || '-' || c.subline_cd || '-' || c.pol_iss_cd || '-' || LTRIM (TO_CHAR (c.issue_yy, '09')) || '-' || LTRIM (TO_CHAR (c.pol_seq_no, '0999999')) || '-'
        || LTRIM (TO_CHAR (c.renew_no, '09'))
       ) policy_no,
       c.dsp_loss_date loss_date, c.clm_file_date, c.pol_eff_date incept_date, c.expiry_date, c.pol_iss_cd, c.issue_yy, c.pol_seq_no, c.renew_no, c.clm_stat_cd, a.booking_month, a.booking_year,
       a.date_paid, d.posting_date, f.brdrx_type, d.tran_date, g.item_title, c.cred_branch, NVL (c.ri_cd, 0) buss_source
  FROM gicl_clm_res_hist a,
       gicl_item_peril b,
       gicl_claims c,
       (SELECT tran_id, tran_flag, posting_date, tran_date
          FROM giac_acctrans
         WHERE 1 = 2 AND tran_flag != 'D') d,
       (SELECT claim_id, item_no, grouped_item_no, grouped_item_title, control_type_cd, control_cd
          FROM gicl_accident_dtl
         WHERE 0 = 1) e,
       (SELECT DISTINCT claim_id, item_no, peril_cd, clm_res_hist_id, grouped_item_no, 'Outstanding' brdrx_type
                   FROM gicl_reserve_ds
                  WHERE NVL (negate_tag, 'N') <> 'Y') f,
       gicl_clm_item g
 WHERE a.claim_id = b.claim_id
   AND a.claim_id = (SELECT v.claim_id
                       FROM (SELECT   claim_id, NVL (SUM (loss_reserve), 0) lr, NVL (SUM (losses_paid), 0) lp, NVL (SUM (expense_reserve), 0) er, NVL (SUM (expenses_paid), 0) ep
                                 FROM gicl_clm_res_hist
                                WHERE (dist_sw != 'N' OR dist_sw IS NULL)
                             GROUP BY claim_id) v
                      WHERE ((lr - lp) > 0 OR (er - ep) > 0) AND v.claim_id = a.claim_id)
   AND a.item_no = b.item_no
   AND a.peril_cd = b.peril_cd
   AND a.claim_id = c.claim_id
   AND a.tran_id = d.tran_id(+)
   AND a.claim_id = e.claim_id(+)
   AND a.item_no = e.item_no(+)
   AND a.grouped_item_no = e.grouped_item_no(+)
   AND a.claim_id = f.claim_id(+)
   AND a.item_no = f.item_no(+)
   AND a.peril_cd = f.peril_cd(+)
   AND a.grouped_item_no = f.grouped_item_no(+)
   AND b.claim_id = g.claim_id
   AND b.item_no = g.item_no
UNION ALL
SELECT ROWNUM rec_count, a.claim_id, a.item_no, a.peril_cd, b.loss_cat_cd, b.ann_tsi_amt, b.close_date, b.close_date2, g.currency_rate,
                                                                                                                                       /*(b.ann_tsi_amt * NVL (g.currency_rate, 1) ) ann_tsi_amt, */
                                                                                                                                       a.dist_sw, a.loss_reserve, a.losses_paid,
       a.expense_reserve, a.expenses_paid, a.convert_rate, a.tran_id, a.grouped_item_no,
       a.clm_res_hist_id, a.cancel_date, a.cancel_tag, e.grouped_item_title, e.control_cd, e.control_type_cd, c.iss_cd, c.ri_cd, c.line_cd, c.subline_cd,
       TO_NUMBER (TO_CHAR (c.loss_date, 'YYYY')) loss_year, c.assd_no, get_claim_number (c.claim_id) claim_no,
       (c.line_cd || '-' || c.subline_cd || '-' || c.pol_iss_cd || '-' || LTRIM (TO_CHAR (c.issue_yy, '09')) || '-' || LTRIM (TO_CHAR (c.pol_seq_no, '0999999')) || '-'
        || LTRIM (TO_CHAR (c.renew_no, '09'))
       ) policy_no,
       c.dsp_loss_date loss_date, c.clm_file_date, c.pol_eff_date incept_date, c.expiry_date, c.pol_iss_cd, c.issue_yy, c.pol_seq_no, c.renew_no, c.clm_stat_cd, a.booking_month, a.booking_year,
       a.date_paid, d.posting_date, f.brdrx_type, d.tran_date, g.item_title, c.cred_branch, NVL (c.ri_cd, 0) buss_source
  FROM gicl_clm_res_hist a,
       gicl_item_peril b,
       gicl_claims c,
       (SELECT tran_id, tran_flag, posting_date, tran_date
          FROM giac_acctrans
         WHERE 2 = 2 AND tran_flag != 'D') d,
       (SELECT claim_id, item_no, grouped_item_no, grouped_item_title, control_type_cd, control_cd
          FROM gicl_accident_dtl
         WHERE 0 = 1) e,
       (SELECT DISTINCT claim_id, item_no, peril_cd, NULL clm_res_hist_id, grouped_item_no, 'Losses Paid' brdrx_type
                   FROM gicl_loss_exp_ds) f,
       gicl_clm_item g
 WHERE a.claim_id = b.claim_id
   AND a.claim_id = (SELECT v.claim_id
                       FROM (SELECT   claim_id, NVL (SUM (loss_reserve), 0) lr, NVL (SUM (losses_paid), 0) lp, NVL (SUM (expense_reserve), 0) er, NVL (SUM (expenses_paid), 0) ep
                                 FROM gicl_clm_res_hist
                                WHERE tran_id IS NOT NULL
                             GROUP BY claim_id) v
                      WHERE v.claim_id = a.claim_id)
   AND a.item_no = b.item_no
   AND a.peril_cd = b.peril_cd
   AND a.claim_id = c.claim_id
   AND a.tran_id = d.tran_id
   AND a.claim_id = e.claim_id(+)
   AND a.item_no = e.item_no(+)
   AND a.grouped_item_no = e.grouped_item_no(+)
   AND a.claim_id = f.claim_id(+)
   AND a.item_no = f.item_no(+)
   AND a.peril_cd = f.peril_cd(+)
   AND a.grouped_item_no = f.grouped_item_no(+)
   AND b.claim_id = g.claim_id
   AND b.item_no = g.item_no;

  BEGIN
DBMS_OUTPUT.PUT_LINE('bi_claims_brdrx_mv--created....');  
END;   
/


CREATE MATERIALIZED VIEW BI_CLAIMS_BRDRX_FACT_TMP_MV
AS 
SELECT a.rec_count, a.claim_id, a.item_no, a.policy_no, a.claim_no, a.iss_cd, b.branch_code, a.ri_cd, g.line_code, a.subline_cd, a.loss_year, a.assd_no, TO_CHAR (a.loss_date, 'YYYYMMDD') loss_date,
       TO_CHAR (a.clm_file_date, 'YYYYMMDD') clm_file_date, TO_CHAR (a.incept_date, 'YYYYMMDD') incept_date, TO_CHAR (a.expiry_date, 'YYYYMMDD') expiry_date, a.pol_iss_cd, a.issue_yy, a.pol_seq_no,
       a.renew_no, a.peril_cd, a.loss_cat_cd, a.ann_tsi_amt, a.dist_sw, a.convert_rate, NVL (a.loss_reserve, 0) loss_reserve, NVL (a.losses_paid, 0) losses_paid,
       NVL (a.expense_reserve, 0) expense_reserve, NVL (a.expenses_paid, 0) expenses_paid, a.grouped_item_no, a.clm_res_hist_id, a.grouped_item_title, a.control_cd, a.control_type_cd, a.booking_year,
       a.booking_month, TO_CHAR (a.date_paid, 'YYYYMMDD') date_paid, TO_CHAR (a.posting_date, 'YYYYMMDD') posting_date, a.cancel_tag, TO_CHAR (a.cancel_date, 'YYYYMMDD') cancel_date, a.tran_id,
       TO_CHAR (a.tran_date, 'YYYYMMDD') tran_date, a.brdrx_type, TO_CHAR (a.close_date, 'YYYYMMDD') close_date, TO_CHAR (a.close_date2, 'YYYYMMDD') close_date2, a.currency_rate, c.intm_no,
       fnget_agent (a.claim_id) intm_name, d.loss_cat_des, e.clm_stat_desc, a.item_title, f.branch_code cred_branch_code, h.date_paid_2 date_paid_2, h.posting_date_2 posting_date_2, h.tran_id_2,
       a.buss_source, a.line_cd,
       CASE
          WHEN a.booking_month IS NOT NULL AND a.booking_year IS NOT NULL THEN TO_CHAR (TO_DATE ('01-' || a.booking_month || '-' || a.booking_year, 'DD-MONTH-YYYY'), 'YYYYMMDD')
       END booking_date
  FROM bi_claims_brdrx_mv a,
       bi_branch_dim b,
       giis_loss_ctgry d,
       bi_giis_clm_stat e,
       gicl_intm_itmperil c,
       bi_branch_dim f,
       bi_line_dim_mv g,
       (SELECT DISTINCT a.gacc_tran_id, b.tran_id tran_id_2, TO_CHAR (b.posting_date, 'YYYYMMDD') posting_date_2, TO_CHAR (b.tran_date, 'YYYYMMDD') date_paid_2
                   FROM giac_reversals a, giac_acctrans b
                  WHERE a.reversing_tran_id = b.tran_id) h
 WHERE a.iss_cd = b.iss_cd
   AND a.line_cd = d.line_cd(+)
   AND a.loss_cat_cd = d.loss_cat_cd(+)
   AND a.clm_stat_cd = e.clm_stat_cd
   AND a.claim_id = c.claim_id(+)
   AND a.item_no = c.item_no(+)
   AND a.peril_cd = c.peril_cd(+)
   AND a.cred_branch = f.iss_cd(+)
   AND a.line_cd = g.line_cd
   AND a.peril_cd = g.peril_cd
   AND a.subline_cd = g.subline_cd
   AND a.tran_id = h.gacc_tran_id(+);

  BEGIN
DBMS_OUTPUT.PUT_LINE('bi_claims_brdrx_fact_tmp_mv--created....');  
END;   
/


CREATE MATERIALIZED VIEW BI_CLAIMS_BRDRX_TAKE_UP 
AS 
SELECT a.claim_id, get_claim_number (c.claim_id) claim_no,
       (c.line_cd || '-' || c.subline_cd || '-' || c.pol_iss_cd || '-' || LTRIM (TO_CHAR (c.issue_yy, '09')) || '-' || LTRIM (TO_CHAR (c.pol_seq_no, '0999999')) || '-'
        || LTRIM (TO_CHAR (c.renew_no, '09'))
       ) policy_no,
       a.item_no, a.peril_cd, b.loss_cat_cd, (b.ann_tsi_amt * NVL (a.convert_rate, 1)) ann_tsi_amt, d.os_loss
/** NVL (a.convert_rate, 1)*/
--expense and loss in gicl_take_up_hist is already in local currency mlachica 02172014
       os_loss,
               --convert Loss to local currency by MAC 09/17/2013.
               d.os_expense
/** NVL (a.convert_rate, 1)*/
--expense and loss in gicl_take_up_hist is already in local currency mlachica 02172014
       os_expense,
                  --convert Expense to local currency by MAC 09/17/2013.
                  a.grouped_item_no, a.clm_res_hist_id, c.iss_cd, 0 buss_source, c.line_cd, c.subline_cd, TO_NUMBER (TO_CHAR (c.loss_date, 'YYYY')) loss_year, c.assd_no, c.dsp_loss_date loss_date,
       c.clm_file_date, c.pol_eff_date incept_date, c.expiry_date, c.pol_iss_cd, d.acct_date, e.posting_date, e.tran_flag, e.tran_date, f.item_title
  FROM gicl_clm_res_hist a, gicl_item_peril b, gicl_claims c, gicl_take_up_hist d, giac_acctrans e, gicl_clm_item f
 WHERE a.claim_id = b.claim_id
   AND a.item_no = b.item_no
   AND a.peril_cd = b.peril_cd
   AND a.claim_id = c.claim_id
   AND a.claim_id = d.claim_id
   AND a.clm_res_hist_id = d.clm_res_hist_id
   AND d.acct_tran_id = e.tran_id
   AND (NVL (d.os_loss, 0) + NVL (d.os_expense, 0) > 0)
   AND b.claim_id = f.claim_id
   AND b.item_no = f.item_no
   AND e.tran_flag = 'P';


  BEGIN
DBMS_OUTPUT.PUT_LINE('bi_claims_brdrx_take_up--created....');  
END;   
/


CREATE MATERIALIZED VIEW BI_CLAIMS_BRDRX_TAKE_UP_F_MV 
AS 
SELECT a.claim_id, a.claim_no, a.policy_no, a.ann_tsi_amt, a.assd_no, a.buss_source, a.clm_res_hist_id, a.grouped_item_no, a.iss_cd, a.item_no, a.line_cd, a.loss_cat_cd, a.loss_year,
       NVL (a.os_expense, 0) os_expense, NVL (a.os_loss, 0) os_loss, a.peril_cd, a.pol_iss_cd, a.subline_cd, a.tran_flag, TO_CHAR (a.acct_date, 'YYYYMMDD') acct_date,
       TO_CHAR (a.clm_file_date, 'YYYYMMDD') clm_file_date, TO_CHAR (a.expiry_date, 'YYYYMMDD') expiry_date, TO_CHAR (a.incept_date, 'YYYYMMDD') incept_date,
       TO_CHAR (a.loss_date, 'YYYYMMDD') loss_date, TO_CHAR (a.posting_date, 'YYYYMMDD') posting_date, TO_CHAR (a.tran_date, 'YYYYMMDD') tran_date, b.branch_code iss_branch_code,
       c.branch_code pol_iss_branch_code, d.line_code, e.loss_cat_des, a.item_title
  FROM bi_claims_brdrx_take_up a, bi_branch_dim b, bi_branch_dim c, bi_line_dim_mv d, giis_loss_ctgry e
 WHERE a.iss_cd = b.iss_cd AND a.pol_iss_cd = c.iss_cd AND a.line_cd = d.line_cd AND a.peril_cd = d.peril_cd AND a.subline_cd = d.subline_cd AND a.line_cd = e.line_cd(+) AND a.loss_cat_cd = e.loss_cat_cd(+);


  BEGIN
DBMS_OUTPUT.PUT_LINE('bi_claims_brdrx_take_up_f_mv--created....');  
END;   
/

CREATE MATERIALIZED VIEW BI_CLAIMS_BRDRX_DIST_OS_MV
AS
SELECT *
  FROM (SELECT DISTINCT a.rec_count, a.claim_id, a.item_no, a.policy_no, a.claim_no, a.iss_cd, /*branch_code,*/ a.ri_cd, a.line_code, a.subline_cd, a.loss_year, a.assd_no, a.loss_date,
                        a.clm_file_date, a.incept_date, a.expiry_date, a.pol_iss_cd, a.issue_yy, a.pol_seq_no, a.renew_no, a.peril_cd, a.loss_cat_cd, a.ann_tsi_amt, a.dist_sw, a.convert_rate,
                        a.loss_reserve, a.losses_paid, a.expense_reserve, a.expenses_paid, a.grouped_item_no, a.clm_res_hist_id, a.grouped_item_title, a.control_cd, a.control_type_cd, a.booking_year,
                        a.booking_month, a.date_paid, a.posting_date, a.cancel_tag, a.cancel_date, a.tran_id, a.tran_date, a.brdrx_type, a.close_date, a.close_date2, a.currency_rate, a.intm_no,
                        a.buss_source, a.line_cd,
                                                 /*fnget_claims_validate_max(a.claim_id ,a.item_no , a.peril_cd, a.grouped_item_no,'01-jan-2014', '28-feb-2014',1,1) clm_res_hist_id2 ,*/
                                                 b.shr_pct, b.grp_seq_no, c.shr_ri_pct_real, c.ri_cd ri_cd2, b.clm_res_hist_id clm_res_hist_id2, c.grp_seq_no grp_seq_no2, a.booking_date
                   FROM bi_claims_brdrx_fact_tmp_mv a, gicl_reserve_ds b, gicl_reserve_rids c
                  WHERE a.peril_cd = b.peril_cd(+)
                    AND a.item_no = b.item_no(+)
                    AND a.claim_id = b.claim_id(+)
                    AND a.grouped_item_no = b.grouped_item_no(+)
                    AND a.brdrx_type = 'Outstanding'
                    AND b.grp_seq_no = c.grp_seq_no(+)
                    AND b.clm_dist_no = c.clm_dist_no(+)
                    AND b.clm_res_hist_id = c.clm_res_hist_id(+)
                    AND b.claim_id = c.claim_id(+)
                                                  /*AND TRUNC(TO_DATE(a.loss_date, 'YYYY-MM-DD')) BETWEEN '01-JAN-2014' AND '28-FEB-2014'
                                                             AND NVL (TO_DATE(a.date_paid, 'YYYY-MM-DD'), '28-FEB-2014') BETWEEN '01-JAN-2014' AND '28-FEB-2014'
                                                             AND (   DECODE (a.cancel_tag,
                                                                             'Y', TRUNC (TO_DATE(a.cancel_date, 'YYYY-MM-DD')),
                                                                             DECODE (1,
                                                                                     1, (TO_DATE('28-FEB-2014') + 1),
                                                                                     2, (TO_DATE(null) + 1)
                                                                                    )
                                                                            ) >
                                                                        DECODE (1,
                                                                                1, '28-FEB-2014',
                                                                                2, null
                                                                               )
                                                                 )
                                                             AND ( (TO_DATE(a.close_date, 'YYYY-MM-DD') > TRUNC(SYSDATE) OR TO_DATE(a.close_date, 'YYYY-MM-DD') IS NULL)
                                                                   OR (TO_DATE(a.close_date2, 'YYYY-MM-DD') > TRUNC(SYSDATE) OR TO_DATE(a.close_date2, 'YYYY-MM-DD') IS NULL) */
       );

  BEGIN
DBMS_OUTPUT.PUT_LINE('bi_claims_brdrx_dist_os_mv--created....');  
END;   
/


CREATE MATERIALIZED VIEW BI_CLAIMS_BRDRX_DIST_LP_MV 
AS 
SELECT *
  FROM (SELECT DISTINCT a.rec_count, a.claim_id, a.item_no, a.policy_no, a.claim_no, a.iss_cd, /*branch_code,*/ a.ri_cd, a.line_code, a.subline_cd, a.loss_year, a.assd_no, a.loss_date,
                        a.clm_file_date, a.incept_date, a.expiry_date, a.pol_iss_cd, a.issue_yy, a.pol_seq_no, a.renew_no, a.peril_cd, a.loss_cat_cd, a.ann_tsi_amt, a.dist_sw, a.convert_rate,
                        a.loss_reserve, a.losses_paid, a.expense_reserve, a.expenses_paid, a.grouped_item_no, a.clm_res_hist_id, a.grouped_item_title, a.control_cd, a.control_type_cd, a.booking_year,
                        a.booking_month, a.date_paid, a.posting_date, a.cancel_tag, a.cancel_date, a.tran_id, a.tran_date, a.brdrx_type, a.close_date, a.close_date2, a.currency_rate, a.intm_no,
                        a.buss_source, a.line_cd,
                                                 /*fnget_claims_validate_max(a.claim_id ,a.item_no , a.peril_cd, a.grouped_item_no,'01-jan-2014', '28-feb-2014',1,1) clm_res_hist_id2 ,*/
                                                 b.shr_pct, b.grp_seq_no, c.shr_ri_pct_real, c.ri_cd ri_cd2, b.clm_res_hist_id clm_res_hist_id2, c.grp_seq_no grp_seq_no2
                   FROM bi_claims_brdrx_fact_tmp_mv a, gicl_reserve_ds b, gicl_reserve_rids c
                  WHERE a.peril_cd = b.peril_cd(+)
                    AND a.item_no = b.item_no(+)
                    AND a.claim_id = b.claim_id(+)
                    AND a.grouped_item_no = b.grouped_item_no(+)
                    AND a.brdrx_type = 'Losses Paid'
                    AND b.grp_seq_no = c.grp_seq_no(+)
                    AND b.clm_dist_no = c.clm_dist_no(+)
                    AND b.clm_res_hist_id = c.clm_res_hist_id(+)
                    AND b.claim_id = c.claim_id(+)
                                                  /*AND TRUNC(TO_DATE(a.loss_date, 'YYYY-MM-DD')) BETWEEN '01-JAN-2014' AND '28-FEB-2014'
                                                             AND NVL (TO_DATE(a.date_paid, 'YYYY-MM-DD'), '28-FEB-2014') BETWEEN '01-JAN-2014' AND '28-FEB-2014'
                                                             AND (   DECODE (a.cancel_tag,
                                                                             'Y', TRUNC (TO_DATE(a.cancel_date, 'YYYY-MM-DD')),
                                                                             DECODE (1,
                                                                                     1, (TO_DATE('28-FEB-2014') + 1),
                                                                                     2, (TO_DATE(null) + 1)
                                                                                    )
                                                                            ) >
                                                                        DECODE (1,
                                                                                1, '28-FEB-2014',
                                                                                2, null
                                                                               )
                                                                 )
                                                             AND ( (TO_DATE(a.close_date, 'YYYY-MM-DD') > TRUNC(SYSDATE) OR TO_DATE(a.close_date, 'YYYY-MM-DD') IS NULL)
                                                                   OR (TO_DATE(a.close_date2, 'YYYY-MM-DD') > TRUNC(SYSDATE) OR TO_DATE(a.close_date2, 'YYYY-MM-DD') IS NULL) */
       );


  BEGIN
DBMS_OUTPUT.PUT_LINE('bi_claims_brdrx_dist_lp_mv--created....');  
END;   
/

  
BEGIN  
DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------------------------'); 
END;  
/
