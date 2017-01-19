CREATE MATERIALIZED VIEW BIADMIN.BI_PROD_DIST_FACT_MV 
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
/* Formatted on 2016/08/31 13:42 (Formatter Plus v4.8.8) */
SELECT a.policy_id, a.policy_no, b.line_code, c.branch_code,
       d.branch_code cred_branch_code, e.rv_meaning pol_flag,
       f.rv_meaning dist_flag, TO_CHAR (a.eff_date, 'YYYYMMDD') eff_date,
       TO_CHAR (a.issue_date, 'YYYYMMDD') issue_date, a.booking_date,
       TO_CHAR (a.acct_ent_date, 'YYYYMMDD') acct_ent_date,
       TO_CHAR (a.acct_neg_date, 'YYYYMMDD') acct_neg_date, a.nr_dist_tsi,
       a.nr_dist_prem, a.nr_dist_spct, a.tr_dist_tsi, a.tr_dist_prem,
       a.tr_dist_spct, a.fa_dist_tsi, a.fa_dist_prem, a.endorsement_no,
       a.spec_pol_flag, a.assured_code
  FROM bi_prod_dist_fact_mv_tmp a,                       --, bi_dist_mv_tmp a,
       bi_line_dim_mv b,
       bi_branch_dim c,
       bi_branch_dim d,
       cg_ref_codes e,
       cg_ref_codes f
 WHERE a.line_cd = b.line_cd(+)
   AND a.subline_cd = b.subline_cd(+)
   AND NVL (a.peril_cd, -1) = NVL (b.peril_cd, -1)
   AND a.iss_cd = c.iss_cd(+)
   AND a.branch_cd_dist = d.iss_cd(+)
   AND e.rv_domain = 'GIPI_POLBASIC.POL_FLAG'
   AND e.rv_low_value = a.pol_flag
   AND f.rv_low_value = a.dist_flag
   AND f.rv_domain = 'GIPI_POLBASIC.DIST_FLAG';

COMMENT ON MATERIALIZED VIEW BIADMIN.BI_PROD_DIST_FACT_MV IS 'snapshot table for snapshot BIADMIN.BI_PROD_DIST_FACT_MV';

