CREATE MATERIALIZED VIEW BIADMIN.BI_LINE_DIM_MV 
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
/* Formatted on 2016/08/31 13:30 (Formatter Plus v4.8.8) */
SELECT ROWNUM line_code, a.*
  FROM (SELECT DISTINCT a.line_cd, a.line_name, b.subline_cd, b.subline_name,
                        c.peril_name, c.peril_cd, c.peril_sname, c.peril_type
                   FROM giis_line a, giis_subline b, giis_peril c
                  WHERE a.line_cd = b.line_cd AND a.line_cd = c.line_cd
        UNION ALL
        SELECT DISTINCT a.line_cd, a.line_name, b.subline_cd, b.subline_name,
                        NULL, NULL, NULL, NULL
                   FROM giis_line a, giis_subline b
                  WHERE a.line_cd = b.line_cd) a;

COMMENT ON MATERIALIZED VIEW BIADMIN.BI_LINE_DIM_MV IS 'snapshot table for snapshot BIADMIN.BI_LINE_DIM_MV';

