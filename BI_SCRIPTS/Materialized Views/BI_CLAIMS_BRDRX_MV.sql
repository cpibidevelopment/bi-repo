DROP MATERIALIZED VIEW BIADMIN.BI_CLAIMS_BRDRX_MV;
CREATE MATERIALIZED VIEW BIADMIN.BI_CLAIMS_BRDRX_MV 
TABLESPACE USERS
PCTUSED    0
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
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
/* Formatted on 12/9/2016 2:25:34 PM (QP5 v5.227.12220.39754) */
SELECT ROWNUM rec_count,
       a.claim_id,
       a.item_no,
       a.peril_cd,
       b.loss_cat_cd,
       b.ann_tsi_amt,
       b.close_date,
       b.close_date2,
       g.currency_rate,
       /*(b.ann_tsi_amt * NVL (g.currency_rate, 1) ) ann_tsi_amt, */
       a.dist_sw,
       a.loss_reserve,
       a.losses_paid,
       a.expense_reserve,
       a.expenses_paid,
       a.convert_rate,
       a.tran_id,
       a.grouped_item_no,
       a.clm_res_hist_id,
       a.cancel_date,
       a.cancel_tag,
       e.grouped_item_title,
       e.control_cd,
       e.control_type_cd,
       c.iss_cd,
       c.ri_cd,
       c.line_cd,
       c.subline_cd,
       TO_NUMBER (TO_CHAR (c.loss_date, 'YYYY')) loss_year,
       c.assd_no,
       get_claim_number (c.claim_id) claim_no,
       (   c.line_cd
        || '-'
        || c.subline_cd
        || '-'
        || c.pol_iss_cd
        || '-'
        || LTRIM (TO_CHAR (c.issue_yy, '09'))
        || '-'
        || LTRIM (TO_CHAR (c.pol_seq_no, '0999999'))
        || '-'
        || LTRIM (TO_CHAR (c.renew_no, '09')))
          policy_no,
       c.dsp_loss_date loss_date,
       c.clm_file_date,
       c.pol_eff_date incept_date,
       c.expiry_date,
       c.pol_iss_cd,
       c.issue_yy,
       c.pol_seq_no,
       c.renew_no,
       c.clm_stat_cd,
       a.booking_month,
       a.booking_year,
       a.date_paid,
       d.posting_date,
       f.brdrx_type,
       d.tran_date,
       g.item_title,
       c.cred_branch,
       NVL (c.ri_cd, 0) buss_source
  FROM gicl_clm_res_hist a,
       gicl_item_peril b,
       gicl_claims c,
       (SELECT tran_id,
               tran_flag,
               posting_date,
               tran_date
          FROM giac_acctrans
         WHERE 1 = 2 AND tran_flag != 'D') d,
       (SELECT claim_id,
               item_no,
               grouped_item_no,
               grouped_item_title,
               control_type_cd,
               control_cd
          FROM gicl_accident_dtl
         WHERE 0 = 1) e,
       (SELECT DISTINCT claim_id,
                        item_no,
                        peril_cd,
                        clm_res_hist_id,
                        grouped_item_no,
                        'Outstanding' brdrx_type
          FROM gicl_reserve_ds
         WHERE NVL (negate_tag, 'N') <> 'Y') f,
       gicl_clm_item g
 WHERE     a.claim_id = b.claim_id
       AND a.claim_id =
              (SELECT v.claim_id
                 FROM (  SELECT claim_id,
                                NVL (SUM (loss_reserve), 0) lr,
                                NVL (SUM (losses_paid), 0) lp,
                                NVL (SUM (expense_reserve), 0) er,
                                NVL (SUM (expenses_paid), 0) ep
                           FROM gicl_clm_res_hist
                          WHERE (dist_sw != 'N' OR dist_sw IS NULL)
                       GROUP BY claim_id) v
                WHERE     ( (lr - lp) > 0 OR (er - ep) > 0)
                      AND v.claim_id = a.claim_id)
       AND a.item_no = b.item_no
       AND a.peril_cd = b.peril_cd
       AND a.claim_id = c.claim_id
       AND a.tran_id = d.tran_id(+)
       AND a.claim_id = e.claim_id(+)
       AND a.item_no = e.item_no(+)
       AND a.grouped_item_no = e.grouped_item_no(+)
       AND a.claim_id = f.claim_id(+)
       AND a.item_no = f.item_no(+)
       AND a.peril_cd = f.peril_cd(+)
       AND a.grouped_item_no = f.grouped_item_no(+)
       AND b.claim_id = g.claim_id
       AND b.item_no = g.item_no
UNION ALL
SELECT ROWNUM rec_count,
       a.claim_id,
       a.item_no,
       a.peril_cd,
       b.loss_cat_cd,
       b.ann_tsi_amt,
       b.close_date,
       b.close_date2,
       g.currency_rate,
       /*(b.ann_tsi_amt * NVL (g.currency_rate, 1) ) ann_tsi_amt, */
       a.dist_sw,
       a.loss_reserve,
       a.losses_paid,
       a.expense_reserve,
       a.expenses_paid,
       a.convert_rate,
       a.tran_id,
       a.grouped_item_no,
       a.clm_res_hist_id,
       a.cancel_date,
       a.cancel_tag,
       e.grouped_item_title,
       e.control_cd,
       e.control_type_cd,
       c.iss_cd,
       c.ri_cd,
       c.line_cd,
       c.subline_cd,
       TO_NUMBER (TO_CHAR (c.loss_date, 'YYYY')) loss_year,
       c.assd_no,
       get_claim_number (c.claim_id) claim_no,
       (   c.line_cd
        || '-'
        || c.subline_cd
        || '-'
        || c.pol_iss_cd
        || '-'
        || LTRIM (TO_CHAR (c.issue_yy, '09'))
        || '-'
        || LTRIM (TO_CHAR (c.pol_seq_no, '0999999'))
        || '-'
        || LTRIM (TO_CHAR (c.renew_no, '09')))
          policy_no,
       c.dsp_loss_date loss_date,
       c.clm_file_date,
       c.pol_eff_date incept_date,
       c.expiry_date,
       c.pol_iss_cd,
       c.issue_yy,
       c.pol_seq_no,
       c.renew_no,
       c.clm_stat_cd,
       a.booking_month,
       a.booking_year,
       a.date_paid,
       d.posting_date,
       f.brdrx_type,
       d.tran_date,
       g.item_title,
       c.cred_branch,
       NVL (c.ri_cd, 0) buss_source
  FROM gicl_clm_res_hist a,
       gicl_item_peril b,
       gicl_claims c,
       (SELECT tran_id,
               tran_flag,
               posting_date,
               tran_date
          FROM giac_acctrans
         WHERE 2 = 2 AND tran_flag != 'D') d,
       (SELECT claim_id,
               item_no,
               grouped_item_no,
               grouped_item_title,
               control_type_cd,
               control_cd
          FROM gicl_accident_dtl
         WHERE 0 = 1) e,
       (SELECT DISTINCT claim_id,
                        item_no,
                        peril_cd,
                        NULL clm_res_hist_id,
                        grouped_item_no,
                        'Losses Paid' brdrx_type
          FROM gicl_loss_exp_ds) f,
       gicl_clm_item g
 WHERE     a.claim_id = b.claim_id
       AND a.claim_id = (SELECT v.claim_id
                           FROM (  SELECT claim_id,
                                          NVL (SUM (loss_reserve), 0) lr,
                                          NVL (SUM (losses_paid), 0) lp,
                                          NVL (SUM (expense_reserve), 0) er,
                                          NVL (SUM (expenses_paid), 0) ep
                                     FROM gicl_clm_res_hist
                                    WHERE tran_id IS NOT NULL
                                 GROUP BY claim_id) v
                          WHERE v.claim_id = a.claim_id)
       AND a.item_no = b.item_no
       AND a.peril_cd = b.peril_cd
       AND a.claim_id = c.claim_id
       AND a.tran_id = d.tran_id
       AND a.claim_id = e.claim_id(+)
       AND a.item_no = e.item_no(+)
       AND a.grouped_item_no = e.grouped_item_no(+)
       AND a.claim_id = f.claim_id(+)
       AND a.item_no = f.item_no(+)
       AND a.peril_cd = f.peril_cd(+)
       AND a.grouped_item_no = f.grouped_item_no(+)
       AND b.claim_id = g.claim_id
       AND b.item_no = g.item_no;


COMMENT ON MATERIALIZED VIEW BIADMIN.BI_CLAIMS_BRDRX_MV IS 'snapshot table for snapshot BIADMIN.BI_CLAIMS_BRDRX_MV';
