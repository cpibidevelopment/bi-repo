CREATE MATERIALIZED VIEW BIADMIN.BI_PRODUCTION_FACT_AGENT_MV 
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
/* Formatted on 2016/08/31 13:31 (Formatter Plus v4.8.8) */
SELECT d.policy_id, c.iss_cd, c.prem_seq_no, b.intrmdry_intm_no,
       NVL (b.premium_amt, 0) * NVL (c.currency_rt, 1) share_premium,
       NVL (b.commission_amt, 0) * NVL (c.currency_rt, 1) commission_amt,
       NVL ((SELECT 1
               FROM giac_new_comm_inv t
              WHERE t.iss_cd = c.iss_cd
                AND t.prem_seq_no = c.prem_seq_no
                AND t.acct_ent_date IS NOT NULL
                AND t.tran_flag = 'P'
                AND NVL (t.delete_sw, 'N') = 'N'
                AND t.acct_ent_date >= NVL (c.acct_ent_date, d.acct_ent_date)
                AND ROWNUM < 2),
            0
           ) exists_giac_new,
       b.share_percentage,
       NVL (b.wholding_tax, 0) * NVL (c.currency_rt, 1) wholding_tax
  FROM gipi_comm_invoice b, gipi_invoice c, gipi_polbasic d
 WHERE b.policy_id = c.policy_id
   AND b.iss_cd = c.iss_cd
   AND b.prem_seq_no = c.prem_seq_no
   AND c.policy_id = d.policy_id;

COMMENT ON MATERIALIZED VIEW BIADMIN.BI_PRODUCTION_FACT_AGENT_MV IS 'snapshot table for snapshot BIADMIN.BI_PRODUCTION_FACT_AGENT_MV';

