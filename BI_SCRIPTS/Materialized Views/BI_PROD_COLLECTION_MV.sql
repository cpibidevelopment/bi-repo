CREATE MATERIALIZED VIEW BIADMIN.BI_PROD_COLLECTION_MV 
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
/* Formatted on 2016/08/31 13:44 (Formatter Plus v4.8.8) */
SELECT c.agent_name, a.policy_no, d.line_name, d.subline_name,
       pkg_adhoc.get_time (a.booking_date) booking_date,
       pkg_adhoc.get_time (a.issue_date) issue_date,
       pkg_adhoc.get_time (a.incept_date) incept_date,
       pkg_adhoc.get_time (a.spoiled_acct_ent_date) spoiled_acct_ent_date,
       pkg_adhoc.get_time (a.acct_ent_date) acct_ent_date,
       pkg_adhoc.get_time (a.eff_date) effective_date,
       pkg_adhoc.get_time (b.tran_date) tran_date,
       pkg_adhoc.get_time (b.pos_date) pos_date, b.premium_amount premium,
       b.collection_amount, spec_pol_flag, renew_no, endt_seq_no,
       e.branch_name cred_branch
  FROM bi_production_tax_fact a,
       bi_collection_tax_fact b,
       bi_agent_dim c,
       bi_line_sub_line_dim d,
       bi_branch_dim e
 WHERE a.endorsement_no = b.policy_no(+)
   AND a.agent_code = c.agent_code(+)
   AND a.line_code = d.line_code(+)
   AND a.cred_branch_code = e.branch_code(+);

COMMENT ON MATERIALIZED VIEW BIADMIN.BI_PROD_COLLECTION_MV IS 'snapshot table for snapshot BIADMIN.BI_PROD_COLLECTION_MV';

