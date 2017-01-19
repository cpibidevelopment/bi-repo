CREATE MATERIALIZED VIEW BIADMIN.BI_CLAIMS_LP_AGENT_MV 
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
/* Formatted on 2016/08/31 15:28 (Formatter Plus v4.8.8) */
SELECT a.policy_id, a.claim_id, a.policy_no, a.claim_no, a.clm_res_hist_id,
       h.line_code, i.branch_code, a.intm_no agent_code,
       a.assd_no assured_code, a.pol_eff_date effectivity_date,
       d.clm_stat_desc claim_status, e.clm_stat_desc claim_status_grp,
       a.loss_date, a.date_paid,
--       NVL (fnget_claim_amount (a.claim_id,
--                                a.clm_res_hist_id,
--                                'L',
--                                with_loss_payment
--                               ),
--            0
--           ) loss_amount,
--       NVL (fnget_claim_amount (a.claim_id,
--                                a.clm_res_hist_id,
--                                'E',
--                                with_expense_payment
--                               ),
--            0
--           ) expense_amount,
                                a.loss_reserve, a.expense_reserve,
       a.losses_paid, a.expenses_paid, a.peril_cd,
--h.outstanding_amt  ,                                                                                                                                                                a.item_no, ' ' spoiled_acct_ent_date,
                                                  a.file_date, a.cancel_date,
       a.cancel_tag, a.tran_date, a.tran_id, a.loss_cat_des, a.item_no,
       a.pol_iss_cd, a.dist_sw, a.tran_flag,
--       NVL (fget_reserve_ds (a.claim_id,
--                             1,
--                             a.item_no,
--                             a.peril_cd,
--                             'E',
--                             a.dist_sw,
--                             a.tran_id
--                            ),
--            0
--           ) exp_retention_amt,
--       NVL (fget_reserve_ds (a.claim_id,
--                             2,
--                             a.item_no,
--                             a.peril_cd,
--                             'E',
--                             a.dist_sw,
--                             a.tran_id
--                            ),
--            0
--           ) exp_propor_treaty,
--       NVL (fget_reserve_ds (a.claim_id,
--                             3,
--                             a.item_no,
--                             a.peril_cd,
--                             'E',
--                             a.dist_sw,
--                             a.tran_id
--                            ),
--            0
--           ) exp_facultative,
--       NVL (fget_reserve_ds (a.claim_id,
--                             4,
--                             a.item_no,
--                             a.peril_cd,
--                             'E',
--                             a.dist_sw,
--                             a.tran_id
--                            ),
--            0
--           ) exp_nonpropor_treaty,
--       NVL (fget_reserve_ds (a.claim_id,
--                             1,
--                             a.item_no,
--                             a.peril_cd,
--                             'L',
--                             a.dist_sw,
--                             a.tran_id
--                            ),
--            0
--           ) loss_retention_amt,
--       NVL (fget_reserve_ds (a.claim_id,
--                             2,
--                             a.item_no,
--                             a.peril_cd,
--                             'L',
--                             a.dist_sw,
--                             a.tran_id
--                            ),
--            0
--           ) loss_propor_treaty,
--       NVL (fget_reserve_ds (a.claim_id,
--                             3,
--                             a.item_no,
--                             a.peril_cd,
--                             'L',
--                             a.dist_sw,
--                             a.tran_id
--                            ),
--            0
--           ) loss_facultative,
--       NVL (fget_reserve_ds (a.claim_id,
--                             4,
--                             a.item_no,
--                             a.peril_cd,
--                             'L',
--                             a.dist_sw,
--                             a.tran_id
--                            ),
--            0
--           ) loss_nonpropor_treaty,
--       with_loss_payment, with_expense_payment,
                                            convert_rate, intm_name,
       a.intm_no,
--         NVL (fnget_claim_amount (a.claim_id,
--                                  a.clm_res_hist_id,
--                                  'L',
--                                  with_loss_payment
--                                 ),
--              0
--             )
--       + NVL (fnget_claim_amount (a.claim_id,
--                                  a.clm_res_hist_id,
--                                  'E',
--                                  with_expense_payment
--                                 ),
--              0
--             ) claim_amount,
                 a.issue_source, a.shr_pct,
                                           --a.share_type,
                                           j.branch_code claims_branch_code
                                           --,
      -- k.line_code line_subline_code
   --TO_CHAR(a.booking_date,'YYYYMMDD') booking_date
   --j.user_id ,
   --os_loss,
  -- os_expense
FROM   bi_claims_lp_agent_mv_tmp a,
       bi_giis_clm_stat d,
       bi_giis_clm_stat e,
       giis_issource g,
       bi_line_dim_mv h,
       bi_branch_dim i,
       bi_branch_dim j
  --,
 -- bi_line_sub_line_dim_mv k                       --, bi_expnse_loss_mv j
WHERE  a.clm_stat_cd = d.clm_stat_cd
   AND a.clm_stat_cd = e.clm_stat_cd
   AND a.pol_iss_cd = g.iss_cd(+)
   AND a.line_cd = h.line_cd(+)
   AND a.subline_cd = h.subline_cd(+)
   AND a.peril_cd = h.peril_cd(+)
   AND g.iss_cd = i.iss_cd(+)
   AND a.iss_cd = j.iss_cd(+);

COMMENT ON MATERIALIZED VIEW BIADMIN.BI_CLAIMS_LP_AGENT_MV IS 'snapshot table for snapshot BIADMIN.BI_CLAIMS_LP_AGENT_MV';

