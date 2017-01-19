CREATE MATERIALIZED VIEW BIADMIN.BI_CLAIMS_MV 
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
/* Formatted on 2016/08/31 15:04 (Formatter Plus v4.8.8) */
SELECT h.line_code, e.branch_code,
       (   a.line_cd
        || '-'
        || a.subline_cd
        || '-'
        || a.iss_cd
        || '-'
        || LPAD (TO_CHAR (a.clm_yy), 2, '0')
        || '-'
        || LPAD (TO_CHAR (a.clm_seq_no), 7, '0')
       ) "CLAIM_NO",
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
       a.subline_cd, a.pol_iss_cd, a.issue_yy, a.pol_seq_no, a.renew_no,
       a.assd_no, a.claim_id, a.clm_stat_cd, a.old_stat_cd,
       f.clm_stat_desc claim_status,
       TO_CHAR (a.dsp_loss_date, 'YYYYMMDD') loss_date,
       TO_CHAR (a.clm_file_date, 'YYYYMMDD') file_date,
       TO_CHAR (a.pol_eff_date, 'YYYYMMDD') effectivity_date,
       TO_CHAR (a.close_date, 'YYYYMMDD') close_date,
       DECODE (a.pol_iss_cd, 'RI', 'ASSUMED', 'DIRECT') issue_source,
       fnget_claim (a.claim_id,
                    b.item_no,
                    b.peril_cd,
                    'E',
                    a.clm_stat_cd
                   ) exp_amount,
       fnget_claim (a.claim_id,
                    b.item_no,
                    b.peril_cd,
                    'L',
                    a.clm_stat_cd
                   ) loss_amount,
       NVL (fget_reserve_ds (a.claim_id,
                             b.item_no,
                             b.peril_cd,
                             1,
                             'E',
                             a.clm_stat_cd
                            ),
            0
           ) exp_retention_amt,
       NVL (fget_reserve_ds (a.claim_id,
                             b.item_no,
                             b.peril_cd,
                             2,
                             'E',
                             a.clm_stat_cd
                            ),
            0
           ) exp_propor_treaty,
       NVL (fget_reserve_ds (a.claim_id,
                             b.item_no,
                             b.peril_cd,
                             3,
                             'E',
                             a.clm_stat_cd
                            ),
            0
           ) exp_facultative,
       NVL (fget_reserve_ds (a.claim_id,
                             b.item_no,
                             b.peril_cd,
                             4,
                             'E',
                             a.clm_stat_cd
                            ),
            0
           ) exp_nonpropor_treaty,
       NVL (fget_reserve_ds (a.claim_id,
                             b.item_no,
                             b.peril_cd,
                             1,
                             'L',
                             a.clm_stat_cd
                            ),
            0
           ) loss_retention_amt,
       NVL (fget_reserve_ds (a.claim_id,
                             b.item_no,
                             b.peril_cd,
                             2,
                             'L',
                             a.clm_stat_cd
                            ),
            0
           ) loss_propor_treaty,
       NVL (fget_reserve_ds (a.claim_id,
                             b.item_no,
                             b.peril_cd,
                             3,
                             'L',
                             a.clm_stat_cd
                            ),
            0
           ) loss_facultative,
       NVL (fget_reserve_ds (a.claim_id,
                             b.item_no,
                             b.peril_cd,
                             4,
                             'L',
                             a.clm_stat_cd
                            ),
            0
           ) loss_nonpropor_treaty,
       i.branch_code pol_iss_code, b.item_no, b.item_title
  FROM gicl_claims a,
       (SELECT DISTINCT c.peril_cd, c.peril_sname peril_sname, b.item_no,
                        b.claim_id, c.line_cd, c.subline_cd, d.item_title
                   FROM gicl_item_peril b, giis_peril c, gicl_clm_item d
                  WHERE b.peril_cd = c.peril_cd
                    AND b.claim_id = d.claim_id
                    AND b.item_no = d.item_no
                    AND b.grouped_item_no = d.grouped_item_no) b,
       giis_issource d,
       bi_branch_dim e,
       giis_clm_stat f,
       bi_line_dim_mv h,
       bi_branch_dim i
 WHERE a.line_cd = b.line_cd(+)
   AND a.claim_id = b.claim_id(+)
   AND a.pol_iss_cd = d.iss_cd(+)
   AND a.iss_cd = e.iss_cd(+)
   AND a.clm_stat_cd = f.clm_stat_cd
   AND a.line_cd = h.line_cd(+)
   AND a.subline_cd = h.subline_cd(+)
   AND NVL (b.peril_cd, -1) = NVL (h.peril_cd, -1)
   AND a.pol_iss_cd = i.iss_cd;

COMMENT ON MATERIALIZED VIEW BIADMIN.BI_CLAIMS_MV IS 'snapshot table for snapshot BIADMIN.BI_CLAIMS_MV';

