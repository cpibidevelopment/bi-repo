DROP MATERIALIZED VIEW BIADMIN.BI_PRODUCTION_FACT_MV_TMP;
CREATE MATERIALIZED VIEW BIADMIN.BI_PRODUCTION_FACT_MV_TMP 
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
/* Formatted on 12/9/2016 2:35:47 PM (QP5 v5.227.12220.39754) */
SELECT a.policy_no policy_no,
       c.item_no,
       d.item_title,
       pkg_adhoc.get_line_dim (a.line_cd, a.subline_cd, c.peril_cd) line_code,
       a.agent_code,
       a.assured_code,
       a.issue_date,
       a.incept_date,
       a.exp_date,
       a.acct_ent_date,
       a.spoiled_acct_ent_date,
       (NVL (c.tsi_amt, 0) * b.currency_rt) tsi,
       (NVL (c.prem_amt, 0) * b.currency_rt) prem_amt,
       a.commission_amt commission_amt,
       a.pol_flag,
       a.spec_pol_flag spec_pol_flag,
       a.line_cd,
       f.iss_cd,
       a.prem_seq_no,
       a.currency_rt,
       a.subline_cd,
       c.peril_cd,
       a.policy_id,
       a.iss_name,
       a.booking_date,
       a.endorsement_no,
       a.renew_no,
       a.dist_flag,
       f.branch_code branch_code_dist,
       a.eff_date,
       a.check_issue_date,
       a.check_incept_date,
       a.check_booking_date,
       a.check_acct_ent_date,
       a.check_spld_acct_ent_date,
       a.endt_seq_no,
       a.policy_type,
       a.line_code line_subline_code,
       a.cred_branch_code
  FROM bi_production_tax_fact_mv a,
       gipi_invoice b,
       gipi_itmperil c,
       gipi_item d,
       bi_branch_dim f
 WHERE     a.policy_id = b.policy_id(+)
       AND a.item_grp = b.item_grp(+)
       AND b.policy_id = c.policy_id(+)
       AND c.policy_id = d.policy_id(+)
       AND c.item_no = d.item_no
       AND b.item_grp = d.item_grp
       AND f.iss_cd != giacp.v ('RI_ISS_CD')
       AND a.branch_name_dist = f.branch_name(+);


COMMENT ON MATERIALIZED VIEW BIADMIN.BI_PRODUCTION_FACT_MV_TMP IS 'snapshot table for snapshot BIADMIN.BI_PRODUCTION_FACT_MV_TMP';

CREATE INDEX BIADMIN.IDX1_BI_PRODUCTION_FACT_MV_TMP ON BIADMIN.BI_PRODUCTION_FACT_MV_TMP
(POLICY_ID, ISS_CD, PREM_SEQ_NO, AGENT_CODE)
LOGGING
TABLESPACE USERS
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
NOPARALLEL;
