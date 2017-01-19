CREATE MATERIALIZED VIEW BIADMIN.BI_INTM_BASIC_MV1 
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
/* Formatted on 2016/08/31 15:15 (Formatter Plus v4.8.8) */
SELECT   /*+ALL_ROWS*/
         --totel--10/11/2007--added hint for opt
         a.claim_id,
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
         || LTRIM (TO_CHAR (b.renew_no, '09')) policy_no,
         c.intrmdry_intm_no, e.parent_intm_no, e.intm_type, e.intm_name
    FROM gicl_claims a,
         gipi_polbasic b,
         gipi_comm_invoice c,
         giis_intermediary e
   WHERE a.renew_no = b.renew_no
     AND a.pol_seq_no = b.pol_seq_no
     AND a.issue_yy = b.issue_yy
     AND a.pol_iss_cd = b.iss_cd
     AND a.subline_cd = b.subline_cd
     AND a.line_cd = b.line_cd
     AND b.policy_id = c.policy_id
     AND b.pol_flag NOT IN ('4', '5')
     AND a.loss_date >= TRUNC (b.eff_date)
     AND c.intrmdry_intm_no = e.intm_no
GROUP BY a.claim_id,
         b.line_cd,
         b.subline_cd,
         b.iss_cd,
         b.issue_yy,
         b.pol_seq_no,
         b.renew_no,
         c.intrmdry_intm_no,
         e.parent_intm_no,
         e.intm_type,
         e.intm_name;

COMMENT ON MATERIALIZED VIEW BIADMIN.BI_INTM_BASIC_MV1 IS 'snapshot table for snapshot BIADMIN.BI_INTM_BASIC_MV1';

