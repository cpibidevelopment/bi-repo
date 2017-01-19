CREATE MATERIALIZED VIEW BIADMIN.BI_TAX_MV 
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
USING INDEX
            TABLESPACE USERS
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
REFRESH FORCE ON DEMAND
WITH PRIMARY KEY
AS 
/* Formatted on 2016/08/31 11:33 (Formatter Plus v4.8.8) */
SELECT   g.prem_seq_no, g.iss_cd,
         SUM (  DECODE (g.tax_cd, /*giacp.n('LGT')*/ 6, NVL (g.tax_amt, 0), 0)
              * NVL (b.currency_rt, 1)
             ) local_gov_tax,
         SUM (  DECODE (g.tax_cd, /*giacp.n('FST')*/ 5, NVL (g.tax_amt, 0), 0)
              * NVL (b.currency_rt, 1)
             ) fire_service_tax,
         SUM (  DECODE (g.tax_cd, /*giacp.n('EVAT')*/
                        3, NVL (g.tax_amt, 0),
                        0
                       )
              * NVL (b.currency_rt, 1)
             ) evat,
         SUM (  DECODE (g.tax_cd, /*giacp.n('DOC_STAMPS')*/
                        1, NVL (g.tax_amt, 0),
                        0
                       )
              * NVL (b.currency_rt, 1)
             ) doc_stamps,
         SUM (CASE
                 WHEN g.tax_cd NOT IN (6, 5, 3, 1)
                    THEN NVL (g.tax_amt, 0) * NVL (b.currency_rt, 1)
              END
             ) other_charges
    FROM gipi_invoice b, gipi_inv_tax g
   WHERE b.iss_cd = g.iss_cd AND b.prem_seq_no = g.prem_seq_no
GROUP BY g.prem_seq_no, g.iss_cd;

COMMENT ON MATERIALIZED VIEW BIADMIN.BI_TAX_MV IS 'snapshot table for snapshot BIADMIN.BI_TAX_MV';

-- Note: Index I_SNAP$_BI_TAX_MV will be created automatically 
--       by Oracle with the associated materialized view.

