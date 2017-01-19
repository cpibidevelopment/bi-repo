CREATE MATERIALIZED VIEW BIADMIN.BI_CLAIMS_REG_MV 
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
/* Formatted on 2016/08/31 14:19 (Formatter Plus v4.8.8) */
SELECT a.claim_id, a.line_cd, a.subline_cd, a.pol_iss_cd, a.issue_yy,
       a.pol_seq_no, a.renew_no, a.iss_cd,
       TO_NUMBER (TO_CHAR (a.loss_date, 'yyyy')) loss_year, a.assd_no,
       get_claim_number (a.claim_id) claim_no,
       (   a.line_cd
        || '-'
        || a.subline_cd
        || '-'
        || a.pol_iss_cd
        || '-'
        || LTRIM (TO_CHAR (a.issue_yy, '09'))
        || '-'
        || LTRIM (TO_CHAR (a.pol_seq_no, '0999999'))
        || '-'
        || LTRIM (TO_CHAR (a.renew_no, '09'))
       ) policy_no,
       a.clm_file_date, a.dsp_loss_date, a.loss_date, a.pol_eff_date,
       a.expiry_date, a.clm_stat_cd, a.loss_cat_cd, a.ri_cd,
       b.converted_recovered_amt,
       fnget_tot_prem_amt (a.claim_id, c.item_no, c.peril_cd) prem_amt,
       c.item_no, c.peril_cd, c.ann_tsi_amt, c.loss_reserve, c.losses_paid,
       c.expense_reserve, c.expenses_paid, c.grouped_item_no,
       c.clm_res_hist_id,
       DECODE (a.pol_iss_cd,
               giacp.v ('RI_ISS_CD'), giacp.v ('RI_ISS_CD'),
               NULL
              ) intm_type,
       DECODE (a.pol_iss_cd,
               giacp.v ('RI_ISS_CD'), a.ri_cd,
               NULL
              ) buss_source, c.cancel_tag, c.cancel_date
  FROM gicl_claims a,
       (SELECT   claim_id,
                 SUM (NVL (recovered_amt * convert_rate, 0)
                     ) converted_recovered_amt
            FROM gicl_clm_recovery
        GROUP BY claim_id) b,
       (SELECT   b.claim_id, b.item_no, b.peril_cd, b.loss_cat_cd,
                 NVL (a.convert_rate, 1) convert_rate,
                 (b.ann_tsi_amt * NVL (a.convert_rate, 1)) ann_tsi_amt,
                 SUM (DECODE (a.dist_sw,
                              'Y', NVL (a.convert_rate, 1)
                               * NVL (a.loss_reserve, 0),
                              0
                             )
                     ) loss_reserve,
                 SUM (DECODE (a.dist_sw,
                              NULL, NVL (a.convert_rate, 1)
                               * NVL (a.losses_paid, 0),
                              0
                             )
                     ) losses_paid,
                 SUM (DECODE (a.dist_sw,
                              'Y', NVL (a.convert_rate, 1)
                               * NVL (a.expense_reserve, 0),
                              0
                             )
                     ) expense_reserve,
                 SUM (DECODE (a.dist_sw,
                              NULL, NVL (a.convert_rate, 1)
                               * NVL (a.expenses_paid, 0),
                              0
                             )
                     ) expenses_paid,
                 a.grouped_item_no, c.clm_res_hist_id, a.cancel_tag,
                 a.cancel_date
            FROM gicl_clm_res_hist a,
                 gicl_item_peril b,
                 (SELECT DISTINCT claim_id, item_no, peril_cd,
                                  clm_res_hist_id, grouped_item_no
                             FROM gicl_reserve_ds
                            WHERE NVL (negate_tag, 'N') <> 'Y') c
           WHERE a.peril_cd = b.peril_cd
             AND a.item_no = b.item_no
             AND a.claim_id = b.claim_id
             AND NVL (a.dist_sw, 'Y') = 'Y'
--                        AND b.loss_cat_cd =
--                                        NVL (:p_dsp_loss_cat_cd, b.loss_cat_cd)
             AND a.claim_id = c.claim_id
             AND a.item_no = c.item_no
             AND a.peril_cd = c.peril_cd
             AND a.grouped_item_no = c.grouped_item_no
        GROUP BY b.claim_id,
                 b.item_no,
                 b.peril_cd,
                 b.loss_cat_cd,
                 NVL (a.convert_rate, 1),
                 b.ann_tsi_amt,
                 a.grouped_item_no,
                 c.clm_res_hist_id,
                 a.cancel_tag,
                 a.cancel_date) c
 WHERE 1 = 1 AND b.claim_id(+) = a.claim_id AND a.claim_id = c.claim_id;

COMMENT ON MATERIALIZED VIEW BIADMIN.BI_CLAIMS_REG_MV IS 'snapshot table for snapshot BIADMIN.BI_CLAIMS_REG_MV';

