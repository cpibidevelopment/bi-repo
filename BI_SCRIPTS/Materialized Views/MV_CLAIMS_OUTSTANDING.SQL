
SET SERVEROUTPUT ON
SET FEEDBACK  OFF  



BEGIN  
 DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------------------------'); 
 DBMS_OUTPUT.PUT_LINE('##Processing Materialized Views-Claims Outstanding##');
 DBMS_OUTPUT.PUT_LINE('Dropping Materialized Views...');  
END;   
/



BEGIN  
   process_object('BI_OUTSTANDING_MV ',  'MATERIALIZED VIEW','DROP');   
END;   
/

CREATE MATERIALIZED VIEW  BI_OUTSTANDING_MV 
AS
SELECT ROWNUM claim_rec, a.*
  FROM (SELECT   a.claim_id, a.peril_cd, f.intm_no, c.assd_no, h.line_code,
                 i.branch_code,
                    c.line_cd
                 || '-'
                 || c.subline_cd
                 || '-'
                 || c.iss_cd
                 || '-'
                 || LTRIM (TO_CHAR (c.clm_yy, '09'))
                 || '-'
                 || LTRIM (TO_CHAR (c.clm_seq_no, '0999999')) claim_no,
                    c.line_cd
                 || '-'
                 || c.subline_cd
                 || '-'
                 || c.pol_iss_cd
                 || '-'
                 || LTRIM (TO_CHAR (c.issue_yy, '09'))
                 || '-'
                 || LTRIM (TO_CHAR (c.pol_seq_no, '0999999'))
                 || '-'
                 || LTRIM (TO_CHAR (c.renew_no, '09')) policy_no,
                 TO_CHAR (e.posting_date, 'YYYYMMDD') posting_date,
                 TO_CHAR (e.tran_date, 'YYYYMMDD') tran_date,
                 TO_CHAR (c.dsp_loss_date, 'YYYYMMDD') loss_date,
                 TO_CHAR (c.clm_file_date, 'YYYYMMDD') file_date,
                 CASE
                    WHEN a.booking_month IS NOT NULL
                    AND a.booking_year IS NOT NULL
                       THEN TO_CHAR ((TO_DATE (   '01-'
                                               || a.booking_month
                                               || '-'
                                               || a.booking_year,
                                               'DD-MONTH-YYYY'
                                              )
                                     ),
                                     'YYYYMMDD'
                                    )
                 END booking_date,
                 fnget_cg_ref (e.tran_flag,
                               'GIAC_ACCTRANS.TRAN_FLAG'
                              ) tran_flag,
                 SUM (  d.os_loss
                      * NVL (f.shr_intm_pct, 100)
                      / 100                                 /* g.shr_pct/100*/
                     ) os_loss,
                 SUM (d.os_expense * NVL (f.shr_intm_pct, 100) / 100
                     /* g.shr_pct/100*/
                     ) os_expense,
                 g.shr_pct, g.share_type, ' ' date_paid, 0 loss_reserve,
                 0 losses_paid, 0 expense_reserve, 0 expenses_paid,
                 ' ' close_date, ' ' close_date2, ' ' cancel_tag,
                 ' ' cancel_date, 'Y' taken_up
            FROM gicl_clm_res_hist a,
                 gicl_item_peril b,
                 gicl_claims c,
                 gicl_take_up_hist d,
                 giac_acctrans e,
                 (SELECT claim_id, item_no, peril_cd, intm_no, shr_intm_pct
                    FROM gicl_intm_itmperil
                                           /* WHERE p_print_option = 4
                                                OR p_intm_no IS NOT NULL*/
                 ) f,
                 (SELECT DISTINCT claim_id, item_no, peril_cd,
                                  clm_res_hist_id, grouped_item_no, shr_pct,
                                  share_type
                             --DECODE('G', 'G', 100, shr_pct) shr_pct --multiply 100 if extraction is Gross else multiply share of Net Retention only
                  FROM            gicl_reserve_ds
                                                 /*WHERE DECODE('G', 'G', 1, share_type) = 1*/
                 ) g,
                 bi_line_dim_mv h,
                 bi_branch_dim i
--if extraction amount is based on Gross retrieve all records otherwise retrieve records of Net Retention only
        WHERE    a.claim_id = b.claim_id
             AND a.item_no = b.item_no
             AND a.peril_cd = b.peril_cd
             AND a.claim_id = c.claim_id
             AND a.claim_id = d.claim_id
             AND a.clm_res_hist_id = d.clm_res_hist_id
             AND b.peril_cd = h.peril_cd(+)
             AND c.iss_cd = i.iss_cd(+)
             AND c.subline_cd = h.subline_cd
             AND c.line_cd = h.line_cd
             AND d.acct_tran_id = e.tran_id
             /*AND TO_DATE (   NVL (a.booking_month, TO_CHAR (:p_curr2_date, 'FMMONTH'))
                          || ' 01, '
                          || NVL (TO_CHAR (a.booking_year, '0999'),TO_CHAR (:p_curr2_date, 'YYYY')), 'FMMONTH DD, YYYY'
                         ) <= :p_curr2_date*/
             --AND DECODE(:v_posted,'Y',TRUNC(e.posting_date),TRUNC(e.tran_date)) = :p_curr2_date
             --AND e.tran_flag = DECODE(:v_posted,'Y','P','C')
             AND (NVL (d.os_loss, 0) + NVL (d.os_expense, 0)) > 0
             AND b.claim_id = f.claim_id(+)
             AND b.item_no = f.item_no(+)
             AND b.peril_cd = f.peril_cd(+)
             AND DECODE (NULL, NULL, 1, f.intm_no) = NVL (NULL, 1)
             AND a.claim_id = g.claim_id
             -- AND d.claim_id = 92592
             AND a.item_no = g.item_no
             AND a.peril_cd = g.peril_cd
             AND a.grouped_item_no = g.grouped_item_no
             AND a.clm_res_hist_id = g.clm_res_hist_id
        GROUP BY a.claim_id,
                 a.peril_cd,
                 f.intm_no,
                 TO_CHAR (e.posting_date, 'YYYYMMDD'),
                 TO_CHAR (e.tran_date, 'YYYYMMDD'),
                 a.booking_month,
                 a.booking_year,
                 e.tran_flag,
                 g.shr_pct,
                 g.share_type,
                 c.line_cd,
                 c.subline_cd,
                 c.iss_cd,
                 c.clm_yy,
                 c.clm_seq_no,
                 c.pol_iss_cd,
                 c.issue_yy,
                 c.pol_seq_no,
                 c.renew_no,
                 c.assd_no,
                 c.dsp_loss_date,
                 c.clm_file_date,
                 h.line_code,
                 i.branch_code
        UNION ALL
        SELECT   a.claim_id, a.peril_cd, d.intm_no, c.assd_no, g.line_code,
                 h.branch_code,
                    c.line_cd
                 || '-'
                 || c.subline_cd
                 || '-'
                 || c.iss_cd
                 || '-'
                 || LTRIM (TO_CHAR (c.clm_yy, '09'))
                 || '-'
                 || LTRIM (TO_CHAR (c.clm_seq_no, '0999999')) claim_no,
                    c.line_cd
                 || '-'
                 || c.subline_cd
                 || '-'
                 || c.pol_iss_cd
                 || '-'
                 || LTRIM (TO_CHAR (c.issue_yy, '09'))
                 || '-'
                 || LTRIM (TO_CHAR (c.pol_seq_no, '0999999'))
                 || '-'
                 || LTRIM (TO_CHAR (c.renew_no, '09')) policy_no,
                 ' ' posting_date, ' ' tran_date,
                 TO_CHAR (c.dsp_loss_date, 'YYYYMMDD') loss_date,
                 TO_CHAR (c.clm_file_date, 'YYYYMMDD') file_date,
                 CASE
                    WHEN a.booking_month IS NOT NULL
                    AND a.booking_year IS NOT NULL
                       THEN TO_CHAR ((TO_DATE (   '01-'
                                               || a.booking_month
                                               || '-'
                                               || a.booking_year,
                                               'DD-MONTH-YYYY'
                                              )
                                     ),
                                     'YYYYMMDD'
                                    )
                 END booking_date,
                 ' ' tran_flag, 0 os_loss, 0 os_expense, f.shr_pct,
                 f.share_type, TO_CHAR (a.date_paid, 'YYYYMMDD') date_paid,
                 SUM (  DECODE (a.dist_sw,
                                'Y', NVL (a.convert_rate, 1)
                                 * NVL (a.loss_reserve, 0),
                                0
                               )
                      * NVL (d.shr_intm_pct, 100)
                      / 100
                     --  * f.shr_pct
                     --  / 100
                     ) loss_reserve,
                 SUM (  DECODE (a.dist_sw,
                                NULL, NVL (a.convert_rate, 1)
                                 * NVL (a.losses_paid, 0),
                                0
                               )
                      * NVL (d.shr_intm_pct, 100)
                      / 100
                     --    * f.shr_pct
                      --   / 100
                     ) losses_paid,
                 SUM (  DECODE (a.dist_sw,
                                'Y', NVL (a.convert_rate, 1)
                                 * NVL (a.expense_reserve, 0),
                                0
                               )
                      * NVL (d.shr_intm_pct, 100)
                      / 100
                      --    * f.shr_pct
                     --     / 100
                     ) expense_reserve,
                 SUM (  DECODE (a.dist_sw,
                                NULL, NVL (a.convert_rate, 1)
                                 * NVL (a.expenses_paid, 0),
                                0
                               )
                      * NVL (d.shr_intm_pct, 100)
                      / 100
                     --    * f.shr_pct
                     --    / 100
                     ) expenses_paid,
                 TO_CHAR (b.close_date, 'YYYYMMDD') close_date,
                 TO_CHAR (b.close_date2, 'YYYYMMDD') close_date2,
                 a.cancel_tag, TO_CHAR (a.cancel_date,
                                        'YYYYMMDD') cancel_date, 'N' taken_up
            FROM gicl_clm_res_hist a,
                 gicl_item_peril b,
                 gicl_claims c,
                 (SELECT claim_id, item_no, peril_cd, intm_no, shr_intm_pct
                    FROM gicl_intm_itmperil) d,
                 (SELECT DISTINCT claim_id, item_no, peril_cd,
                                  clm_res_hist_id, grouped_item_no,
                                  share_type,
                                             /*DECODE('G', 'G', 100, shr_pct)*/
                                             shr_pct
--multiply 100 if extraction is Gross else multiply share of Net Retention only
                  FROM            gicl_reserve_ds
                            WHERE NVL (negate_tag, 'N') <> 'Y'
                                                              /*AND DECODE('G', 'G', 1, share_type) = 1*/
                 ) f,
                 bi_line_dim_mv g,
                 bi_branch_dim h
--if extraction amount is based on Gross retrieve all records otherwise retrieve records of Net Retention only
        WHERE    a.claim_id = b.claim_id
             AND a.item_no = b.item_no
             AND a.peril_cd = b.peril_cd
             AND a.claim_id = c.claim_id(+)
             AND b.claim_id = d.claim_id(+)
             AND b.item_no = d.item_no(+)
             AND b.peril_cd = d.peril_cd(+)
             AND b.peril_cd = g.peril_cd(+)
             AND c.iss_cd = h.iss_cd(+)
             AND c.line_cd = g.line_cd
             AND c.subline_cd = g.subline_cd
              --AND check_user_per_iss_cd2(c.line_cd, c.iss_cd, 'GICLS204', p_user_id) = 1
              /*AND TO_DATE (   NVL (a.booking_month, TO_CHAR (p_curr2_date, 'FMMONTH'))
                           || ' 01, '
                           || NVL (TO_CHAR (a.booking_year, '0999'), TO_CHAR (p_curr2_date, 'YYYY')), 'FMMONTH DD, YYYY'
                          ) <= p_curr2_date*/
              --AND TRUNC(NVL(a.date_paid, p_curr2_date)) <= p_curr2_date
             -- AND DECODE (a.cancel_tag, 'Y', TRUNC (a.cancel_date), p_curr2_date + 1) > p_curr2_date
             -- AND (GICLS202_EXTRACTION_PKG.CHECK_CLOSE_DATE1(1, a.claim_id, a.item_no, a.peril_cd, p_curr2_date) = 1
               --   OR GICLS202_EXTRACTION_PKG.CHECK_CLOSE_DATE2(1, a.claim_id, a.item_no, a.peril_cd, p_curr2_date) = 1)
             AND DECODE (NULL, NULL, 1, d.intm_no) = NVL (NULL, 1)
             AND a.claim_id = f.claim_id
             AND a.item_no = f.item_no
             AND a.peril_cd = f.peril_cd
             AND a.grouped_item_no = f.grouped_item_no
        GROUP BY a.claim_id,
                 a.peril_cd,
                 d.intm_no,
                 a.date_paid,
                 a.booking_month,
                 a.booking_year,
                 TO_CHAR (b.close_date, 'YYYYMMDD'),
                 TO_CHAR (b.close_date2, 'YYYYMMDD'),
                 a.cancel_tag,
                 a.cancel_date,
                 f.shr_pct,
                 f.share_type,
                 c.line_cd,
                 c.subline_cd,
                 c.iss_cd,
                 c.clm_yy,
                 c.clm_seq_no,
                 c.pol_iss_cd,
                 c.issue_yy,
                 c.pol_seq_no,
                 c.renew_no,
                 c.assd_no,
                 c.dsp_loss_date,
                 c.clm_file_date,
                 g.line_code,
                 h.branch_code) a;

BEGIN      
 DBMS_OUTPUT.PUT_LINE('BI_OUTSTANDING_MV --created....');  
 END;
/
