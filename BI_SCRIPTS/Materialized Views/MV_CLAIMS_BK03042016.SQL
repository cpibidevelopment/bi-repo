
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
   process_object('bi_claims_mv',  'MATERIALIZED VIEW','DROP');    
END;   
/

                           
               
               CREATE  MATERIALIZED VIEW bi_claims_mv_tmp
               REFRESH FORCE ON DEMAND
               AS        
               select 
                      a.claim_id, 
                      a.line_cd || '-' ||  
                      a.subline_cd || '-' ||  a.iss_cd || '-' ||  LTRIM (TO_CHAR (a.clm_yy, '09'))  || '-'|| LTRIM (TO_CHAR (a.clm_seq_no, '0999999')) claim_no,                     
                      a.line_cd|| '-'|| a.subline_cd|| '-' || a.pol_iss_cd|| '-'|| LTRIM (TO_CHAR (a.issue_yy, '09'))|| '-'|| LTRIM (TO_CHAR (a.pol_seq_no, '0999999'))|| '-' || LTRIM (TO_CHAR (a.renew_no, '09')) policy_no,
                      c.peril_cd ,                      
                      a.assd_no,
                      a.line_cd,
                      a.subline_cd,          
                      TO_CHAR(d.date_paid,'YYYYMMDD') date_paid  ,
                      a.clm_stat_cd  ,
                      TO_CHAR(a.dsp_loss_date,'YYYYMMDD') dps_loss_date,
                      TO_CHAR(
                      CASE WHEN  (TRUNC(a.dsp_loss_date) <TRUNC(a.pol_eff_date)   AND  TRUNC(a.dsp_loss_date) < TRUNC(a.expiry_date))
                           THEN 
                                 TRUNC(a.pol_eff_date)
                           WHEN  (TRUNC(a.dsp_loss_date) >TRUNC(a.pol_eff_date ) AND TRUNC(a.dsp_loss_date) > TRUNC(a.expiry_date))
                           THEN
                                TRUNC(a.expiry_date)
                           WHEN (TRUNC(a.dsp_loss_date) BETWEEN TRUNC(a.pol_eff_date)   AND   TRUNC(a.expiry_date))
                           THEN 
                                 TRUNC(a.dsp_loss_date)
                      END ,'YYYYMMDD') loss_date,
                      TO_CHAR(a.pol_eff_date,'YYYYMMDD') pol_eff_date ,
                      CASE WHEN a.clm_stat_cd NOT IN ('DN', 'CC', 'WD') THEN  DECODE (NVL (d.cancel_tag, 'N'),
                                    'N', DECODE (d.tran_id,
                                                 NULL, DECODE('L', 'E',NVL (NVL(d.convert_rate, 1) * d.expense_reserve, 0),
                                                              NVL (NVL(d.convert_rate, 1) * d.loss_reserve, 0)),
                                                 DECODE('L', 'E',NVL (NVL(d.convert_rate, 1) * d.expenses_paid, 0),
                                                        NVL (NVL(d.convert_rate, 1) * d.losses_paid, 0))),
                                    DECODE('L', 'E',NVL (NVL(d.convert_rate, 1) * d.expense_reserve, 0),
                                           NVL (NVL(d.convert_rate, 1) * d.loss_reserve, 0))) ELSE 0 END  loss_amount,
                       CASE WHEN a.clm_stat_cd NOT IN ('DN', 'CC', 'WD') THEN  DECODE (NVL (d.cancel_tag, 'N'),
                                    'N', DECODE (d.tran_id,
                                                 NULL, DECODE('E', 'E',NVL (NVL(d.convert_rate, 1) * d.expense_reserve, 0),
                                                              NVL (NVL(d.convert_rate, 1) * d.loss_reserve, 0)),
                                                 DECODE('E', 'E',NVL (NVL(d.convert_rate, 1) * d.expenses_paid, 0),
                                                        NVL (NVL(d.convert_rate, 1) * d.losses_paid, 0))),
                                    DECODE('E', 'E',NVL (NVL(d.convert_rate, 1) * d.expense_reserve, 0),
                                           NVL (NVL(d.convert_rate, 1) * d.loss_reserve, 0))) ELSE 0 END  expense_amount,
                      (DECODE(/*GICLS202_EXTRACTION_PKG.CHECK_CLOSE_DATE1(2, a.claim_id, a.item_no, a.peril_cd, p_curr2_date)*/1, 0, 0, 
                                      DECODE (d.dist_sw, NULL, NVL (d.convert_rate, 1) * NVL (d.losses_paid, 0), 0)                                    
                                    ) * NVL(h.shr_intm_pct, 100)/100 /*  GET_REVERSAL(a.tran_id, p_curr1_date, p_curr2_date)*/   --* i.shr_pct/100
                             ) losses_paid,
                      (DECODE(/*GICLS202_EXTRACTION_PKG.CHECK_CLOSE_DATE1(2, a.claim_id, a.item_no, a.peril_cd, p_curr2_date)*/1, 0, 0, 
                                      DECODE (d.dist_sw, NULL, NVL (d.convert_rate, 1) * NVL (d.expenses_paid, 0), 0)                                    
                                    ) * NVL(h.shr_intm_pct, 100)/100 /*  GET_REVERSAL(a.tran_id, p_curr1_date, p_curr2_date)*/   --* i.shr_pct/100
                             ) expenses_paid,                      
                      d.loss_reserve,
                      d.expense_reserve   ,
                      d.tran_id ,
                      f.loss_cat_des  ,
                      b.item_no,
                      TO_CHAR(clm_file_date,'YYYYMMDD') file_date ,                      
                      TO_CHAR(d.cancel_date,'YYYYMMDD') cancel_date ,
                      d.cancel_tag,
                      fnget_reversal_trandate(d.tran_id) tran_date,
                      a.pol_iss_cd,
                      d.dist_sw,
                      g.tran_flag ,
                      fnget_check_payment(d.claim_id, d.item_no, d.peril_cd,'L') with_loss_payment,
                      fnget_check_payment(d.claim_id, d.item_no, d.peril_cd,'E') with_expense_payment,
                      d.convert_rate,
                      h.intm_no,
                      fnget_agent(a.claim_id) intm_name, 
                      f.loss_cat_des loss_cat_desc,
                      d.clm_res_hist_id ,
                      DECODE(a.pol_iss_cd, 'RI' , 'ASSUMED', 'DIRECT')  issue_source,
                      nvl(i.shr_pct,0)/100 shr_pct,
                      i.share_type   ,
                      a.iss_cd                                                     
              from gicl_claims a, gicl_clm_item b, gicl_item_peril c,gicl_clm_res_hist d,   giis_loss_ctgry f, giac_acctrans g,gicl_intm_itmperil h,
                   (SELECT DISTINCT claim_id, item_no, peril_cd, clm_res_hist_id, grouped_item_no, 
                               /*DECODE('G', 'G', 100, shr_pct)*/ shr_pct, share_type --multiply 100 if extraction is Gross else multiply share of Net Retention only
                          FROM gicl_reserve_ds
                         WHERE NVL (negate_tag, 'N') <> 'Y'
                           /*AND DECODE('G', 'G', 1, share_type) = 1*/) i                     
             where a.claim_id = b.claim_id(+)
               and b.claim_id = c.claim_id(+)
               and b.item_no = c.item_no(+)
               --and a.claim_id = 103370
               and b.grouped_item_no =  c.grouped_item_no(+)
               and c.claim_id = d.claim_id(+)
               and c.item_no  = d.item_no(+) 
               and c.peril_cd  = d.peril_cd(+)
              -- and a.line_cd|| '-'|| a.subline_cd|| '-' || a.pol_iss_cd|| '-'|| LTRIM (TO_CHAR (a.issue_yy, '09'))|| '-'|| LTRIM (TO_CHAR (a.pol_seq_no, '0999999'))|| '-' || LTRIM (TO_CHAR (a.renew_no, '09')) = e.policy_no
               --and c.peril_cd = e.peril_cd(+)
               --and c.item_no = e.item_no(+)
               --and c.claim_id  = e.claim_id(+)
               and a.line_cd = f.line_cd(+)
               and a.loss_cat_cd = f.loss_cat_cd(+)
               and d.tran_id = g.tran_id(+)
               and c.claim_id = h.claim_id (+)
               and c.item_no = h.item_no (+)
               and c.peril_cd = h.peril_cd (+)                              
               and d.claim_id = i.claim_id(+)
               and d.item_no = i.item_no(+)
               and d.peril_cd = i.peril_cd(+)
               and d.grouped_item_no = i.grouped_item_no(+);


      
BEGIN      
 DBMS_OUTPUT.PUT_LINE('bi_claims_mv_tmp--created....');  
 END;
/




BEGIN      
 DBMS_OUTPUT.PUT_LINE('bi_claims_mv--created....');  
 END;
/
     
CREATE  MATERIALIZED VIEW bi_claims_mv
REFRESH FORCE ON DEMAND
AS
       SELECT   a.claim_id, 
                a.policy_no, 
                a.claim_no, 
                h.line_code,                                                               
                i.branch_code, 
                a.intm_no agent_code, 
                a.assd_no assured_code, 
                a.pol_eff_date  effectivity_date,  
                d.clm_stat_desc claim_status, 
                e.clm_stat_desc claim_status_grp,
                a.loss_date,
                a.date_paid,                
                NVL(fnget_claim_amount(a.claim_id , a.clm_res_hist_id, 'L', with_loss_payment ),0)  loss_amount,
                NVL(fnget_claim_amount(a.claim_id , a.clm_res_hist_id, 'E', with_expense_payment),0) expense_amount,                
                a.loss_reserve,
                a.expense_reserve   , 
                a.losses_paid,
                a.expenses_paid,
                a.peril_cd,                 --h.outstanding_amt  ,                                                                                                                                                                a.item_no, ' ' spoiled_acct_ent_date,
                a.file_date, 
                a.cancel_date, 
                a.cancel_tag, 
                a.tran_date,
                a.tran_id ,
                a.loss_cat_des  ,
                a.item_no,
                a.pol_iss_cd,
                a.dist_sw,
                a.tran_flag,
                NVL(fget_reserve_ds(a.claim_id,1,a.item_no,  a.peril_cd,'E',a.dist_sw, a.tran_id ),0) exp_retention_amt ,
                NVL(fget_reserve_ds(a.claim_id,2,a.item_no,  a.peril_cd,'E',a.dist_sw,a.tran_id ),0) exp_propor_treaty, 
                NVL(fget_reserve_ds(a.claim_id,3, a.item_no, a.peril_cd,'E',a.dist_sw,a.tran_id ),0) exp_facultative, 
                NVL(fget_reserve_ds(a.claim_id,4,a.item_no,  a.peril_cd,'E',a.dist_sw,a.tran_id ),0) exp_nonpropor_treaty,
                NVL(fget_reserve_ds(a.claim_id,1,a.item_no,  a.peril_cd,'L',a.dist_sw,a.tran_id ),0) loss_retention_amt ,
                NVL(fget_reserve_ds(a.claim_id,2,a.item_no,  a.peril_cd,'L',a.dist_sw,a.tran_id ),0) loss_propor_treaty, 
                NVL(fget_reserve_ds(a.claim_id,3,a.item_no,  a.peril_cd,'L',a.dist_sw,a.tran_id ),0) loss_facultative, 
                NVL(fget_reserve_ds(a.claim_id,4,a.item_no,  a.peril_cd,'L',a.dist_sw,a.tran_id),0) loss_nonpropor_treaty,
                with_loss_payment,
                with_expense_payment, 
                convert_rate,
                intm_name ,
                a.intm_no,
                NVL(fnget_claim_amount(a.claim_id , a.clm_res_hist_id, 'L', with_loss_payment ),0)  +
                NVL(fnget_claim_amount(a.claim_id , a.clm_res_hist_id, 'E', with_expense_payment),0)
                claim_amount,
                a.issue_source,
                a.shr_pct,
                a.share_type,
                j.branch_code claims_branch_code,
                k.line_code line_subline_code                    
                --TO_CHAR(a.booking_date,'YYYYMMDD') booking_date
                --j.user_id ,
                --os_loss, 
               -- os_expense                              
           FROM bi_claims_mv_tmp a, bi_giis_clm_stat d, bi_giis_clm_stat e,  giis_issource g, bi_line_dim_mv h, bi_branch_dim  i, bi_branch_dim j, bi_line_sub_line_dim_mv k--, bi_expnse_loss_mv j                      
          WHERE a.clm_stat_cd = d.clm_stat_cd
            AND a.clm_stat_cd = e.clm_stat_cd
            AND a.pol_iss_cd = g.iss_cd(+)
            AND a.line_cd = h.line_cd(+)
            AND a.subline_cd = h.subline_cd(+)
            AND a.peril_cd  = h.peril_cd(+)
            AND g.iss_cd =  i.iss_cd(+)
            AND a.iss_cd = j.iss_cd(+)
            AND a.line_cd = k.line_cd(+)
            AND a.subline_cd = k.subline_cd(+);
            --AND a.claim_id = j.claim_id(+)
            --AND (j.user_id = 'CPI' or j.user_id IS NULL)
            --AND a.peril_cd = j.peril_cd(+)
            --AND a.clm_res_hist_id = j.clm_res_hist_id(+) 
            --AND a.intm_no = j.intm_no(+);
             
               
               
                      