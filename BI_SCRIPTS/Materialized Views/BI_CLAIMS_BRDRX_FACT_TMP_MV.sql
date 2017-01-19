DROP MATERIALIZED VIEW BIADMIN.BI_CLAIMS_BRDRX_FACT_TMP_MV;
CREATE MATERIALIZED VIEW BIADMIN.BI_CLAIMS_BRDRX_FACT_TMP_MV 
TABLESPACE USERS
PCTUSED    0
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
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
/* Formatted on 12/9/2016 2:25:26 PM (QP5 v5.227.12220.39754) */
SELECT a.rec_count,
       a.claim_id,
       a.item_no,
       a.policy_no,
       a.claim_no,
       a.iss_cd,
       b.branch_code,
       a.ri_cd,
       g.line_code,
       a.subline_cd,
       a.loss_year,
       a.assd_no,
       TO_CHAR (a.loss_date, 'YYYYMMDD') loss_date,
       TO_CHAR (a.clm_file_date, 'YYYYMMDD') clm_file_date,
       TO_CHAR (a.incept_date, 'YYYYMMDD') incept_date,
       TO_CHAR (a.expiry_date, 'YYYYMMDD') expiry_date,
       a.pol_iss_cd,
       a.issue_yy,
       a.pol_seq_no,
       a.renew_no,
       a.peril_cd,
       a.loss_cat_cd,
       a.ann_tsi_amt,
       a.dist_sw,
       a.convert_rate,
       NVL (a.loss_reserve, 0) loss_reserve,
       NVL (a.losses_paid, 0) losses_paid,
       NVL (a.expense_reserve, 0) expense_reserve,
       NVL (a.expenses_paid, 0) expenses_paid,
       a.grouped_item_no,
       a.clm_res_hist_id,
       a.grouped_item_title,
       a.control_cd,
       a.control_type_cd,
       a.booking_year,
       a.booking_month,
       TO_CHAR (a.date_paid, 'YYYYMMDD') date_paid,
       TO_CHAR (a.posting_date, 'YYYYMMDD') posting_date,
       a.cancel_tag,
       TO_CHAR (a.cancel_date, 'YYYYMMDD') cancel_date,
       a.tran_id,
       TO_CHAR (a.tran_date, 'YYYYMMDD') tran_date,
       a.brdrx_type,
       TO_CHAR (a.close_date, 'YYYYMMDD') close_date,
       TO_CHAR (a.close_date2, 'YYYYMMDD') close_date2,
       a.currency_rate,
       c.intm_no,
       fnget_agent (a.claim_id) intm_name,
       d.loss_cat_des,
       e.clm_stat_desc,
       a.item_title,
       f.branch_code cred_branch_code,
       h.date_paid_2 date_paid_2,
       h.posting_date_2 posting_date_2,
       h.tran_id_2,
       a.buss_source,
       a.line_cd,
       CASE
          WHEN a.booking_month IS NOT NULL AND a.booking_year IS NOT NULL
          THEN
             TO_CHAR (
                TO_DATE ('01-' || a.booking_month || '-' || a.booking_year,
                         'DD-MONTH-YYYY'),
                'YYYYMMDD')
       END
          booking_date
  FROM bi_claims_brdrx_mv a,
       bi_branch_dim b,
       giis_loss_ctgry d,
       bi_giis_clm_stat e,
       gicl_intm_itmperil c,
       bi_branch_dim f,
       bi_line_dim_mv g,
       (SELECT DISTINCT a.gacc_tran_id,
                        b.tran_id tran_id_2,
                        TO_CHAR (b.posting_date, 'YYYYMMDD') posting_date_2,
                        TO_CHAR (b.tran_date, 'YYYYMMDD') date_paid_2
          FROM giac_reversals a, giac_acctrans b
         WHERE a.reversing_tran_id = b.tran_id) h
 WHERE     a.iss_cd = b.iss_cd
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


COMMENT ON MATERIALIZED VIEW BIADMIN.BI_CLAIMS_BRDRX_FACT_TMP_MV IS 'snapshot table for snapshot BIADMIN.BI_CLAIMS_BRDRX_FACT_TMP_MV';
