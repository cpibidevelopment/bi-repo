SET SERVEROUTPUT ON
SET FEEDBACK  OFF  


BEGIN  
 DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------------------------'); 
 DBMS_OUTPUT.PUT_LINE('##Processing Materialized Views-collection##');
 DBMS_OUTPUT.PUT_LINE('Dropping Materialized Views...');  
END;   
/


BEGIN  
   process_object('bi_collection_tax_fact_mv_tmp',  'MATERIALIZED VIEW' ,'DROP');
   process_object('bi_collection_tax_fact_mv',   'MATERIALIZED VIEW' ,'DROP');     
END;   
/


CREATE  MATERIALIZED VIEW   bi_collection_tax_fact_mv_tmp
REFRESH FORCE ON DEMAND AS
                SELECT     h.intm_no,
                           UPPER (h.intm_name) intm_name,
                           b.policy_id,
                           j.iss_name,
                           a.b140_iss_cd,
                           a.b140_prem_seq_no,
                           UPPER (l.assd_name) assd_name,
                           SUM(NVL (a.premium_amt, 0)* (NVL (g.share_percentage, 100) / 100  ) ) premium,
                           --or_pref_suf || '-' || or_no or_no,
                           --or_date,
                           c.tran_class,
                           i.line_cd,
                           i.line_name,
                           b.subline_cd,
                           k.subline_name,
                           f.assd_no,
                           c.posting_date  posting_date,
                           c.tran_id, 
                           a.gacc_tran_id,
                           c.tran_date  tran_date,
                           c.tran_flag       ,
                           SUM (a.collection_amt * (NVL (g.share_percentage, 100) / 100) )  collection_amt    ,                           
                           DECODE (d.acct_ent_date, NULL, 'U', 'B') book_tag  ,
                           a.b140_iss_cd || '-' || TO_CHAR (a.b140_prem_seq_no) bill_no        ,
                           SUM (a.tax_amt * (NVL (g.share_percentage, 100) / 100  ))     tax_amt ,
                           g.share_percentage
                 FROM   gipi_polbasic b, 
                        giac_acctrans c,
                        gipi_invoice d,
                        gipi_parlist e,
                        giis_assured f,
                        gipi_comm_invoice g,
                        giis_intermediary h,
                        giis_line i,
                        giis_issource j   ,
                        giis_subline k,
                        giac_direct_prem_collns a,                                                                        
                        giis_assured l
               WHERE b.policy_id = d.policy_id
                 AND d.iss_cd = a.b140_iss_cd
                 AND d.prem_seq_no = a.b140_prem_seq_no
                 AND a.gacc_tran_id = c.tran_id
                 AND c.tran_id > 0
                 AND c.tran_flag <> 'D'
                -- AND c.tran_class <> 'CP'
                 AND g.intrmdry_intm_no = h.intm_no
                 AND g.iss_cd = d.iss_cd
                 AND g.prem_seq_no = d.prem_seq_no
                 AND g.policy_id = d.policy_id
                 AND a.b140_iss_cd = j.iss_cd
                 AND b.assd_no = l.assd_no(+)
                 AND b.line_cd = i.line_cd(+)
                 AND b.line_cd  =k.line_cd(+)                 
                 AND b.subline_cd = k.subline_cd(+)
                 --AND (d.acct_ent_date IS NOT NULL OR p_param IN (2, 3))
                -- AND (d.acct_ent_date IS NULL OR p_param IN (1, 3))
                 AND b.par_id = e.par_id
                 AND e.assd_no = f.assd_no
                 --AND d.iss_cd = NVL (p_branch_code, d.iss_cd)               
                  /* AND TRUNC (DECODE (1, 2, c.tran_date, c.posting_date))
                        BETWEEN '01-JAN-2015'
                            AND '31-JAN-2015'*/
                 AND NOT EXISTS (
                        SELECT x.gacc_tran_id
                          FROM giac_reversals x, giac_acctrans y
                         WHERE x.reversing_tran_id = y.tran_id
                           AND y.tran_flag <> 'D'
                           AND x.gacc_tran_id = a.gacc_tran_id)
            GROUP BY f.assd_no,
                     f.assd_name,
                     h.intm_no,
                     h.intm_name,
                     a.b140_iss_cd,
                     a.b140_prem_seq_no,
                     c.tran_flag,
                     c.posting_date,
                     d.prem_amt + d.tax_amt,
                     DECODE (d.acct_ent_date, NULL, 'U', 'B'),
                     b.line_cd,
                     c.tran_id, 
                     a.gacc_tran_id,
                     b.subline_cd,
                     k.subline_name,
                     g.share_percentage,
                     c.tran_date,
                     c.tran_flag ,
                     i.line_name,
                     j.iss_name,
                     b.policy_id,
                     c.tran_class,
                     i.line_cd,
                     DECODE (d.acct_ent_date, NULL, 'U', 'B'),
                     UPPER (l.assd_name) ,
                     b.line_cd
                         || '-'
                         || b.subline_cd
                         || '-'
                         || b.iss_cd
                         || '-'
                         || LTRIM (TO_CHAR (b.issue_yy, '09'))
                         || '-'
                         || LTRIM (TO_CHAR (b.pol_seq_no, '0999999'))
                         || '-'
                         || LTRIM (TO_CHAR (b.renew_no, '09'))
                         || DECODE (
                               NVL (b.endt_seq_no, 0),
                               0, '',
                                  ' / '
                               || b.endt_iss_cd
                               || '-'
                               || LTRIM (TO_CHAR (b.endt_yy, '09'))
                               || '-'
                               || LTRIM (TO_CHAR (b.endt_seq_no, '0999999'))
                            );
            
     
BEGIN
DBMS_OUTPUT.PUT_LINE('bi_collection_tax_fact_mv_tmp--created....');  
END;   
/            


CREATE  MATERIALIZED VIEW   bi_collection_tax_fact_mv
REFRESH FORCE ON DEMAND
AS
SELECT rownum  collection_code, a.*   ,c.line_code  , b.iss_cd, b.prem_seq_no   , a.premium modal_premium,
           0                                                          evat, 
           0                                              local_gov_tax, 
           0                                                  doc_stamps, 
           0                                           fire_service_tax, 
           0                                              other_charges,
           or_pref_suf || '-' || or_no or_no,
           or_date,
           gibr_branch_cd--,
         --  e.branch_name  gibr_branch_name
 FROM  bi_collection_tax_fact_mv_tmp  a,gipi_invoice b , bi_line_sub_line_dim_mv  c, giac_order_of_payts d--, bi_branch_dim e
 WHERE a.policy_id =b.policy_id 
  AND a.line_name =c.line_name 
  AND a.subline_name = c.subline_name 
  AND a.tran_id = d.gacc_tran_id (+) 
  AND a.gacc_tran_id = d.gacc_tran_id(+);
  --AND d.gibr_branch_cd= e.iss_cd
  
  
  BEGIN
DBMS_OUTPUT.PUT_LINE('bi_collection_tax_fact_mv--created....');  
END;   
/
  
BEGIN  
DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------------------------'); 
END;  
/

