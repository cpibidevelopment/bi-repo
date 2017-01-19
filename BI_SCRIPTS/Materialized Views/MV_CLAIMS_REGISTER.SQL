SET SERVEROUTPUT ON
SET FEEDBACK  OFF  


BEGIN  
 DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------------------------'); 
 DBMS_OUTPUT.PUT_LINE('##Processing Materialized Views-Production##');
 DBMS_OUTPUT.PUT_LINE('Dropping Materialized Views...');  
END;   
/

BEGIN
process_object('bi_claims_reg_mv',  'MATERIALIZED VIEW','DROP');
process_object('bi_claims_reg_fact_tmp_mv',  'MATERIALIZED VIEW','DROP');
END;
/


CREATE MATERIALIZED VIEW BI_CLAIMS_REG_MV 
AS 
SELECT a.claim_id, a.line_cd, a.subline_cd, a.pol_iss_cd, a.issue_yy, a.pol_seq_no, a.renew_no, a.iss_cd, TO_NUMBER (TO_CHAR (a.loss_date, 'yyyy')) loss_year, a.assd_no,
       get_claim_number (a.claim_id) claim_no,
       (a.line_cd || '-' || a.subline_cd || '-' || a.pol_iss_cd || '-' || LTRIM (TO_CHAR (a.issue_yy, '09')) || '-' || LTRIM (TO_CHAR (a.pol_seq_no, '0999999')) || '-'
        || LTRIM (TO_CHAR (a.renew_no, '09'))
       ) policy_no,
       a.clm_file_date, a.dsp_loss_date, a.loss_date, a.pol_eff_date, a.expiry_date, a.clm_stat_cd, a.loss_cat_cd, a.ri_cd, b.converted_recovered_amt,
       fnget_tot_prem_amt (a.claim_id, c.item_no, c.peril_cd) prem_amt, c.item_no, c.peril_cd, c.ann_tsi_amt, c.loss_reserve, c.losses_paid, c.expense_reserve, c.expenses_paid,
       c.grouped_item_no, c.clm_res_hist_id, DECODE (a.pol_iss_cd, giacp.v ('RI_ISS_CD'), giacp.v ('RI_ISS_CD'), NULL) intm_type,
       DECODE (a.pol_iss_cd, giacp.v ('RI_ISS_CD'), a.ri_cd, NULL) buss_source, c.cancel_tag, c.cancel_date
  FROM gicl_claims a,
       (SELECT   claim_id, SUM (NVL (recovered_amt * convert_rate, 0)) converted_recovered_amt
            FROM gicl_clm_recovery
        GROUP BY claim_id) b,
       (SELECT   b.claim_id, b.item_no, b.peril_cd, b.loss_cat_cd, NVL (a.convert_rate, 1) convert_rate, (b.ann_tsi_amt * NVL (a.convert_rate, 1)) ann_tsi_amt,
                 SUM (DECODE (a.dist_sw, 'Y', NVL (a.convert_rate, 1) * NVL (a.loss_reserve, 0), 0)) loss_reserve,
                 SUM (DECODE (a.dist_sw, NULL, NVL (a.convert_rate, 1) * NVL (a.losses_paid, 0), 0)) losses_paid,
                 SUM (DECODE (a.dist_sw, 'Y', NVL (a.convert_rate, 1) * NVL (a.expense_reserve, 0), 0)) expense_reserve,
                 SUM (DECODE (a.dist_sw, NULL, NVL (a.convert_rate, 1) * NVL (a.expenses_paid, 0), 0)) expenses_paid, a.grouped_item_no, c.clm_res_hist_id, a.cancel_tag, a.cancel_date
            FROM gicl_clm_res_hist a,
                 gicl_item_peril b,
                 (SELECT DISTINCT claim_id, item_no, peril_cd, clm_res_hist_id, grouped_item_no
                             FROM gicl_reserve_ds
                            WHERE NVL (negate_tag, 'N') <> 'Y') c
           WHERE a.peril_cd = b.peril_cd
             AND a.item_no = b.item_no
             AND a.claim_id = b.claim_id
             AND NVL (a.dist_sw, 'Y') = 'Y'
--                        AND b.loss_cat_cd =
--                                        NVL (:p_dsp_loss_cat_cd, b.loss_cat_cd)
             AND a.claim_id = c.claim_id
             AND a.item_no = c.item_no
             AND a.peril_cd = c.peril_cd
             AND a.grouped_item_no = c.grouped_item_no
        GROUP BY b.claim_id, b.item_no, b.peril_cd, b.loss_cat_cd, NVL (a.convert_rate, 1), b.ann_tsi_amt, a.grouped_item_no, c.clm_res_hist_id, a.cancel_tag, a.cancel_date) c
 WHERE 1 = 1 AND b.claim_id(+) = a.claim_id AND a.claim_id = c.claim_id;



CREATE MATERIALIZED VIEW BI_CLAIMS_REG_FACT_TMP_MV 
AS 
SELECT a.claim_id, a.claim_no, a.item_no, a.policy_no, a.clm_res_hist_id, c.clm_stat_desc, a.prem_amt, a.loss_reserve, a.losses_paid, a.expense_reserve, a.expenses_paid, a.ann_tsi_amt, a.assd_no,
       TO_CHAR (a.clm_file_date, 'YYYYMMDD') clm_file_date, TO_CHAR (a.dsp_loss_date, 'YYYYMMDD') dsp_loss_date, b.branch_code clm_iss_branch, TO_CHAR (a.loss_date, 'YYYYMMDD') loss_date,
       TO_CHAR (a.pol_eff_date, 'YYYYMMDD') eff_date, TO_CHAR (a.expiry_date, 'YYYYMMDD') exp_date, get_gpa_item_title (a.claim_id, a.line_cd, a.item_no, NVL (a.grouped_item_no, 0)) item_title,
       fnget_agent (a.claim_id) AGENT, NVL (a.converted_recovered_amt, 0) recovered_amt, a.cancel_tag, TO_CHAR (a.cancel_date, 'YYYYMMDD') cancel_date, d.branch_code pol_iss_branch, e.line_code
  FROM bi_claims_reg_mv a, bi_branch_dim b, bi_giis_clm_stat c, bi_branch_dim d, bi_line_dim_mv e
 WHERE a.iss_cd = b.iss_cd AND a.clm_stat_cd = c.clm_stat_cd AND a.pol_iss_cd = d.iss_cd AND a.line_cd = e.line_cd AND a.peril_cd = e.peril_cd AND a.subline_cd = e.subline_cd;
