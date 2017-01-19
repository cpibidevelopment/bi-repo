CREATE MATERIALIZED VIEW BIADMIN.BI_PRODUCTION_TAX_FACT_MV 
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
/* Formatted on 2016/08/25 14:51 (Formatter Plus v4.8.8) */
SELECT a.policy_no policy_no, c.line_code line_code,
       d.intrmdry_intm_no agent_code, a.assd_no assured_code, a.issue_date,
       a.incept_date, a.expiry_date exp_date, a.acct_ent_date,
       a.spoiled_acct_ent_date,
       (NVL (d.share_percentage, 100) / 100) * a.tsi_amt tsi,
       CASE
          WHEN d.share_premium = 0
             THEN 0
          ELSE   (NVL (d.share_percentage, 100) / 100)
               * a.modal_premium
       END modal_premium,                                  -- a.modal_premium,
       x.evat evat, x.local_gov_tax local_gov_tax, x.doc_stamps doc_stamps,
       x.fire_service_tax fire_service_tax, x.other_charges other_charges,
       CASE
          WHEN a.iss_cd = 'RI'
             THEN fnget_ri_comm (a.iss_cd,
                                 a.prem_seq_no,
                                 a.line_cd
                                )
          ELSE d.commission_amt
       END commission_amt,
       b.rv_meaning pol_flag, a.spec_pol_flag spec_pol_flag, a.line_cd,
       a.iss_cd, a.prem_seq_no, a.currency_rt, a.subline_cd, a.policy_id,
       a.iss_name, a.booking_date, a.endorsement_no, a.renew_no,
       f.rv_meaning dist_flag, a.ret_prem, a.facul_prem, a.item_grp,
       a.branch_name_dist, a.eff_date, a.check_issue_date,
       a.check_incept_date, a.check_booking_date, a.check_acct_ent_date,
       a.check_spld_acct_ent_date, a.endt_seq_no, a.policy_type,
       d.wholding_tax, g.branch_code cred_branch_code, a.endt_type,
       a.reinstate_tag
  FROM bi_production_tax_fact_mv_tmp a,
       cg_ref_codes b,
       bi_line_dim_mv c,
       bi_production_fact_agent_mv d,
       cg_ref_codes f,
       (SELECT   prem_seq_no, iss_cd, SUM (doc_stamps) doc_stamps,
                 SUM (local_gov_tax) local_gov_tax,
                 SUM (other_charges) other_charges,
                 SUM (fire_service_tax) fire_service_tax, SUM (evat) evat
            FROM bi_tax_mv
        GROUP BY prem_seq_no, iss_cd) x,
       bi_branch_dim g
 WHERE b.rv_domain = 'GIPI_POLBASIC.POL_FLAG'
   AND b.rv_low_value = a.pol_flag
   AND f.rv_low_value = a.dist_flag
   AND f.rv_domain = 'GIPI_POLBASIC.DIST_FLAG'
   -- and a.acct_ent_date is null
   AND a.line_cd = c.line_cd(+)
   AND a.subline_cd = c.subline_cd(+)
   AND a.iss_cd = d.iss_cd(+)
   AND a.prem_seq_no = d.prem_seq_no(+)
   AND c.peril_cd IS NULL
   AND a.prem_seq_no = x.prem_seq_no(+)
   AND a.iss_cd = x.iss_cd(+)
   AND a.cred_branch = g.iss_cd;

COMMENT ON MATERIALIZED VIEW BIADMIN.BI_PRODUCTION_TAX_FACT_MV IS 'snapshot table for snapshot BIADMIN.BI_PRODUCTION_TAX_FACT_MV';
