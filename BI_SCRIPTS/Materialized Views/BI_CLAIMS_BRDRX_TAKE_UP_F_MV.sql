DROP MATERIALIZED VIEW BIADMIN.BI_CLAIMS_BRDRX_TAKE_UP_F_MV;
CREATE MATERIALIZED VIEW BIADMIN.BI_CLAIMS_BRDRX_TAKE_UP_F_MV 
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
/* Formatted on 12/9/2016 2:25:54 PM (QP5 v5.227.12220.39754) */
SELECT a.claim_id,
       a.claim_no,
       a.policy_no,
       a.ann_tsi_amt,
       a.assd_no,
       a.buss_source,
       a.clm_res_hist_id,
       a.grouped_item_no,
       a.iss_cd,
       a.item_no,
       a.line_cd,
       a.loss_cat_cd,
       a.loss_year,
       NVL (a.os_expense, 0) os_expense,
       NVL (a.os_loss, 0) os_loss,
       a.peril_cd,
       a.pol_iss_cd,
       a.subline_cd,
       a.tran_flag,
       TO_CHAR (a.acct_date, 'YYYYMMDD') acct_date,
       TO_CHAR (a.clm_file_date, 'YYYYMMDD') clm_file_date,
       TO_CHAR (a.expiry_date, 'YYYYMMDD') expiry_date,
       TO_CHAR (a.incept_date, 'YYYYMMDD') incept_date,
       TO_CHAR (a.loss_date, 'YYYYMMDD') loss_date,
       TO_CHAR (a.posting_date, 'YYYYMMDD') posting_date,
       TO_CHAR (a.tran_date, 'YYYYMMDD') tran_date,
       b.branch_code iss_branch_code,
       c.branch_code pol_iss_branch_code,
       d.line_code,
       e.loss_cat_des,
       a.item_title
  FROM bi_claims_brdrx_take_up a,
       bi_branch_dim b,
       bi_branch_dim c,
       bi_line_dim_mv d,
       giis_loss_ctgry e
 WHERE     a.iss_cd = b.iss_cd
       AND a.pol_iss_cd = c.iss_cd
       AND a.line_cd = d.line_cd
       AND a.peril_cd = d.peril_cd
       AND a.subline_cd = d.subline_cd
       AND a.line_cd = e.line_cd(+)
       AND a.loss_cat_cd = e.loss_cat_cd(+);


COMMENT ON MATERIALIZED VIEW BIADMIN.BI_CLAIMS_BRDRX_TAKE_UP_F_MV IS 'snapshot table for snapshot BIADMIN.BI_CLAIMS_BRDRX_TAKE_UP_F_MV';
