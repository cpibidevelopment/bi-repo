
SET SERVEROUTPUT ON
SET FEEDBACK  OFF  

BEGIN  
 DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------------------------'); 
 DBMS_OUTPUT.PUT_LINE('##Processing Materialized Views-Others##');
 DBMS_OUTPUT.PUT_LINE('Dropping Materialized Views...');  
END;   
/

BEGIN
        process_object('bi_prod_collection_mv',  'MATERIALIZED VIEW','DROP'); 
END;        
/

CREATE MATERIALIZED VIEW bi_prod_collection_mv
REFRESH ON DEMAND 
AS
select c.agent_name,
       a.policy_no ,     
       d.line_name, 
       d.subline_name,
       pkg_adhoc.get_time (a.booking_date)  booking_date,
       pkg_adhoc.get_time (a.issue_date)    issue_date,
       pkg_adhoc.get_time (a.incept_date)   incept_date,
       pkg_adhoc.get_time (a.spoiled_acct_ent_date) spoiled_acct_ent_date,
       pkg_adhoc.get_time (a.acct_ent_date) acct_ent_date,
       pkg_adhoc.get_time (a.eff_date) effective_date,
       pkg_adhoc.get_time (b.tran_date) tran_date,
       pkg_adhoc.get_time (b.pos_date) pos_date,
       b.premium_amount premium,
       b.collection_amount,
       spec_pol_flag,
       renew_no, 
       endt_seq_no, 
       e.branch_name cred_branch             
  from bi_production_tax_fact  a, 
       bi_collection_tax_fact b,
       bi_agent_dim  c,
       bi_line_sub_line_dim d, 
       bi_branch_dim e          
 where a.endorsement_no  =  b.policy_no(+)
   and a.agent_code =  c.agent_code(+)
   and a.line_code = d.line_code(+)
   and a.cred_branch_code = e.branch_code(+);
   
BEGIN  
DBMS_OUTPUT.PUT_LINE('bi_prod_collection_mv--created....');
END;    
/

BEGIN  
DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------------------------'); 
END;
/
   
   
   
  
   
   


    
    
    