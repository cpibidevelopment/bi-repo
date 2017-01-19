CREATE MATERIALIZED VIEW BIADMIN.BI_PROD_DIST_FACT_MV_TMP 
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
/* Formatted on 2016/08/31 13:40 (Formatter Plus v4.8.8) */
SELECT DISTINCT b.policy_id,
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
                || LTRIM (TO_CHAR (b.renew_no, '09'))
                || DECODE (NVL (b.endt_seq_no, 0),
                           0, '',
                              ' / '
                           || b.endt_iss_cd
                           || '-'
                           || LTRIM (TO_CHAR (b.endt_yy, '09'))
                           || '-'
                           || LTRIM (TO_CHAR (b.endt_seq_no, '9999999'))
                          ) policy_no,
                g.line_cd, b.subline_cd, g.share_cd, f.share_type,
                f.trty_name, f.trty_yy, g.dist_no, g.dist_seq_no, g.peril_cd,
                h.peril_type,
                  DECODE (f.share_type,
                          '1', NVL (g.dist_tsi, 0)
                         )
                * e.currency_rt nr_dist_tsi,
                  DECODE (f.share_type,
                          '1', NVL (g.dist_prem, 0)
                         )
                * e.currency_rt nr_dist_prem,
                DECODE (f.share_type, '1', g.dist_spct) nr_dist_spct,
                  DECODE (f.share_type,
                          '2', NVL (g.dist_tsi, 0)
                         )
                * e.currency_rt tr_dist_tsi,
                  DECODE (f.share_type,
                          '2', NVL (g.dist_prem, 0)
                         )
                * e.currency_rt tr_dist_prem,
                DECODE (f.share_type, '2', g.dist_spct) tr_dist_spct,
                  DECODE (f.share_type,
                          '3', NVL (g.dist_tsi, 0)
                         )
                * e.currency_rt fa_dist_tsi,
                  DECODE (f.share_type,
                          '3', NVL (g.dist_prem, 0)
                         )
                * e.currency_rt fa_dist_prem,
                DECODE (f.share_type, '3', g.dist_spct) fa_dist_spct,
                e.currency_rt, b.endt_seq_no, b.iss_cd, b.issue_yy,
                b.pol_seq_no, b.renew_no, b.endt_iss_cd, b.endt_yy,
                a.dist_flag, a.acct_ent_date, a.acct_neg_date, b.cred_branch,
                b.pol_flag, b.issue_date, e.prem_seq_no, b.eff_date,
                CASE
                   WHEN e.multi_booking_mm IS NOT NULL
                   AND e.multi_booking_yy IS NOT NULL
                      THEN TO_CHAR (LAST_DAY (TO_DATE (   '01-'
                                                       || e.multi_booking_mm
                                                       || '-'
                                                       || e.multi_booking_yy,
                                                       'DD-MONTH-YYYY'
                                                      )
                                             ),
                                    'YYYYMMDD'
                                   )
                END booking_date,
                j.iss_cd branch_cd_dist, b.assd_no assured_code,
                get_policy_no (b.policy_id) endorsement_no,
                b.reg_policy_sw spec_pol_flag
           FROM gipi_polbasic b,
                giuw_pol_dist a,
                giuw_perilds_dtl g,
                gipi_invoice e,
                giis_dist_share f,
                giis_peril h,
                giis_issource i,
                giis_issource j
          WHERE 1 = 1
            AND a.policy_id = b.policy_id
            AND DECODE (b.cred_branch, NULL, b.iss_cd, b.cred_branch) = i.iss_cd(+)
            AND b.iss_cd = j.iss_cd(+)
            AND g.dist_no = a.dist_no
            AND a.policy_id = e.policy_id
            AND b.reg_policy_sw = DECODE (NULL, 'Y', b.reg_policy_sw, 'Y')
            AND NVL (b.line_cd, b.line_cd) = f.line_cd
            AND NVL (b.line_cd, b.line_cd) = f.line_cd
            AND NVL (b.line_cd, b.line_cd) = f.line_cd
            AND b.line_cd >= '%'
            AND b.subline_cd >= '%'
            AND g.share_cd = f.share_cd
            AND g.share_cd = f.share_cd
            AND g.peril_cd = h.peril_cd
            AND g.line_cd = h.line_cd
            --AND TRUNC(b.issue_date) BETWEEN :p_from_date AND :p_to_date
            AND NVL (b.endt_type, 'A') = 'A'
            AND NVL (a.item_grp, 1) = NVL (e.item_grp, 1)
            --AND ROWNUM <=500
            AND NVL (a.takeup_seq_no, 1) = NVL (e.takeup_seq_no, 1);

COMMENT ON MATERIALIZED VIEW BIADMIN.BI_PROD_DIST_FACT_MV_TMP IS 'snapshot table for snapshot BIADMIN.BI_PROD_DIST_FACT_MV_TMP';

