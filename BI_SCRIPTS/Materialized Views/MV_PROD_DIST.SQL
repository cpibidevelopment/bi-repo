SET SERVEROUTPUT ON
SET FEEDBACK  OFF  

BEGIN  
 DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------------------------'); 
 DBMS_OUTPUT.PUT_LINE('##Processing Materialized Views-Prod Distritbution##');
 DBMS_OUTPUT.PUT_LINE('Dropping Materialized Views...');  
END;   
/



BEGIN  
   process_object('bi_prod_dist_fact_mv_tmp',  'MATERIALIZED VIEW','DROP');
   process_object('bi_prod_dist_fact_mv',  'MATERIALIZED VIEW','DROP');  
END;   
/
  


CREATE  MATERIALIZED VIEW  bi_prod_dist_fact_mv_tmp
REFRESH FORCE ON DEMAND
AS  
SELECT   DISTINCT b.policy_id,
         b.line_cd || '-' ||
         b.subline_cd || '-' ||
         b.iss_cd || '-' ||
         LTRIM (TO_CHAR (b.issue_yy, '09')) || '-' ||
         LTRIM (TO_CHAR (b.pol_seq_no, '0999999')) || '-' ||
         LTRIM (TO_CHAR (b.renew_no, '09')) ||
         DECODE ( NVL (b.endt_seq_no, 0),
                       0, '',
                       ' / ' ||
           b.endt_iss_cd || '-' ||
           LTRIM (TO_CHAR (b.endt_yy, '09'))|| '-' ||
           LTRIM (TO_CHAR (b.endt_seq_no, '9999999'))
                      ) policy_no,
          g.line_cd,
          b.subline_cd, g.share_cd, f.share_type, f.trty_name, f.trty_yy,
          g.dist_no, g.dist_seq_no, g.peril_cd, h.peril_type,
          DECODE (f.share_type, '1', NVL (g.dist_tsi   , 0)) * e.currency_rt  nr_dist_tsi,
          DECODE (f.share_type, '1', NVL (g.dist_prem   , 0)) * e.currency_rt  nr_dist_prem,
          DECODE (f.share_type, '1', g.dist_spct) nr_dist_spct,
          DECODE (f.share_type, '2', NVL (g.dist_tsi  , 0)) * e.currency_rt  tr_dist_tsi,
          DECODE (f.share_type, '2', NVL (g.dist_prem   , 0)) * e.currency_rt  tr_dist_prem,
          DECODE (f.share_type, '2', g.dist_spct) tr_dist_spct,
          DECODE (f.share_type, '3', NVL (g.dist_tsi   , 0)) * e.currency_rt  fa_dist_tsi,
          DECODE (f.share_type, '3', NVL (g.dist_prem   , 0)) * e.currency_rt fa_dist_prem,
          DECODE (f.share_type, '3', g.dist_spct) fa_dist_spct,
          e.currency_rt, b.endt_seq_no, b.iss_cd, b.issue_yy,
          b.pol_seq_no, b.renew_no, b.endt_iss_cd, b.endt_yy,
          A.dist_flag ,
          a.acct_ent_date, A.acct_neg_date,b.cred_branch,
          b.pol_flag,
          b.issue_date,
          e.prem_seq_no,
          b.eff_date , 
          CASE WHEN  e.multi_booking_mm  IS NOT NULL AND e.multi_booking_yy IS NOT NULL 
          THEN 
             TO_CHAR(last_day(to_date('01-' ||  e.multi_booking_mm  || '-'  || e.multi_booking_yy , 'DD-MONTH-YYYY' )), 'YYYYMMDD') 
          END booking_date,
          j.iss_cd branch_cd_dist ,
          b.assd_no                                                       assured_code   ,
          get_policy_no(b.policy_id) endorsement_no,
          b.reg_policy_sw spec_pol_flag    
      FROM GIPI_POLBASIC b,
           GIUW_POL_DIST A,
           GIUW_PERILDS_DTL g,
           GIPI_INVOICE e,
           GIIS_DIST_SHARE f,
           GIIS_PERIL h,
           giis_issource i, 
           giis_issource j
     WHERE 1 = 1
       AND A.policy_id = b.policy_id
       AND DECODE(b.cred_branch,NULL,b.iss_cd,b.cred_branch)  = i.iss_cd (+)
       AND b.iss_cd = j.iss_cd(+)
       AND g.dist_no = A.dist_no
       AND A.policy_id = e.policy_id
       AND b.reg_policy_sw = DECODE(NULL,'Y',b.reg_policy_sw,'Y')
       AND NVL (b.line_cd, b.line_cd) = f.line_cd
       AND NVL (b.line_cd, b.line_cd) = f.line_cd
       AND NVL (b.line_cd, b.line_cd) = f.line_cd
       AND b.line_cd >= '%'
       AND b.subline_cd >= '%'
       AND g.share_cd = f.share_cd
       AND g.share_cd = f.share_cd
       AND g.peril_cd = h.peril_cd
       AND g.line_cd = h.line_cd
      --AND TRUNC(b.issue_date) BETWEEN :p_from_date AND :p_to_date
       AND NVL (b.endt_type, 'A') = 'A'           
       AND NVL(a.item_grp,1) = NVL(e.item_grp,1)
       --AND ROWNUM <=500     
       AND NVL(a.takeup_seq_no,1) = NVL(e.takeup_seq_no,1);
     
BEGIN  
DBMS_OUTPUT.PUT_LINE('bi_prod_dist_fact_mv_tmp--created....');
END;    
/       


CREATE  MATERIALIZED VIEW   bi_prod_dist_fact_mv
REFRESH FORCE ON DEMAND
AS      SELECT a.policy_id, 
              a.policy_no , 
              b.line_code ,
              c.branch_code,    
              d.branch_code cred_branch_code, 
              e.rv_meaning     pol_flag,   
              f.rv_meaning     dist_flag   ,   
              TO_CHAR(a.eff_date,'YYYYMMDD') eff_date,
              TO_CHAR(a.issue_date,'YYYYMMDD') issue_date,
              a.booking_date,
              TO_CHAR(a.acct_ent_date,'YYYYMMDD') acct_ent_date,
              TO_CHAR(a.acct_neg_date,'YYYYMMDD')acct_neg_date  ,
              a.nr_dist_tsi,
              a.nr_dist_prem,
              a.nr_dist_spct,
              a.tr_dist_tsi,
              a.tr_dist_prem,
              a.tr_dist_spct,
              a.fa_dist_tsi,
              a.fa_dist_prem  ,
              a.endorsement_no ,
              a.spec_pol_flag   ,
              a.assured_code                                                              
        FROM  bi_prod_dist_fact_mv_tmp a, --, bi_dist_mv_tmp a,
              bi_line_dim_mv b,
              bi_branch_dim  c,
              bi_branch_dim  d ,
              cg_ref_codes   e,
              cg_ref_codes   f 
        WHERE a.line_cd = b.line_cd(+)
         AND  a.subline_cd = b.subline_cd(+)
         AND  a.peril_cd = b.peril_cd(+)
         AND  a.iss_cd = c.iss_cd(+)
         AND  a.branch_cd_dist = d.iss_cd(+)
         AND  e.rv_domain='GIPI_POLBASIC.POL_FLAG'
         AND  e.rv_low_value = a.pol_flag 
         AND  f.rv_low_value = a.dist_flag
         AND  f.rv_domain = 'GIPI_POLBASIC.DIST_FLAG';
       
      
         
BEGIN  
DBMS_OUTPUT.PUT_LINE('bi_prod_dist_fact_mv--created....');
END;    
/       
         
BEGIN  
 DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------------------------'); 
END;    
/

