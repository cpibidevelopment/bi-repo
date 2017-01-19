CREATE MATERIALIZED VIEW BIADMIN.BI_PRODUCTION_TAX_FACT_MV_TMP 
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
/* Formatted on 2016/08/25 14:49 (Formatter Plus v4.8.8) */
SELECT get_policy_no (a.policy_id) endorsement_no, a.prem_amt modal_premium,
       TO_CHAR (a.issue_date, 'YYYYMMDD') issue_date,
       TO_CHAR (a.incept_date, 'YYYYMMDD') incept_date,
       TO_CHAR (a.acct_ent_date, 'YYYYMMDD') acct_ent_date,
       TO_CHAR (e.spoiled_acct_ent_date, 'YYYYMMDD') spoiled_acct_ent_date,
       a.pol_flag pol_flag, e.iss_cd iss_cd, e.prem_seq_no prem_seq_no,
       e.currency_rt currency_rt, a.subline_cd subline_cd, a.line_cd,
       f.line_name line_name, g.subline_name subline_name, a.tsi_amt,
       a.renew_no,
       CASE
          WHEN e.multi_booking_mm IS NOT NULL
          AND e.multi_booking_yy IS NOT NULL
             THEN TO_CHAR (LAST_DAY (TO_DATE (   '01-'
                                              || e.multi_booking_mm
                                              || '-'
                                              || e.multi_booking_yy,
                                              'DD-MONTH-YYYY'
                                             )
                                    ),
                           'YYYYMMDD'
                          )
       END booking_date,
       TO_CHAR (a.expiry_date, 'YYYYMMDD') expiry_date,
       a.reg_policy_sw spec_pol_flag,
          a.line_cd
       || '-'
       || a.subline_cd
       || '-'
       || a.iss_cd
       || '-'
       || LTRIM (TO_CHAR (a.issue_yy, '09'))
       || '-'
       || LTRIM (TO_CHAR (a.pol_seq_no, '0999999'))
       || '-'
       || LTRIM (TO_CHAR (renew_no, '09')) policy_no,
       b.iss_name, a.assd_no, a.policy_id, a.dist_flag, 0 ret_prem,
       0 facul_prem, e.item_grp, h.iss_name branch_name_dist,
       TO_CHAR (a.eff_date, 'YYYYMMDD') eff_date,
       TO_CHAR
          (SYSDATE, 'YYYYMMDD')
/*TO_CHAR (fnget_check_date (a.line_cd, a.subline_cd, a.iss_cd, a.issue_yy, a.pol_seq_no, a.renew_no, 1), 'YYYYMMDD') */
                                                             check_issue_date,
       TO_CHAR
          (SYSDATE, 'YYYYMMDD')
/*TO_CHAR (fnget_check_date (a.line_cd, a.subline_cd, a.iss_cd, a.issue_yy, a.pol_seq_no, a.renew_no, 2), 'YYYYMMDD') */
                                                            check_incept_date,
       TO_CHAR
          (SYSDATE, 'YYYYMMDD')
/*TO_CHAR (fnget_check_date (a.line_cd, a.subline_cd, a.iss_cd, a.issue_yy, a.pol_seq_no, a.renew_no, 3), 'YYYYMMDD') */
                                                           check_booking_date,
       TO_CHAR
          (SYSDATE, 'YYYYMMDD')
/*TO_CHAR (fnget_check_date (a.line_cd, a.subline_cd, a.iss_cd, a.issue_yy, a.pol_seq_no, a.renew_no, 4), 'YYYYMMDD') */
                                                          check_acct_ent_date,
       TO_CHAR
          (SYSDATE, 'YYYYMMDD')
/*TO_CHAR (SYSDATE, 'YYYY' )TO_CHAR (fnget_check_date (a.line_cd, a.subline_cd, a.iss_cd, a.issue_yy, a.pol_seq_no, a.renew_no, 5), 'YYYYMMDD')*/
                                                     check_spld_acct_ent_date,
       a.endt_seq_no, i.type_desc policy_type, a.cred_branch,
       NVL (a.endt_type, 'A') endt_type,
       NVL (a.reinstate_tag, 'N') reinstate_tag
  FROM gipi_polbasic a,
       giis_issource b,
       giis_grp_issource c,
       giis_issource d,
       gipi_invoice e,
       giis_line f,
       giis_subline g,
       giis_issource h,
       giis_policy_type i
 WHERE a.iss_cd = b.iss_cd(+)
   AND a.iss_cd = h.iss_cd(+)
   AND b.iss_grp = c.iss_grp(+)
   AND b.cpi_branch_cd = d.iss_cd(+)
   AND a.policy_id = e.policy_id(+)
   AND a.line_cd = f.line_cd(+)
   AND a.line_cd = g.line_cd(+)
   AND a.subline_cd = g.subline_cd(+)
   AND a.type_cd = i.type_cd(+)
   AND a.line_cd = i.line_cd(+)
   AND NVL (a.endt_type, 'A') = 'A'
   AND NVL (a.reinstate_tag, 'N') = NVL (a.reinstate_tag, 'N');

COMMENT ON MATERIALIZED VIEW BIADMIN.BI_PRODUCTION_TAX_FACT_MV_TMP IS 'snapshot table for snapshot BIADMIN.BI_PRODUCTION_TAX_FACT_MV_TMP';
