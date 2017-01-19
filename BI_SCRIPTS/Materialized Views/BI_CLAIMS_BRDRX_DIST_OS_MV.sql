DROP MATERIALIZED VIEW BIADMIN.BI_CLAIMS_BRDRX_DIST_OS_MV;
CREATE MATERIALIZED VIEW BIADMIN.BI_CLAIMS_BRDRX_DIST_OS_MV 
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
/* Formatted on 12/9/2016 2:25:08 PM (QP5 v5.227.12220.39754) */
SELECT *
  FROM (SELECT DISTINCT a.rec_count,
                        a.claim_id,
                        a.item_no,
                        a.policy_no,
                        a.claim_no,
                        a.iss_cd,                             /*branch_code,*/
                        a.ri_cd,
                        a.line_code,
                        a.subline_cd,
                        a.loss_year,
                        a.assd_no,
                        a.loss_date,
                        a.clm_file_date,
                        a.incept_date,
                        a.expiry_date,
                        a.pol_iss_cd,
                        a.issue_yy,
                        a.pol_seq_no,
                        a.renew_no,
                        a.peril_cd,
                        a.loss_cat_cd,
                        a.ann_tsi_amt,
                        a.dist_sw,
                        a.convert_rate,
                        a.loss_reserve,
                        a.losses_paid,
                        a.expense_reserve,
                        a.expenses_paid,
                        a.grouped_item_no,
                        a.clm_res_hist_id,
                        a.grouped_item_title,
                        a.control_cd,
                        a.control_type_cd,
                        a.booking_year,
                        a.booking_month,
                        a.date_paid,
                        a.posting_date,
                        a.cancel_tag,
                        a.cancel_date,
                        a.tran_id,
                        a.tran_date,
                        a.brdrx_type,
                        a.close_date,
                        a.close_date2,
                        a.currency_rate,
                        a.intm_no,
                        a.buss_source,
                        a.line_cd,
                        /*fnget_claims_validate_max(a.claim_id ,a.item_no , a.peril_cd, a.grouped_item_no,'01-jan-2014', '28-feb-2014',1,1) clm_res_hist_id2 ,*/
                        b.shr_pct,
                        b.grp_seq_no,
                        c.shr_ri_pct_real,
                        c.ri_cd ri_cd2,
                        b.clm_res_hist_id clm_res_hist_id2,
                        c.grp_seq_no grp_seq_no2,
                        a.booking_date
          FROM bi_claims_brdrx_fact_tmp_mv a,
               gicl_reserve_ds b,
               gicl_reserve_rids c
         WHERE     a.peril_cd = b.peril_cd(+)
               AND a.item_no = b.item_no(+)
               AND a.claim_id = b.claim_id(+)
               AND a.grouped_item_no = b.grouped_item_no(+)
               AND a.brdrx_type = 'Outstanding'
               AND b.grp_seq_no = c.grp_seq_no(+)
               AND b.clm_dist_no = c.clm_dist_no(+)
               AND b.clm_res_hist_id = c.clm_res_hist_id(+)
               AND b.claim_id = c.claim_id(+)/*AND TRUNC(TO_DATE(a.loss_date, 'YYYY-MM-DD')) BETWEEN '01-JAN-2014' AND '28-FEB-2014'
                                                        AND NVL (TO_DATE(a.date_paid, 'YYYY-MM-DD'), '28-FEB-2014') BETWEEN '01-JAN-2014' AND '28-FEB-2014'
                                                        AND (   DECODE (a.cancel_tag,
                                                                        'Y', TRUNC (TO_DATE(a.cancel_date, 'YYYY-MM-DD')),
                                                                        DECODE (1,
                                                                                1, (TO_DATE('28-FEB-2014') + 1),
                                                                                2, (TO_DATE(null) + 1)
                                                                               )
                                                                       ) >
                                                                   DECODE (1,
                                                                           1, '28-FEB-2014',
                                                                           2, null
                                                                          )
                                                            )
                                                        AND ( (TO_DATE(a.close_date, 'YYYY-MM-DD') > TRUNC(SYSDATE) OR TO_DATE(a.close_date, 'YYYY-MM-DD') IS NULL)
                                                              OR (TO_DATE(a.close_date2, 'YYYY-MM-DD') > TRUNC(SYSDATE) OR TO_DATE(a.close_date2, 'YYYY-MM-DD') IS NULL) */
       );


COMMENT ON MATERIALIZED VIEW BIADMIN.BI_CLAIMS_BRDRX_DIST_OS_MV IS 'snapshot table for snapshot BIADMIN.BI_CLAIMS_BRDRX_DIST_OS_MV';
