SET SERVEROUTPUT ON
SET FEEDBACK  OFF  


BEGIN  
 DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------------------------'); 
 DBMS_OUTPUT.PUT_LINE('##Processing Materialized Views-Production##');
 DBMS_OUTPUT.PUT_LINE('Dropping Materialized Views...');  
END;   
/

BEGIN
process_object('bi_production_tax_fact_mv_tmp',  'MATERIALIZED VIEW','DROP');
process_object('bi_production_tax_fact_mv',  'MATERIALIZED VIEW','DROP');
END;
/


CREATE MATERIALIZED VIEW BI_PRODUCTION_TAX_FACT_MV_TMP 
AS
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
          (SYSDATE, 'YYYYMMDD') /*TO_CHAR (fnget_check_date (a.line_cd, a.subline_cd, a.iss_cd, a.issue_yy, a.pol_seq_no, a.renew_no, 1), 'YYYYMMDD') */
                                                             check_issue_date,
       TO_CHAR
          (SYSDATE, 'YYYYMMDD') /*TO_CHAR (fnget_check_date (a.line_cd, a.subline_cd, a.iss_cd, a.issue_yy, a.pol_seq_no, a.renew_no, 2), 'YYYYMMDD') */
                                                            check_incept_date,
       TO_CHAR
          (SYSDATE, 'YYYYMMDD') /*TO_CHAR (fnget_check_date (a.line_cd, a.subline_cd, a.iss_cd, a.issue_yy, a.pol_seq_no, a.renew_no, 3), 'YYYYMMDD') */
                                                           check_booking_date,
       TO_CHAR
          (SYSDATE, 'YYYYMMDD') /*TO_CHAR (fnget_check_date (a.line_cd, a.subline_cd, a.iss_cd, a.issue_yy, a.pol_seq_no, a.renew_no, 4), 'YYYYMMDD') */
                                                          check_acct_ent_date,
       TO_CHAR
          (SYSDATE, 'YYYYMMDD') /*TO_CHAR (SYSDATE, 'YYYY' )TO_CHAR (fnget_check_date (a.line_cd, a.subline_cd, a.iss_cd, a.issue_yy, a.pol_seq_no, a.renew_no, 5), 'YYYYMMDD')*/
                                                     check_spld_acct_ent_date,
       a.endt_seq_no, i.type_desc policy_type, a.cred_branch
  FROM gipi_polbasic a,
       giis_issource b,
       giis_grp_issource c,
       giis_issource d,
       gipi_invoice e,
       giis_line f,
       giis_subline g,
       giis_issource h,
       giis_policy_type i
 WHERE                                            --NVL(a.pol_flag,' ') != '5'
         --AND    NVL(a.reg_policy_sw,' ') != 'N'
       -- AND    TO_DATE(a.booking_mth || '01, ' || a.booking_year, 'MONTH DD, YYYY') <= TO_DATE(UPPER(:booking_month) || '01,' || :booking_year, 'MONTH DD, YYYY')
        --AND    a.acct_ent_date IS NULL -- IF BOOKING
       DECODE (a.cred_branch, NULL, a.iss_cd, a.cred_branch) = b.iss_cd(+)
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
  
 

  
 


CREATE MATERIALIZED VIEW  BI_PRODUCTION_TAX_FACT_MV 
AS
SELECT a.policy_no policy_no, e.line_code line_code,
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
       d.wholding_tax,
       g.branch_code cred_branch_code
  FROM bi_production_tax_fact_mv_tmp a,
       cg_ref_codes b,
       bi_line_sub_line_dim_mv c,
       bi_production_fact_agent_mv d,
       bi_line_sub_line_dim_mv e,
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
   AND a.line_cd = e.line_cd(+)
   AND a.subline_cd = e.subline_cd(+)
   AND a.prem_seq_no = x.prem_seq_no(+)
   AND a.iss_cd = x.iss_cd(+)
   AND a.cred_branch = g.iss_cd;