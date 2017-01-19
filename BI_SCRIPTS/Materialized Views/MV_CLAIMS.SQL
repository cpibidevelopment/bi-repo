
SET SERVEROUTPUT ON
SET FEEDBACK  OFF  



BEGIN  
 DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------------------------'); 
 DBMS_OUTPUT.PUT_LINE('##Processing Materialized Views-Claims##');
 DBMS_OUTPUT.PUT_LINE('Dropping Materialized Views...');  
END;   
/



BEGIN  
   process_object('bi_claims_agent_mv',  'MATERIALIZED VIEW','DROP');   
   process_object('bi_claims_mv',  'MATERIALIZED VIEW','DROP');    
   process_object('bi_intm_basic_mv',  'MATERIALIZED VIEW','DROP');  
   process_object('bi_intm_basic_mv1',  'MATERIALIZED VIEW','DROP');  
END;   
/


CREATE MATERIALIZED VIEW BI_INTM_BASIC_MV1 
as
SELECT   /*+ALL_ROWS*/
         --totel--10/11/2007--added hint for opt
         a.claim_id,
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
         || LTRIM (TO_CHAR (b.renew_no, '09')) policy_no,
         c.intrmdry_intm_no, e.parent_intm_no, e.intm_type, e.intm_name
    FROM gicl_claims a, gipi_polbasic b, gipi_comm_invoice c, giis_intermediary e
   WHERE a.renew_no = b.renew_no
     AND a.pol_seq_no = b.pol_seq_no
     AND a.issue_yy = b.issue_yy
     AND a.pol_iss_cd = b.iss_cd
     AND a.subline_cd = b.subline_cd
     AND a.line_cd = b.line_cd
     AND b.policy_id = c.policy_id
     AND b.pol_flag NOT IN ('4', '5')
     AND a.loss_date >= TRUNC (b.eff_date)
     AND c.intrmdry_intm_no = e.intm_no
GROUP BY a.claim_id, b.line_cd, b.subline_cd, b.iss_cd, b.issue_yy, b.pol_seq_no, b.renew_no, c.intrmdry_intm_no, e.parent_intm_no, e.intm_type, e.intm_name;

BEGIN      
 DBMS_OUTPUT.PUT_LINE('bi_intm_basic_mv1--created....');  
 END;
/


 CREATE MATERIALIZED VIEW BI_INTM_BASIC_MV 
as
/* Formatted on 2016/03/04 10:48 (Formatter Plus v4.8.8) */
SELECT DISTINCT DECODE (NVL (0, 1), 1, NVL (parent_intm_no, intrmdry_intm_no), 0, intrmdry_intm_no) agent_code
           FROM bi_intm_basic_mv1 b, gicl_claims a
          WHERE a.claim_id = b.claim_id
		AND( parent_intm_no = NVL (a.intm_no, intrmdry_intm_no)
             OR     (intrmdry_intm_no = NVL (a.intm_no, intrmdry_intm_no) AND parent_intm_no IS NOT NULL OR intrmdry_intm_no = NVL (a.intm_no, intrmdry_intm_no) AND parent_intm_no IS NULL)) ;



BEGIN      
 DBMS_OUTPUT.PUT_LINE('bi_intm_basic_mv--created....');  
 END;
/
                         
               
CREATE MATERIALIZED VIEW BI_CLAIMS_MV 
AS 
/* Formatted on 2016/03/02 14:46 (Formatter Plus v4.8.8) */
SELECT h.line_code, e.branch_code, (a.line_cd || '-' || a.subline_cd || '-' || a.iss_cd || '-' || LPAD (TO_CHAR (a.clm_yy), 2, '0') || '-' || LPAD (TO_CHAR (a.clm_seq_no), 7, '0')) "CLAIM_NO",
          a.line_cd
       || '-'
       || a.subline_cd
       || '-'
       || a.pol_iss_cd
       || '-'
       || LTRIM (TO_CHAR (a.issue_yy, '00'))
       || '-'
       || LTRIM (TO_CHAR (a.pol_seq_no, '0000009'))
       || '-'
       || LTRIM (TO_CHAR (a.renew_no, '00')) "POLICY_NO",
       a.subline_cd, a.pol_iss_cd, a.issue_yy, a.pol_seq_no, a.renew_no, a.assd_no, a.claim_id, a.clm_stat_cd, a.old_stat_cd, f.clm_stat_desc claim_status,
       TO_CHAR (a.dsp_loss_date, 'YYYYMMDD') loss_date, TO_CHAR (a.clm_file_date, 'YYYYMMDD') file_date, TO_CHAR (a.pol_eff_date, 'YYYYMMDD') effectivity_date,
       TO_CHAR (a.close_date, 'YYYYMMDD') close_date, DECODE (a.pol_iss_cd, 'RI', 'ASSUMED', 'DIRECT') issue_source, fnget_claim (a.claim_id, b.item_no, b.peril_cd, 'E', a.clm_stat_cd) exp_amount,
       fnget_claim (a.claim_id, b.item_no, b.peril_cd, 'L', a.clm_stat_cd) loss_amount, NVL (fget_reserve_ds (a.claim_id, b.item_no, b.peril_cd, 1, 'E', a.clm_stat_cd), 0) exp_retention_amt,
       NVL (fget_reserve_ds (a.claim_id, b.item_no, b.peril_cd, 2, 'E', a.clm_stat_cd), 0) exp_propor_treaty,
       NVL (fget_reserve_ds (a.claim_id, b.item_no, b.peril_cd, 3, 'E', a.clm_stat_cd), 0) exp_facultative,
       NVL (fget_reserve_ds (a.claim_id, b.item_no, b.peril_cd, 4, 'E', a.clm_stat_cd), 0) exp_nonpropor_treaty,
       NVL (fget_reserve_ds (a.claim_id, b.item_no, b.peril_cd, 1, 'L', a.clm_stat_cd), 0) loss_retention_amt,
       NVL (fget_reserve_ds (a.claim_id, b.item_no, b.peril_cd, 2, 'L', a.clm_stat_cd), 0) loss_propor_treaty,
       NVL (fget_reserve_ds (a.claim_id, b.item_no, b.peril_cd, 3, 'L', a.clm_stat_cd), 0) loss_facultative,
       NVL (fget_reserve_ds (a.claim_id, b.item_no, b.peril_cd, 4, 'L', a.clm_stat_cd), 0) loss_nonpropor_treaty
  FROM gicl_claims a,
       (SELECT DISTINCT c.peril_cd, c.peril_sname peril_sname, b.item_no, b.claim_id, c.line_cd, c.subline_cd
                   FROM gicl_item_peril b, giis_peril c
                  WHERE b.peril_cd = c.peril_cd) b,
       giis_issource d,
       bi_branch_dim e,
       giis_clm_stat f,
       bi_line_sub_line_dim_mv h
 WHERE a.line_cd = b.line_cd(+) AND a.claim_id = b.claim_id(+) AND a.pol_iss_cd = d.iss_cd(+) AND a.iss_cd = e.iss_cd(+) AND a.clm_stat_cd = f.clm_stat_cd AND a.line_cd = h.line_cd(+)
       AND a.subline_cd = h.subline_cd(+);








BEGIN      
 DBMS_OUTPUT.PUT_LINE('bi_claims_mv--created....');  
 END;
/
     
CREATE MATERIALIZED VIEW BI_CLAIMS_AGENT_MV 
AS
/* Formatted on 2016/03/02 14:48 (Formatter Plus v4.8.8) */
SELECT a.claim_id, a.line_cd, a.iss_cd, a.line_cd || '-' || a.subline_cd || '-' || a.iss_cd || '-' || LTRIM (TO_CHAR (a.clm_yy, '09')) || '-' || LTRIM (TO_CHAR (a.clm_seq_no, '0999999')) claim_no,
          a.line_cd
       || '-'
       || a.subline_cd
       || '-'
       || a.pol_iss_cd
       || '-'
       || LTRIM (TO_CHAR (a.issue_yy, '09'))
       || '-'
       || LTRIM (TO_CHAR (a.pol_seq_no, '0999999'))
       || '-'
       || LTRIM (TO_CHAR (a.renew_no, '09')) policy_no,
       TO_CHAR (a.dsp_loss_date, 'YYYYMMDD') loss_date, TO_CHAR (a.clm_file_date, 'YYYYMMDD') file_date, TO_CHAR (a.pol_eff_date, 'YYYYMMDD') effectivity_date,
       TO_CHAR (a.close_date, 'YYYYMMDD') close_date, a.subline_cd, a.pol_iss_cd, a.issue_yy, a.pol_seq_no, a.renew_no, a.assd_no, b.intrmdry_intm_no parent_no, b.intm_name parent_name, b.intm_type,
       a.clm_stat_cd, a.old_stat_cd, c.peril_cd, fnget_claim_agent_amount (a.claim_id, 'L', c.peril_cd, a.clm_stat_cd) loss_amount,
       fnget_claim_agent_amount (a.claim_id, 'E', c.peril_cd, a.clm_stat_cd) expense_amount, fget_reserve_agent_ds (a.claim_id, 1, c.peril_cd, 'L', a.clm_stat_cd) loss_retention_amt,
       fget_reserve_agent_ds (a.claim_id, 1, c.peril_cd, 'E', a.clm_stat_cd) exp_retention_amt, fget_reserve_agent_ds (a.claim_id, 2, c.peril_cd, 'L', a.clm_stat_cd) loss_propor_treaty,
       fget_reserve_agent_ds (a.claim_id, 2, c.peril_cd, 'E', a.clm_stat_cd) exp_propor_treaty, fget_reserve_agent_ds (a.claim_id, 3, c.peril_cd, 'L', a.clm_stat_cd) loss_facultative,
       fget_reserve_agent_ds (a.claim_id, 3, c.peril_cd, 'E', a.clm_stat_cd) exp_facultative, fget_reserve_agent_ds (a.claim_id, 4, c.peril_cd, 'L', a.clm_stat_cd) loss_nonpropor_treaty,
       fget_reserve_agent_ds (a.claim_id, 4, c.peril_cd, 'E', a.clm_stat_cd) exp_nonpropor_treaty, pkg_adhoc.get_line_dim (a.line_cd, a.subline_cd, c.peril_cd) line_code
  FROM bi_intm_basic_mv1 b,
       gicl_claims a,
       (SELECT DISTINCT c.peril_cd, c.peril_sname, b.claim_id, c.line_cd
                   FROM gicl_item_peril b, giis_peril c
                  WHERE b.peril_cd = c.peril_cd) c
 WHERE a.claim_id = b.claim_id AND b.intrmdry_intm_no IN (SELECT agent_code
                                                            FROM bi_intm_basic_mv) AND NVL (c.line_cd, a.line_cd) = a.line_cd AND c.claim_id(+) = a.claim_id;                      


BEGIN      
 DBMS_OUTPUT.PUT_LINE('bi_claims_agent_mv--created....');  
 END;
/