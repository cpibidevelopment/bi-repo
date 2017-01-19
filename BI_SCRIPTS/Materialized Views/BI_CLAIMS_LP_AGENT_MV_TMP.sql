CREATE MATERIALIZED VIEW BIADMIN.BI_CLAIMS_LP_AGENT_MV_TMP 
TABLESPACE USERS
PCTUSED    0
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOCACHE
LOGGING
NOCOMPRESS
NOPARALLEL
BUILD IMMEDIATE
REFRESH FORCE ON DEMAND
WITH PRIMARY KEY
AS 
/* Formatted on 2016/08/31 15:26 (Formatter Plus v4.8.8) */
SELECT get_policy_id (a.line_cd,
                      a.subline_cd,
                      a.iss_cd,
                      a.issue_yy,
                      a.pol_seq_no,
                      a.renew_no
                     ) policy_id,
       a.claim_id,
          a.line_cd
       || '-'
       || a.subline_cd
       || '-'
       || a.iss_cd
       || '-'
       || LTRIM (TO_CHAR (a.clm_yy, '09'))
       || '-'
       || LTRIM (TO_CHAR (a.clm_seq_no, '0999999')) claim_no,
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
       c.peril_cd, a.assd_no, a.line_cd, a.subline_cd,
       TO_CHAR (d.date_paid, 'YYYYMMDD') date_paid, a.clm_stat_cd,
       TO_CHAR (a.dsp_loss_date, 'YYYYMMDD') dps_loss_date,
       TO_CHAR
          (CASE
              WHEN (    TRUNC (a.dsp_loss_date) < TRUNC (a.pol_eff_date)
                    AND TRUNC (a.dsp_loss_date) < TRUNC (a.expiry_date)
                   )
                 THEN TRUNC (a.pol_eff_date)
              WHEN (    TRUNC (a.dsp_loss_date) > TRUNC (a.pol_eff_date)
                    AND TRUNC (a.dsp_loss_date) > TRUNC (a.expiry_date)
                   )
                 THEN TRUNC (a.expiry_date)
              WHEN (TRUNC (a.dsp_loss_date) BETWEEN TRUNC (a.pol_eff_date)
                                                AND TRUNC (a.expiry_date)
                   )
                 THEN TRUNC (a.dsp_loss_date)
           END,
           'YYYYMMDD'
          ) loss_date,
       TO_CHAR (a.pol_eff_date, 'YYYYMMDD') pol_eff_date,
       CASE
          WHEN a.clm_stat_cd NOT IN ('DN', 'CC', 'WD')
             THEN DECODE
                    (NVL (d.cancel_tag, 'N'),
                     'N', DECODE (d.tran_id,
                                  NULL, DECODE ('L',
                                                'E', NVL
                                                       (  NVL (d.convert_rate,
                                                               1
                                                              )
                                                        * d.expense_reserve,
                                                        0
                                                       ),
                                                NVL (  NVL (d.convert_rate, 1)
                                                     * d.loss_reserve,
                                                     0
                                                    )
                                               ),
                                  DECODE ('L',
                                          'E', NVL (  NVL (d.convert_rate, 1)
                                                    * d.expenses_paid,
                                                    0
                                                   ),
                                          NVL (  NVL (d.convert_rate, 1)
                                               * d.losses_paid,
                                               0
                                              )
                                         )
                                 ),
                     DECODE ('L',
                             'E', NVL (  NVL (d.convert_rate, 1)
                                       * d.expense_reserve,
                                       0
                                      ),
                             NVL (NVL (d.convert_rate, 1) * d.loss_reserve, 0)
                            )
                    )
          ELSE 0
       END loss_amount,
       CASE
          WHEN a.clm_stat_cd NOT IN ('DN', 'CC', 'WD')
             THEN DECODE
                    (NVL (d.cancel_tag, 'N'),
                     'N', DECODE (d.tran_id,
                                  NULL, DECODE ('E',
                                                'E', NVL
                                                       (  NVL (d.convert_rate,
                                                               1
                                                              )
                                                        * d.expense_reserve,
                                                        0
                                                       ),
                                                NVL (  NVL (d.convert_rate, 1)
                                                     * d.loss_reserve,
                                                     0
                                                    )
                                               ),
                                  DECODE ('E',
                                          'E', NVL (  NVL (d.convert_rate, 1)
                                                    * d.expenses_paid,
                                                    0
                                                   ),
                                          NVL (  NVL (d.convert_rate, 1)
                                               * d.losses_paid,
                                               0
                                              )
                                         )
                                 ),
                     DECODE ('E',
                             'E', NVL (  NVL (d.convert_rate, 1)
                                       * d.expense_reserve,
                                       0
                                      ),
                             NVL (NVL (d.convert_rate, 1) * d.loss_reserve, 0)
                            )
                    )
          ELSE 0
       END expense_amount,
       (  DECODE
             ( /*GICLS202_EXTRACTION_PKG.CHECK_CLOSE_DATE1(2, a.claim_id, a.item_no, a.peril_cd, p_curr2_date)*/1,
              0, 0,
              DECODE (d.dist_sw,
                      NULL, NVL (d.convert_rate, 1) * NVL (d.losses_paid, 0),
                      0
                     )
             )
        * NVL (h.shr_intm_pct, 100)
        / 100
         /*  GET_REVERSAL(a.tran_id, p_curr1_date, p_curr2_date)*/
       --  * i.shr_pct/100
       ) losses_paid,
       (  DECODE
             ( /*GICLS202_EXTRACTION_PKG.CHECK_CLOSE_DATE1(2, a.claim_id, a.item_no, a.peril_cd, p_curr2_date)*/1,
              0, 0,
              DECODE (d.dist_sw,
                      NULL, NVL (d.convert_rate, 1) * NVL (d.expenses_paid, 0),
                      0
                     )
             )
        * NVL (h.shr_intm_pct, 100)
        / 100
        /*  GET_REVERSAL(a.tran_id, p_curr1_date, p_curr2_date)*/
       --  * i.shr_pct/100
       ) expenses_paid,
       d.loss_reserve, d.expense_reserve, d.tran_id, f.loss_cat_des,
       b.item_no, TO_CHAR (clm_file_date, 'YYYYMMDD') file_date,
       TO_CHAR (d.cancel_date, 'YYYYMMDD') cancel_date, d.cancel_tag,
       fnget_reversal_trandate (d.tran_id) tran_date, a.pol_iss_cd, d.dist_sw,
       fnget_cg_ref (g.tran_flag, 'GIAC_ACCTRANS.TRAN_FLAG') tran_flag,
       fnget_check_payment (d.claim_id,
                            d.item_no,
                            d.peril_cd,
                            'L'
                           ) with_loss_payment,
       fnget_check_payment (d.claim_id,
                            d.item_no,
                            d.peril_cd,
                            'E'
                           ) with_expense_payment,
       d.convert_rate, h.intm_no, fnget_agent (a.claim_id) intm_name,
       f.loss_cat_des loss_cat_desc, d.clm_res_hist_id,
       DECODE (a.pol_iss_cd, 'RI', 'ASSUMED', 'DIRECT') issue_source,
       NVL (i.shr_pct, 0) / 100 shr_pct,
                                        -- i.share_type,
                                        a.iss_cd
  FROM gicl_claims a,
       gicl_clm_item b,
       gicl_item_peril c,
       gicl_clm_res_hist d,
       giis_loss_ctgry f,
       giac_acctrans g,
       gicl_intm_itmperil h,
       (SELECT DISTINCT claim_id, item_no, peril_cd, clm_res_hist_id,
                        grouped_item_no,
                        DECODE ('G', 'G', 100, shr_pct) shr_pct
--                                        , share_type
--multiply 100 if extraction is Gross else multiply share of Net Retention only
        FROM            gicl_reserve_ds
                  WHERE NVL (negate_tag, 'N') <> 'Y'
                                                    /*AND DECODE('G', 'G', 1, share_type) = 1*/
       ) i,
       giis_intermediary j
 WHERE a.claim_id = b.claim_id
   AND h.intm_no = j.intm_no
   AND b.claim_id = c.claim_id
   AND b.item_no = c.item_no
   --and a.claim_id = 103370
   AND b.grouped_item_no = c.grouped_item_no
   AND c.claim_id = d.claim_id(+)
   AND c.item_no = d.item_no(+)
   AND c.peril_cd = d.peril_cd(+)
   -- and a.line_cd|| '-'|| a.subline_cd|| '-' || a.pol_iss_cd|| '-'|| LTRIM (TO_CHAR (a.issue_yy, '09'))|| '-'|| LTRIM (TO_CHAR (a.pol_seq_no, '0999999'))|| '-' || LTRIM (TO_CHAR (a.renew_no, '09')) = e.policy_no
    --and c.peril_cd = e.peril_cd(+)
    --and c.item_no = e.item_no(+)
    --and c.claim_id  = e.claim_id(+)
   AND a.line_cd = f.line_cd(+)
   AND a.loss_cat_cd = f.loss_cat_cd(+)
   AND d.tran_id = g.tran_id(+)
   AND c.claim_id = h.claim_id(+)
   AND c.item_no = h.item_no(+)
   AND c.peril_cd = h.peril_cd(+)
   AND d.claim_id = i.claim_id
   AND d.item_no = i.item_no
   AND d.peril_cd = i.peril_cd
   AND d.grouped_item_no = i.grouped_item_no;

COMMENT ON MATERIALIZED VIEW BIADMIN.BI_CLAIMS_LP_AGENT_MV_TMP IS 'snapshot table for snapshot BIADMIN.BI_CLAIMS_LP_AGENT_MV_TMP';

