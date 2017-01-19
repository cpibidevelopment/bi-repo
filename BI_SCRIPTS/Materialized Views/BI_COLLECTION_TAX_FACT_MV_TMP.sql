DROP MATERIALIZED VIEW BIADMIN.BI_COLLECTION_TAX_FACT_MV_TMP;
CREATE MATERIALIZED VIEW BIADMIN.BI_COLLECTION_TAX_FACT_MV_TMP 
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
/* Formatted on 12/9/2016 2:34:42 PM (QP5 v5.227.12220.39754) */
  SELECT h.intm_no,
         UPPER (h.intm_name) intm_name,
         b.policy_id,
         j.iss_name,
         a.b140_iss_cd,
         a.b140_prem_seq_no,
         UPPER (l.assd_name) assd_name,
         SUM (NVL (a.premium_amt, 0) * (NVL (g.share_percentage, 100) / 100))
            premium,
         c.tran_class,
         i.line_cd,
         i.line_name,
         b.subline_cd,
         k.subline_name,
         f.assd_no,
         c.posting_date posting_date,
         c.tran_id,
         a.gacc_tran_id,
         c.tran_date tran_date,
         c.tran_flag,
         SUM (a.collection_amt * (NVL (g.share_percentage, 100) / 100))
            collection_amt,
         DECODE (d.acct_ent_date, NULL, 'U', 'B') book_tag,
         a.b140_iss_cd || '-' || TO_CHAR (a.b140_prem_seq_no) bill_no,
         SUM (a.tax_amt * (NVL (g.share_percentage, 100) / 100)) tax_amt,
         g.share_percentage,
         TRUNC (d.due_date) due_date,
         b.pol_flag pol_flag_code,
         TRUNC (b.eff_date) eff_date,
         TRUNC (b.incept_date) incept_date
    FROM gipi_polbasic b,
         giac_acctrans c,
         gipi_invoice d,
         gipi_parlist e,
         giis_assured f,
         gipi_comm_invoice g,
         giis_intermediary h,
         giis_line i,
         giis_issource j,
         giis_subline k,
         giac_direct_prem_collns a,
         giis_assured l
   WHERE     b.policy_id = d.policy_id
         AND d.iss_cd = a.b140_iss_cd
         AND d.prem_seq_no = a.b140_prem_seq_no
         AND a.gacc_tran_id = c.tran_id
         AND c.tran_id > 0
         AND c.tran_flag <> 'D'
         AND g.intrmdry_intm_no = h.intm_no
         AND g.iss_cd = d.iss_cd
         AND g.prem_seq_no = d.prem_seq_no
         AND g.policy_id = d.policy_id
         AND a.b140_iss_cd = j.iss_cd
         AND b.assd_no = l.assd_no(+)
         AND b.line_cd = i.line_cd(+)
         AND b.line_cd = k.line_cd(+)
         AND b.subline_cd = k.subline_cd(+)
         AND b.par_id = e.par_id
         AND e.assd_no = f.assd_no
         AND NOT EXISTS
                    (SELECT x.gacc_tran_id
                       FROM giac_reversals x, giac_acctrans y
                      WHERE     x.reversing_tran_id = y.tran_id
                            AND y.tran_flag <> 'D'
                            AND x.gacc_tran_id = a.gacc_tran_id)
GROUP BY f.assd_no,
         f.assd_name,
         h.intm_no,
         h.intm_name,
         a.b140_iss_cd,
         a.b140_prem_seq_no,
         c.tran_flag,
         c.posting_date,
         d.prem_amt + d.tax_amt,
         DECODE (d.acct_ent_date, NULL, 'U', 'B'),
         b.line_cd,
         c.tran_id,
         a.gacc_tran_id,
         b.subline_cd,
         k.subline_name,
         g.share_percentage,
         c.tran_date,
         c.tran_flag,
         i.line_name,
         j.iss_name,
         b.policy_id,
         c.tran_class,
         i.line_cd,
         DECODE (d.acct_ent_date, NULL, 'U', 'B'),
         UPPER (l.assd_name),
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
         || DECODE (
               NVL (b.endt_seq_no, 0),
               0, '',
                  ' / '
               || b.endt_iss_cd
               || '-'
               || LTRIM (TO_CHAR (b.endt_yy, '09'))
               || '-'
               || LTRIM (TO_CHAR (b.endt_seq_no, '0999999'))),
         d.due_date,
         b.pol_flag,
         b.eff_date,
         b.incept_date;


COMMENT ON MATERIALIZED VIEW BIADMIN.BI_COLLECTION_TAX_FACT_MV_TMP IS 'snapshot table for snapshot BIADMIN.BI_COLLECTION_TAX_FACT_MV_TMP';
