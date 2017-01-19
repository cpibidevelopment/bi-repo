SET SERVEROUTPUT ON
SET FEEDBACK  OFF  



BEGIN  
 DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------------------------'); 
 DBMS_OUTPUT.PUT_LINE('##Processing Materialized Views-Claims##');
 DBMS_OUTPUT.PUT_LINE('Dropping Materialized Views...');  
END;   
/



BEGIN  
   process_object('bi_claims_mv_tmp',  'MATERIALIZED VIEW','DROP');
   process_object('bi_claims_os_mv',  'MATERIALIZED VIEW','DROP');
   process_object('bi_claims_mv',  'MATERIALIZED VIEW','DROP');    
END;   
/



BEGIN  
 DBMS_OUTPUT.PUT_LINE('Creating Materialized Views...');  
END;   
/

  


        CREATE  MATERIALIZED VIEW bi_claims_mv_tmp
              REFRESH FORCE ON DEMAND
               AS  
               select a.claim_id, 
                      a.line_cd || '-' ||  
                      a.subline_cd || '-' ||  a.iss_cd || '-' ||  LTRIM (TO_CHAR (a.clm_yy, '09'))  || '-'|| LTRIM (TO_CHAR (a.clm_seq_no, '0999999')) claim_no,                     
                      a.line_cd|| '-'|| a.subline_cd|| '-' || a.pol_iss_cd|| '-'|| LTRIM (TO_CHAR (a.issue_yy, '09'))|| '-'|| LTRIM (TO_CHAR (a.pol_seq_no, '0999999'))|| '-' || LTRIM (TO_CHAR (a.renew_no, '09')) policy_no,
                      c.peril_cd ,
                      0 losses_paid_amount ,
                      a.assd_no,
                      a.line_cd,
                      a.subline_cd,          
                      e.date_paid  ,
                      a.clm_stat_cd  ,
                      a.dsp_loss_date,
                      CASE WHEN  (TRUNC(a.dsp_loss_date) <TRUNC(a.pol_eff_date)   AND  TRUNC(a.dsp_loss_date) < TRUNC(a.expiry_date))
                           THEN 
                                 TRUNC(a.pol_eff_date)
                           WHEN  (TRUNC(a.dsp_loss_date) >TRUNC(a.pol_eff_date ) AND TRUNC(a.dsp_loss_date) > TRUNC(a.expiry_date))
                           THEN
                                TRUNC(a.expiry_date)
                           WHEN (TRUNC(a.dsp_loss_date) BETWEEN TRUNC(a.pol_eff_date)   AND   TRUNC(a.expiry_date))
                           THEN 
                                 TRUNC(a.dsp_loss_date)
                      END loss_date,
                      a.pol_eff_date  ,
                      e.losses_paid loss_amount, 
                      e.expenses_paid  expense_amount ,
                      e.tran_id ,
                      D.loss_reserve,
                      f.loss_cat_des  ,
                      b.item_no 
              from gicl_claims a, gicl_clm_item b, gicl_item_peril c, GICL_CLM_RESERVE d , bi_losses_mv e, giis_loss_ctgry f
             where a.claim_id = b.claim_id
               and b.claim_id = c.claim_id
               and b.item_no = c.item_no
               and c.claim_id = d.claim_id
               and c.item_no = d.item_no
               and c.item_no = e.item_no(+)
               and c.peril_cd  = d.peril_cd
              -- and a.line_cd|| '-'|| a.subline_cd|| '-' || a.pol_iss_cd|| '-'|| LTRIM (TO_CHAR (a.issue_yy, '09'))|| '-'|| LTRIM (TO_CHAR (a.pol_seq_no, '0999999'))|| '-' || LTRIM (TO_CHAR (a.renew_no, '09')) = e.policy_no
               and c.peril_cd = e.peril_cd(+)
               and c.item_no = e.item_no(+)
               and c.claim_id  = e.claim_id(+)
               and a.line_cd = f.line_cd(+)
               and a.loss_cat_cd = f.loss_cat_cd(+);
               
 BEGIN      
 DBMS_OUTPUT.PUT_LINE('bi_claims_mv_tmp--created....');  
 END;
/




 BEGIN      
 DBMS_OUTPUT.PUT_LINE('bi_claims_os_mv--created....');  
 END;
/

CREATE  MATERIALIZED VIEW   bi_claims_mv
REFRESH FORCE ON DEMAND
AS
   select DISTINCT
        a.claim_id, 
        a.policy_no,       
        a.claim_no, 
        b.line_code, 
        g.branch_code ,
        b.agent_code,
        b.assured_code,
        b.issue_date issue_date,
        b.acct_ent_date acct_ent_Date,
        TO_CHAR (a.pol_eff_date, 'YYYYMMDD')         effectivity_date,       
        b.booking_date  booking_date,
        b.tsi,
        b.modal_premium,
        d.clm_stat_desc   claim_status ,
        e.clm_stat_desc   claim_status_grp, 
        TO_CHAR(trunc(a.loss_date) ,'YYYYMMDD')  loss_date, 
       -- NULL               file_date,
        TO_CHAR(a.date_paid,'YYYYMMDD')   date_paid  ,
        a.loss_amount,
       -- 0                  loss_res_amt,
        a.expense_amount, 
        NVL(a.loss_amount,0)  +   NVL( a.expense_amount,0)  losses_paid_amount ,
        a.tran_id    ,
        a.peril_cd  ,
        a.loss_reserve      ,
        a.loss_cat_des    , 
        0 outstanding_amt ,--h.outstanding_amt  ,
        a.item_no,
        b.spoiled_acct_ent_date
   from bi_claims_mv_tmp a, bi_production_fact_mv b,BI_GIIS_CLM_STAT    d,bi_giis_clm_stat e , gipi_polbasic f,  bi_branch_dim g--,
       --bi_claims_os_mv h  
  where a.policy_no = b.policy_no || '-' || LTRIM (TO_CHAR (b.renew_no, '09'))
    and a.peril_cd = b.peril_cd
    and a.clm_stat_cd = d.clm_stat_cd
    and a.clm_stat_cd = e.clm_stat_cd
    --and a.claim_id = h.claim_id(+)
   -- and a.peril_cd = h.peril_cd(+) 
    --and a.assd_no  = h.assd_no(+)
    and a.policy_no =
                f.line_cd
             || '-'
             || f.subline_cd
             || '-'
             || f.iss_cd
             || '-'
             || LTRIM (TO_CHAR (f.issue_yy, '09'))
             || '-'
             || LTRIM (TO_CHAR (f.pol_seq_no, '0999999'))
             || '-'
             || LTRIM (TO_CHAR (f.renew_no, '09'))
    and b.policy_id = f.policy_id
    and TRUNC(a.pol_eff_date) = TRUNC(f.eff_date)
    and b.iss_name =  g.branch_name(+);




 BEGIN      
 DBMS_OUTPUT.PUT_LINE('bi_claims_mv--created....');  
 END;
/ 
 
BEGIN  
DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------------------------');
END;   
/