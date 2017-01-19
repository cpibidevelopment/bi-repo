SET SERVEROUTPUT ON
SET FEEDBACK  OFF  

BEGIN  
 DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------------------------'); 
 DBMS_OUTPUT.PUT_LINE('##Processing Materialized Views-Others##');
 DBMS_OUTPUT.PUT_LINE('Dropping Materialized Views...');  
END;   
/

BEGIN
        process_object('bi_production_fact_agent_mv',  'MATERIALIZED VIEW','DROP'); 
        process_object('bi_tax_mv',  'MATERIALIZED VIEW','DROP');
        process_object('bi_line_sub_line_dim_mv',  'MATERIALIZED VIEW','DROP');   
        process_object('bi_line_dim_mv',  'MATERIALIZED VIEW','DROP');
       --   process_object('indx1_bi_prod_net_retention',  'INDEX','DROP');
       -- process_object('bi_production_net_retention',  'MATERIALIZED VIEW','DROP');  
       -- process_object('bi_losses_mv',  'MATERIALIZED VIEW','DROP');
     
END; 
/


CREATE MATERIALIZED VIEW BI_PRODUCTION_FACT_AGENT_MV 
AS
SELECT d.policy_id, c.iss_cd, c.prem_seq_no, b.intrmdry_intm_no,
       NVL (b.premium_amt, 0) * NVL (c.currency_rt, 1) share_premium,
       NVL (b.commission_amt, 0) * NVL (c.currency_rt, 1) commission_amt,
       NVL ((SELECT 1
               FROM giac_new_comm_inv t
              WHERE t.iss_cd = c.iss_cd
                AND t.prem_seq_no = c.prem_seq_no
                AND t.acct_ent_date IS NOT NULL
                AND t.tran_flag = 'P'
                AND NVL (t.delete_sw, 'N') = 'N'
                AND t.acct_ent_date >= NVL (c.acct_ent_date, d.acct_ent_date)
                AND ROWNUM < 2),
            0
           ) exists_giac_new , b.share_percentage, 
        NVL (b.wholding_tax, 0) * NVL (c.currency_rt, 1)  wholding_tax
  FROM gipi_comm_invoice b, gipi_invoice c, gipi_polbasic d
 WHERE b.policy_id = c.policy_id
   AND b.iss_cd = c.iss_cd
   AND b.prem_seq_no = c.prem_seq_no
   AND c.policy_id = d.policy_id;

BEGIN  
DBMS_OUTPUT.PUT_LINE('bi_production_fact_agent_mv --created....');
END;    
/



CREATE MATERIALIZED VIEW BI_TAX_MV 
AS
SELECT   g.prem_seq_no, g.iss_cd,
         SUM (  DECODE (g.tax_cd,  /*giacp.n('LGT')*/   6 , NVL (g.tax_amt, 0), 0)
              * NVL (b.currency_rt, 1)
             ) local_gov_tax,
         SUM (  DECODE (g.tax_cd,  /*giacp.n('FST')*/  5   , NVL (g.tax_amt, 0), 0)
              * NVL (b.currency_rt, 1)
             ) fire_service_tax,
         SUM (  DECODE (g.tax_cd,  /*giacp.n('EVAT')*/   3 , NVL (g.tax_amt, 0), 0)
              * NVL (b.currency_rt, 1)
             ) evat,
         SUM (  DECODE (g.tax_cd,   /*giacp.n('DOC_STAMPS')*/   1 , NVL (g.tax_amt, 0), 0)
              * NVL (b.currency_rt, 1)
             ) doc_stamps,
         SUM (CASE
                 WHEN g.tax_cd  NOT IN (6 , 5 , 3, 1) THEN 
                      NVL (g.tax_amt, 0)  * NVL (b.currency_rt, 1)
              END
             ) other_charges
    FROM gipi_invoice b, gipi_inv_tax g
   WHERE b.iss_cd = g.iss_cd AND b.prem_seq_no = g.prem_seq_no
GROUP BY g.prem_seq_no, g.iss_cd;
 
BEGIN  
DBMS_OUTPUT.PUT_LINE('bi_tax_mv --created....');
END;    
/




CREATE MATERIALIZED VIEW BI_LINE_SUB_LINE_DIM_MV 
AS
SELECT ROWNUM line_code, a.*
  FROM (SELECT DISTINCT a.line_cd, a.line_name, b.subline_cd, b.subline_name
                   FROM giis_line a, giis_subline b
                  WHERE a.line_cd = b.line_cd) a;
                  

BEGIN  
DBMS_OUTPUT.PUT_LINE('BI_LINE_SUB_LINE_DIM_MV--created....');
END;    
/

CREATE MATERIALIZED VIEW BI_LINE_DIM_MV 
AS
SELECT ROWNUM line_code, a.*
  FROM (SELECT DISTINCT a.line_cd, a.line_name, b.subline_cd, b.subline_name,
                        c.peril_name, c.peril_cd, c.peril_sname, c.peril_type
                   FROM giis_line a, giis_subline b, giis_peril c
                  WHERE a.line_cd = b.line_cd AND a.line_cd = c.line_cd) a;

BEGIN  
DBMS_OUTPUT.PUT_LINE('bi_line_dim_mv--created....');
END;    
/

BEGIN  
DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------------------------'); 
END;
/