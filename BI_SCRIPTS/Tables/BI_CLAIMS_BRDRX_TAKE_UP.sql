DROP MATERIALIZED VIEW BIADMIN.BI_CLAIMS_BRDRX_TAKE_UP;
CREATE MATERIALIZED VIEW BIADMIN.BI_CLAIMS_BRDRX_TAKE_UP 
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
/* Formatted on 12/9/2016 2:25:46 PM (QP5 v5.227.12220.39754) */
SELECT a.claim_id,
       get_claim_number (c.claim_id) claim_no,
       (   c.line_cd
        || '-'
        || c.subline_cd
        || '-'
        || c.pol_iss_cd
        || '-'
        || LTRIM (TO_CHAR (c.issue_yy, '09'))
        || '-'
        || LTRIM (TO_CHAR (c.pol_seq_no, '0999999'))
        || '-'
        || LTRIM (TO_CHAR (c.renew_no, '09')))
          policy_no,
       a.item_no,
       a.peril_cd,
       b.loss_cat_cd,
       (b.ann_tsi_amt * NVL (a.convert_rate, 1)) ann_tsi_amt,
       d.os_loss /** NVL (a.convert_rate, 1)*/
                 --expense and loss in gicl_take_up_hist is already in local currency mlachica 02172014
                 os_loss,
       --convert Loss to local currency by MAC 09/17/2013.
       d.os_expense /** NVL (a.convert_rate, 1)*/
                    --expense and loss in gicl_take_up_hist is already in local currency mlachica 02172014
                    os_expense,
       --convert Expense to local currency by MAC 09/17/2013.
       a.grouped_item_no,
       a.clm_res_hist_id,
       c.iss_cd,
       0 buss_source,
       c.line_cd,
       c.subline_cd,
       TO_NUMBER (TO_CHAR (c.loss_date, 'YYYY')) loss_year,
       c.assd_no,
       c.dsp_loss_date loss_date,
       c.clm_file_date,
       c.pol_eff_date incept_date,
       c.expiry_date,
       c.pol_iss_cd,
       d.acct_date,
       e.posting_date,
       e.tran_flag,
       e.tran_date,
       f.item_title
  FROM gicl_clm_res_hist a,
       gicl_item_peril b,
       gicl_claims c,
       gicl_take_up_hist d,
       giac_acctrans e,
       gicl_clm_item f
 WHERE     a.claim_id = b.claim_id
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


COMMENT ON MATERIALIZED VIEW BIADMIN.BI_CLAIMS_BRDRX_TAKE_UP IS 'snapshot table for snapshot BIADMIN.BI_CLAIMS_BRDRX_TAKE_UP';
