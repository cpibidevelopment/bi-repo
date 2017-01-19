SET SERVEROUTPUT ON
SET FEEDBACK  OFF  


BEGIN  
 DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------------------------'); 
 DBMS_OUTPUT.PUT_LINE('##Processing Materialized Views-Production per peril##');
 DBMS_OUTPUT.PUT_LINE('Dropping Materialized Views...');  
END;   
/

BEGIN
process_object('bi_production_fact_mv_tmp',  'MATERIALIZED VIEW','DROP');
process_object('bi_production_fact_mv',  'MATERIALIZED VIEW','DROP');
END;
/


BEGIN  
 DBMS_OUTPUT.PUT_LINE('Creating Materialized Views...');  
END;   
/
          CREATE  MATERIALIZED VIEW  bi_production_fact_mv_tmp
          REFRESH FORCE ON DEMAND
          AS            
          SELECT  --  ROWNUM                                                           policy_code,
                   a.policy_no                                                       policy_no,
                   PKG_ADHOC.GET_LINE_DIM(a.line_cd,a.subline_cd ,c.peril_cd )       line_code,   
                   a.agent_code,
                   a.assured_code,  
                   a.issue_date, 
                   a.incept_date, 
                   a.exp_date,
                   a.acct_ent_date,
                   a.spoiled_acct_ent_date  ,                    
                   (NVL (c.tsi_amt, 0)*b.currency_rt)                              tsi,
                   --(NVL (g.share_percentage, 0) / 100)
                   -- *
                   (NVL (c.prem_amt, 0)*b.currency_rt)                             prem_amt            ,           
                   0                                                               annual_premium,
                   0                                                               evat, 
                   0                                                               local_gov_tax, 
                   0                                                               doc_stamps, 
                   0                                                               fire_service_tax, 
                   0                                                               other_charges,
                   a.commission_amt                                                commission_amt, 
                   0                                                               ret_prem, 
                   0                                                               facul_prem,
                   0                                                               treaty_prem,                                                             
                   a.pol_flag,
                   a.spec_pol_flag                                                 spec_pol_flag,
                   a.line_cd, 
                   f.iss_cd ,
                   a.prem_seq_no , 
                   a.currency_rt,          
                   a.subline_cd    ,                    
                   c.peril_cd ,    
                   a.policy_id,
                   a.iss_name,
                   a.booking_date,
                   a.endorsement_no,
                   a.renew_no,
                   a.dist_flag, 
                   0                                                                ret_prem_acct_ent,
                   0                                                                dist_tsi_ret,
                   0                                                                dist_tsi_facul,
                   0                                                                dist_tsi_treaty    ,
                   f.branch_code                                                    branch_code_dist      ,
                   a.eff_date ,
                   a.check_issue_date,
                   a.check_incept_date,
                   a.check_booking_date,
                   a.check_acct_ent_date,
                   a.check_spld_acct_ent_date,
                   a.endt_seq_no, 
                   a.policy_type ,
                   a.line_code                                                      line_subline_code                                        
              FROM bi_production_tax_fact_mv a,
                   gipi_invoice b,
                   gipi_invperil c,
                   bi_branch_dim f
                   --gipi_comm_invoice g
         WHERE a.policy_id = b.policy_id(+) 
           AND a.item_grp = b.item_grp(+)
           AND b.iss_cd = c.iss_cd(+)
           AND b.prem_seq_no= c.prem_seq_no(+)
           AND b.item_grp = c.item_grp(+)    
           AND f.iss_cd != Giacp.v ('RI_ISS_CD')
           AND a.branch_name_dist = f.branch_name(+);
           
       
         
           
           create index idx1_bi_production_fact_mv_tmp on bi_production_fact_mv_tmp (policy_id, iss_cd, prem_seq_no , agent_code ) ;
           
           
           
           
           
          CREATE  MATERIALIZED VIEW  bi_production_fact_mv
          REFRESH FORCE ON DEMAND
          AS     
          SELECT ROWNUM  policy_code, a.* from 
          (SELECT    
                    a.policy_no,
                    a.line_code,
                    a.agent_code,
                    a.assured_code,  
                    a.issue_date, 
                    a.incept_date, 
                    a.exp_date,
                    a.acct_ent_date,
                    a.spoiled_acct_ent_date  ,
                    (NVL (b.share_percentage, 100) / 100)
                    * a.tsi     tsi,
                    (NVL (b.share_percentage, 100) / 100)
                    * a.prem_amt                                                    prem_amt,
                    a.annual_premium                                                annual_premium        ,
                    0                                                               evat, 
                    0                                                               local_gov_tax, 
                    0                                                               doc_stamps, 
                    0                                                               fire_service_tax, 
                    0                                                               other_charges,
                    b.commission_amt                                                commission_amt, 
                    a.ret_prem                                                      ret_prem, 
                    a.facul_prem                                                    facul_prem,
                    a.treaty_prem                                                   treaty_prem,                                                             
                    a.pol_flag,
                    a.spec_pol_flag                                                 spec_pol_flag,
                    a.line_cd, 
                    a.iss_cd ,
                    a.prem_seq_no , 
                    a.currency_rt,          
                    a.subline_cd    ,                    
                    a.peril_cd ,    
                    a.policy_id,
                    a.iss_name,
                    a.booking_date,
                    a.endorsement_no,
                    a.renew_no,
                    a.dist_flag, 
                    a.ret_prem_acct_ent                                             ret_prem_acct_ent,
                    a.dist_tsi_ret                                                  dist_tsi_ret,
                    a.dist_tsi_facul                                                dist_tsi_facul,
                    a.dist_tsi_treaty                                               dist_tsi_treaty,
                    a.branch_code_dist,
                    a.eff_date ,
                    a.check_issue_date,  
                    a.check_incept_date,
                    a.check_booking_date,
                    a.check_acct_ent_date,
                    a.check_spld_acct_ent_date,
                    a.endt_seq_no, 
                    a.policy_type  ,
                    a.line_subline_code ,
                    b.wholding_tax 
          FROM bi_production_fact_mv_tmp a,
               gipi_comm_invoice b
          WHERE  b.policy_id(+) = a.policy_id
               AND b.iss_cd(+) =a.iss_cd             
               AND b.prem_seq_no(+) =a.prem_seq_no  
               AND b.intrmdry_intm_no(+)  = a.agent_code 
         UNION ALL
         SELECT    --ROWNUM                                                              policy_code,
                   a.policy_no                                                       policy_no,
                   PKG_ADHOC.GET_LINE_DIM(a.line_cd,a.subline_cd ,c.peril_cd )       line_code,   
                   a.agent_code,
                   a.assured_code,  
                   a.issue_date, 
                   a.incept_date, 
                   a.exp_date,
                   a.acct_ent_date,
                   a.spoiled_acct_ent_date  ,  
                   (NVL (c.tsi_amt, 0)*b.currency_rt)                                                    tsi,
                   (NVL (c.prem_amt, 0)*b.currency_rt)                             prem_amt            ,           
                   0                                                               annual_premium,
                   a.evat                                                          evat, 
                   a.local_gov_tax                                                 local_gov_tax, 
                   a.doc_stamps                                                    doc_stamps, 
                   a.fire_service_tax                                              fire_service_tax, 
                   a.other_charges                                                 other_charges,
                   c.ri_comm_amt                                                   commission_amt, 
                   0                                                               ret_prem, 
                   0                                                               facul_prem,
                   0                                                               treaty_prem,                                                             
                   a.pol_flag,
                   a.spec_pol_flag                                                 spec_pol_flag,
                   a.line_cd, 
                   a.iss_cd ,
                   a.prem_seq_no , 
                   a.currency_rt,          
                   a.subline_cd    ,                    
                   c.peril_cd ,    
                   a.policy_id,
                   a.iss_name,
                   a.booking_date,
                   a.endorsement_no,
                   a.renew_no,
                   a.dist_flag, 
                   0                                                                ret_prem_acct_ent,
                   0                                                                dist_tsi_ret,
                   0                                                                dist_tsi_facul,
                   0                                                                dist_tsi_treaty    ,
                   f.branch_code                                                    branch_code_dist      ,
                   a.eff_date ,
                   a.check_issue_date,       
                   a.check_incept_date,
                   a.check_booking_date,
                   a.check_acct_ent_date,
                   a.check_spld_acct_ent_date,
                   a.endt_seq_no, 
                   a.policy_type,    
                   a.line_code                                                      line_subline_code,                                 
                   0                                                                wholding_tax
              FROM bi_production_tax_fact_mv a,
                   gipi_invoice b,
                   gipi_invperil c,
                   bi_branch_dim f
         WHERE a.policy_id = b.policy_id(+) 
           AND a.item_grp = b.item_grp(+)
           AND b.iss_cd = c.iss_cd(+)
           AND b.prem_seq_no= c.prem_seq_no(+)
           AND b.item_grp = c.item_grp(+)     
           AND a.branch_name_dist = f.branch_name(+)
           AND f.iss_cd = Giacp.v('RI_ISS_CD')) a ;
           
           
       
BEGIN  
DBMS_OUTPUT.PUT_LINE('bi_production_fact_mv--created....');
END;    
/

BEGIN  
DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------------------------'); 
END;
/

