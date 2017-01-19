DROP TABLE BIADMIN.BI_PRODUCTION_FACT CASCADE CONSTRAINTS;

CREATE TABLE BIADMIN.BI_PRODUCTION_FACT
(
  POLICY_CODE               NUMBER(12),
  POLICY_NO                 VARCHAR2(100 BYTE)  NOT NULL,
  ITEM_NO                   NUMBER(12),
  ITEM_TITLE                VARCHAR2(50 BYTE),
  LINE_CODE                 NUMBER(12),
  BRANCH_CODE               NUMBER(12),
  AGENT_CODE                NUMBER(12),
  ASSURED_CODE              NUMBER(12),
  ISSUE_DATE                NUMBER(12),
  INCEPT_DATE               NUMBER(12),
  EXP_DATE                  NUMBER(12),
  ACCT_ENT_DATE             NUMBER(12),
  SPOILED_ACCT_ENT_DATE     NUMBER(12),
  TSI                       NUMBER(16,5),
  MODAL_PREMIUM             NUMBER(16,5),
  POL_FLAG                  VARCHAR2(50 BYTE),
  SPEC_POL_FLAG             VARCHAR2(1 BYTE),
  LINE_CD                   VARCHAR2(2 BYTE)    NOT NULL,
  ISS_CD                    VARCHAR2(2 BYTE),
  PREM_SEQ_NO               NUMBER(12),
  CURRENCY_RT               NUMBER(12,9),
  SUBLINE_CD                VARCHAR2(7 BYTE),
  PERIL_CD                  NUMBER(5),
  POLICY_ID                 NUMBER(12),
  BRANCH_NAME               VARCHAR2(500 BYTE),
  BOOKING_DATE              NUMBER(12),
  ENDORSEMENT_NO            VARCHAR2(100 BYTE),
  RENEW_NO                  NUMBER(12),
  DIST_FLAG                 VARCHAR2(50 BYTE),
  REC_TYPE                  VARCHAR2(20 BYTE),
  BRANCH_CODE_DIST          NUMBER,
  EFF_DATE                  NUMBER,
  CHECK_ISSUE_DATE          NUMBER(12),
  CHECK_INCEPT_DATE         NUMBER(12),
  CHECK_BOOKING_DATE        NUMBER(12),
  CHECK_ACCT_ENT_DATE       NUMBER(12),
  CHECK_SPLD_ACCT_ENT_DATE  NUMBER(12),
  ENDT_SEQ_NO               NUMBER(6),
  POLICY_TYPE               VARCHAR2(300 BYTE),
  CRED_BRANCH_CODE          NUMBER(12)
)
TABLESPACE USERS
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING;
