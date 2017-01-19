CREATE MATERIALIZED VIEW BIADMIN.BI_PRODUCTION_FACT_MV 
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
/* Formatted on 2016/08/25 17:00 (Formatter Plus v4.8.8) */
SELECT ROWNUM policy_code, a.*
  FROM (SELECT a.policy_no, a.item_no, a.item_title, a.line_code,
               a.agent_code, a.assured_code, a.issue_date, a.incept_date,
               a.exp_date, a.acct_ent_date, a.spoiled_acct_ent_date,
               (NVL (b.share_percentage, 100) / 100) * a.tsi tsi,
               (NVL (b.share_percentage, 100) / 100) * a.prem_amt prem_amt,
               b.commission_amt commission_amt, a.pol_flag,
               a.spec_pol_flag spec_pol_flag, a.line_cd, a.iss_cd,
               a.prem_seq_no, a.currency_rt, a.subline_cd, a.peril_cd,
               a.policy_id, a.iss_name, a.booking_date, a.endorsement_no,
               a.renew_no, a.dist_flag, a.branch_code_dist, a.eff_date,
               a.check_issue_date, a.check_incept_date, a.check_booking_date,
               a.check_acct_ent_date, a.check_spld_acct_ent_date,
               a.endt_seq_no, a.policy_type, b.wholding_tax,
               a.cred_branch_code
          FROM bi_production_fact_mv_tmp a, gipi_comm_invoice b
         WHERE b.policy_id(+) = a.policy_id
           AND b.iss_cd(+) = a.iss_cd
           AND b.prem_seq_no(+) = a.prem_seq_no
           AND b.intrmdry_intm_no(+) = a.agent_code
        UNION ALL
        SELECT
--ROWNUM                                                              policy_code,
               a.policy_no policy_no, d.item_no item_no,
               e.item_title item_title,
               pkg_adhoc.get_line_dim (a.line_cd,
                                       a.subline_cd,
                                       c.peril_cd
                                      ) line_code,
               a.agent_code, a.assured_code, a.issue_date, a.incept_date,
               a.exp_date, a.acct_ent_date, a.spoiled_acct_ent_date,
               (NVL (d.tsi_amt, 0) * b.currency_rt) tsi,
--change the retrieval of tsi and premamt to make it per Item Peril; updated by JJPajilan 6/14/2016
               (NVL (d.prem_amt, 0) * b.currency_rt) prem_amt,
               c.ri_comm_amt commission_amt, a.pol_flag,
               a.spec_pol_flag spec_pol_flag, a.line_cd, a.iss_cd,
               a.prem_seq_no, a.currency_rt, a.subline_cd, c.peril_cd,
               a.policy_id, a.iss_name, a.booking_date, a.endorsement_no,
               a.renew_no, a.dist_flag, f.branch_code branch_code_dist,
               a.eff_date, a.check_issue_date, a.check_incept_date,
               a.check_booking_date, a.check_acct_ent_date,
               a.check_spld_acct_ent_date, a.endt_seq_no, a.policy_type,
               0 wholding_tax, a.cred_branch_code
          FROM bi_production_tax_fact_mv a,
               gipi_invoice b,
               gipi_invperil c,
               bi_branch_dim f,
               gipi_itmperil d,
               gipi_item e
         WHERE a.policy_id = b.policy_id(+)
           AND a.item_grp = b.item_grp(+)
           AND b.iss_cd = c.iss_cd(+)
           AND b.prem_seq_no = c.prem_seq_no(+)
           AND b.item_grp = c.item_grp(+)
           AND a.branch_name_dist = f.branch_name(+)
           AND f.iss_cd = giacp.v ('RI_ISS_CD')
           /* added by JJPajilan to make the fact per Item peril 6/14/2016*/
           AND b.policy_id = d.policy_id(+)
           AND d.policy_id = e.policy_id(+)
           AND d.item_no = e.item_no
           AND b.item_grp = e.item_grp
           AND c.peril_cd = d.peril_cd) a;

COMMENT ON MATERIALIZED VIEW BIADMIN.BI_PRODUCTION_FACT_MV IS 'snapshot table for snapshot BIADMIN.BI_PRODUCTION_FACT_MV';
