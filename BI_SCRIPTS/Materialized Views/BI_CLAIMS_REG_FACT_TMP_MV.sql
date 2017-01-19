CREATE MATERIALIZED VIEW BIADMIN.BI_CLAIMS_REG_FACT_TMP_MV 
TABLESPACE USERS
PCTUSED    0
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOCACHE
LOGGING
NOCOMPRESS
NOPARALLEL
BUILD IMMEDIATE
REFRESH FORCE ON DEMAND
WITH PRIMARY KEY
AS 
/* Formatted on 2016/08/31 14:21 (Formatter Plus v4.8.8) */
SELECT a.claim_id, a.claim_no, a.item_no, a.policy_no, a.clm_res_hist_id,
       c.clm_stat_desc, a.prem_amt, a.loss_reserve, a.losses_paid,
       a.expense_reserve, a.expenses_paid, a.ann_tsi_amt, a.assd_no,
       TO_CHAR (a.clm_file_date, 'YYYYMMDD') clm_file_date,
       TO_CHAR (a.dsp_loss_date, 'YYYYMMDD') dsp_loss_date,
       b.branch_code clm_iss_branch,
       TO_CHAR (a.loss_date, 'YYYYMMDD') loss_date,
       TO_CHAR (a.pol_eff_date, 'YYYYMMDD') eff_date,
       TO_CHAR (a.expiry_date, 'YYYYMMDD') exp_date,
       get_gpa_item_title (a.claim_id,
                           a.line_cd,
                           a.item_no,
                           NVL (a.grouped_item_no, 0)
                          ) item_title,
       fnget_agent (a.claim_id) AGENT,
       NVL (a.converted_recovered_amt, 0) recovered_amt, a.cancel_tag,
       TO_CHAR (a.cancel_date, 'YYYYMMDD') cancel_date,
       d.branch_code pol_iss_branch, e.line_code
  FROM bi_claims_reg_mv a,
       bi_branch_dim b,
       bi_giis_clm_stat c,
       bi_branch_dim d,
       bi_line_dim_mv e
 WHERE a.iss_cd = b.iss_cd
   AND a.clm_stat_cd = c.clm_stat_cd
   AND a.pol_iss_cd = d.iss_cd
   AND a.line_cd = e.line_cd
   AND a.peril_cd = e.peril_cd
   AND a.subline_cd = e.subline_cd;

COMMENT ON MATERIALIZED VIEW BIADMIN.BI_CLAIMS_REG_FACT_TMP_MV IS 'snapshot table for snapshot BIADMIN.BI_CLAIMS_REG_FACT_TMP_MV';

