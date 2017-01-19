DROP MATERIALIZED VIEW BIADMIN.BI_CLAIMS_LOSSES_PAID_MV;
CREATE MATERIALIZED VIEW BIADMIN.BI_CLAIMS_LOSSES_PAID_MV 
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
/* Formatted on 12/9/2016 2:34:07 PM (QP5 v5.227.12220.39754) */
SELECT a.policy_id,
       a.claim_id,
       a.policy_no,
       a.claim_no,
       a.clm_res_hist_id,
       h.line_code,
       i.branch_code,
       a.assd_no assured_code,
       a.pol_eff_date effectivity_date,
       d.clm_stat_desc claim_status,
       e.clm_stat_desc claim_status_grp,
       a.loss_date,
       a.date_paid,
       a.losses_paid,
       a.expenses_paid,
       a.peril_cd,
       a.file_date,
       a.cancel_date,
       a.cancel_tag,
       a.tran_date,
       a.tran_id,
       a.loss_cat_des,
       a.item_no,
       a.pol_iss_cd,
       a.dist_sw,
       a.tran_flag,
       a.issue_source,
       a.shr_pct,
       j.branch_code claims_branch_code,
       convert_rate
  FROM bi_claims_losses_paid_mv_tmp a,
       bi_giis_clm_stat d,
       bi_giis_clm_stat e,
       giis_issource g,
       bi_line_dim_mv h,
       bi_branch_dim i,
       bi_branch_dim j
 WHERE     a.clm_stat_cd = d.clm_stat_cd
       AND a.clm_stat_cd = e.clm_stat_cd
       AND a.pol_iss_cd = g.iss_cd(+)
       AND a.line_cd = h.line_cd(+)
       AND a.subline_cd = h.subline_cd(+)
       AND a.peril_cd = h.peril_cd(+)
       AND g.iss_cd = i.iss_cd(+)
       AND a.iss_cd = j.iss_cd(+);


COMMENT ON MATERIALIZED VIEW BIADMIN.BI_CLAIMS_LOSSES_PAID_MV IS 'snapshot table for snapshot BIADMIN.BI_CLAIMS_LOSSES_PAID_MV';
