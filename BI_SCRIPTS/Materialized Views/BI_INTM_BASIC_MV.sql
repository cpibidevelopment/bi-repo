CREATE MATERIALIZED VIEW BIADMIN.BI_INTM_BASIC_MV 
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
/* Formatted on 2016/08/31 15:17 (Formatter Plus v4.8.8) */
SELECT DISTINCT DECODE (NVL (0, 1),
                        1, NVL (parent_intm_no, intrmdry_intm_no),
                        0, intrmdry_intm_no
                       ) agent_code
           FROM bi_intm_basic_mv1 b, gicl_claims a
          WHERE a.claim_id = b.claim_id
            AND (   parent_intm_no = NVL (a.intm_no, intrmdry_intm_no)
                 OR (       intrmdry_intm_no =
                                             NVL (a.intm_no, intrmdry_intm_no)
                        AND parent_intm_no IS NOT NULL
                     OR     intrmdry_intm_no =
                                             NVL (a.intm_no, intrmdry_intm_no)
                        AND parent_intm_no IS NULL
                    )
                );

COMMENT ON MATERIALIZED VIEW BIADMIN.BI_INTM_BASIC_MV IS 'snapshot table for snapshot BIADMIN.BI_INTM_BASIC_MV';

