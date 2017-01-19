DROP MATERIALIZED VIEW BIADMIN.BI_COLLECTION_TAX_FACT_MV;
CREATE MATERIALIZED VIEW BIADMIN.BI_COLLECTION_TAX_FACT_MV 
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
/* Formatted on 12/9/2016 2:34:33 PM (QP5 v5.227.12220.39754) */
SELECT ROWNUM collection_code,
       a.*,
       c.line_code,
       b.iss_cd,
       b.prem_seq_no,
       a.premium modal_premium,
       0 evat,
       0 local_gov_tax,
       0 doc_stamps,
       0 fire_service_tax,
       0 other_charges,
       or_pref_suf || '-' || or_no or_no,
       or_date,
       gibr_branch_cd,
       TRUNC (d.or_date) - TRUNC (a.due_date) age,
       e.rv_meaning pol_flag,
       b.prem_amt invoice_prem_amt
  FROM bi_collection_tax_fact_mv_tmp a,
       gipi_invoice b,
       bi_line_dim_mv c,
       giac_order_of_payts d,
       cg_ref_codes e
 WHERE     a.policy_id = b.policy_id
       AND a.line_name = c.line_name
       AND a.subline_name = c.subline_name
       AND c.peril_cd IS NULL
       AND a.tran_id = d.gacc_tran_id(+)
       AND a.gacc_tran_id = d.gacc_tran_id(+)
       AND e.rv_domain = 'GIPI_POLBASIC.POL_FLAG'
       AND e.rv_low_value = a.pol_flag_code;


COMMENT ON MATERIALIZED VIEW BIADMIN.BI_COLLECTION_TAX_FACT_MV IS 'snapshot table for snapshot BIADMIN.BI_COLLECTION_TAX_FACT_MV';
