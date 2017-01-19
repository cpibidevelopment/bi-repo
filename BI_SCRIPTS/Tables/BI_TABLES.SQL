SET SERVEROUTPUT ON
SET FEEDBACK  OFF  

BEGIN  
DBMS_OUTPUT.PUT_LINE('##DROPPING BI  TABLES##'); 
DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------------------------'); 
END;   
/

BEGIN  
   process_object('BI_PROD_BUD_ACT_FACT',  'TABLE ','DROP');   
   process_object('BI_PROD_DIST_FACT',  'TABLE ','DROP');
  -- process_object('BUD_ACT_PROD',  'TABLE ','DROP');     
   process_object('BI_GIIS_CLM_STAT',  'TABLE ','DROP');
   process_object('BI_AGENT_DIM  CASCADE CONSTRAINT  ',  'TABLE ','DROP');
   process_object('BI_COLLECTION_TAX_FACT',  'TABLE ','DROP');
   process_object('BI_COLLECTION_FACT',  'TABLE ','DROP');
  -- process_object('BI_ASSURED_DIM CASCADE CONSTRAINT ',  'TABLE ','DROP');
   process_object('BI_PRODUCTION_FACT',  'TABLE ','DROP');
   process_object('BI_PRODUCTION_TAX_FACT',  'TABLE ','DROP');      
   process_object('BI_LINE_DIM CASCADE CONSTRAINT  ',  'TABLE ','DROP');
   process_object('BI_LINE_SUB_LINE_DIM CASCADE CONSTRAINT  ',  'TABLE ','DROP');
   process_object('BI_BRANCH_DIM CASCADE CONSTRAINT  ',  'TABLE ','DROP');
   process_object('BI_TIME_DIM CASCADE CONSTRAINT ',  'TABLE ','DROP');
   process_object('BI_PRODUCTION_FACT_ACCT_ENT',  'TABLE ','DROP');
   process_object('BI_CLAIMS_FACT',  'TABLE ','DROP');                             
   process_object('BI_CLAIMS_AGENT_FACT',  'TABLE ','DROP');  
   process_object('BI_CLAIMS_LP_AGENT_FACT',  'TABLE ','DROP');  
   process_object('BI_OUTSTANDING_FACT',  'TABLE ','DROP');  
   process_object('BI_CLAIMS_LOSSES_PAID_FACT',  'TABLE ','DROP');
   process_object('BI_CLAIMS_REG_FACT', 'TABLE ', 'DROP');
   process_object('BI_CLAIMS_BRDRX_FACT', 'TABLE ', 'DROP');
   process_object('BI_CLAIMS_BRDRX_TAKE_UP_FACT', 'TABLE ', 'DROP');  
END;   

/


BEGIN  
DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------------------------'); 
END;   
/


BEGIN  
DBMS_OUTPUT.PUT_LINE('##CREATING BI  TABLES##'); 
DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------------------------'); 
END;   
/


CREATE TABLE BI_AGENT_DIM
(
  AGENT_CODE    NUMBER(12)                      PRIMARY KEY,
  AGENT_NAME    VARCHAR2(240)                   NOT NULL,
  AGENT_TYPE    VARCHAR2(50)                    NOT NULL,
  BRANCH_NAME   VARCHAR2(500)                   /* NOT NULL*/,
  PARENT_AGENT  VARCHAR2(240)   ,
  PARENT_AGENT_CODE NUMBER(12), 
  BIRTHDATE     DATE         
);


BEGIN
DBMS_OUTPUT.PUT_LINE('BI_AGENT_DIM--created....');      
END;   
/

/*
CREATE TABLE  BI_ASSURED_DIM
(
   ASSURED_CODE  NUMBER(12) PRIMARY KEY,
   ASSURED_NAME  VARCHAR2(/*240*/500) NOT NULL,
   ACTIVE_TAG VARCHAR2(1),
   BIRTH_DATE DATE,
   CORPORATE_TAG VARCHAR2(1),
   ASSURED_GRP VARCHAR2(100)
);
*/

BEGIN
DBMS_OUTPUT.PUT_LINE('BI_ASSURED_DIM--created....');      
END;   
/


CREATE TABLE  BI_LINE_DIM
(
   LINE_CODE     NUMBER(12) PRIMARY KEY,
   LINE_NAME     VARCHAR2(50) NOT NULL,
   SUBLINE_NAME  VARCHAR2(50) NOT NULL,
   PERIL_NAME     VARCHAR2(50) NOT NULL,
   PERIL_SNAME   VARCHAR2(4), 
   PERIL_TYPE    VARCHAR2(1)
);




BEGIN
DBMS_OUTPUT.PUT_LINE('BI_LINE_DIM--created....');      
END;   
/

CREATE TABLE  BI_LINE_SUB_LINE_DIM
(
   LINE_CODE     NUMBER(12) PRIMARY KEY,
   LINE_NAME     VARCHAR2(50) NOT NULL,
   SUBLINE_NAME  VARCHAR2(50) NOT NULL
);


BEGIN
DBMS_OUTPUT.PUT_LINE('BI_LINE_SUB_LINE_DIM--created....');      
END;   
/

CREATE TABLE  BI_BRANCH_DIM
(
   BRANCH_CODE     NUMBER(12) PRIMARY KEY,
   BRANCH_NAME     VARCHAR2(50) NOT NULL,
   BRANCH_GROUP    VARCHAR2(50) /*NOT NULL*/,
   CITY            VARCHAR2(50) /*NOT NULL*/,
   REGION          VARCHAR2(50),
   LVL_NAME        VARCHAR2(100), 
   SLV_NAME        VARCHAR2(100),   
   ISS_CD          VARCHAR2(12)
);


BEGIN
DBMS_OUTPUT.PUT_LINE('BI_BRANCH_DIM--created....');      
END;   
/


CREATE TABLE BI_TIME_DIM
(
  TIME_CODE      NUMBER(12) PRIMARY KEY,
  CALENDAR_DATE  DATE  NOT NULL,
  YEAR_NO        NUMBER(4)  NOT NULL,
  QUARTER_NO      NUMBER(1) NOT NULL,
  MONTH_NO       NUMBER(2) NOT NULL,
  MONTH_NAME     VARCHAR2(20 BYTE)  NOT NULL,  
  WEEK_NO        NUMBER(1) NOT NULL,
  DATE_OF_MONTH  NUMBER(2) NOT NULL 
);


BEGIN
DBMS_OUTPUT.PUT_LINE('BI_TIME_DIM--created....');      
END;   
/

    
CREATE TABLE BI_COLLECTION_FACT
(
  COLLECTION_CODE   NUMBER(12)                  NOT NULL,
  LINE_CODE         NUMBER(12)                  NOT NULL,
  BRANCH_CODE       NUMBER(12)                  NOT NULL,
  AGENT_CODE        NUMBER(12)                  NOT NULL,
  ASSURED_CODE      NUMBER(12)                  NOT NULL,
  POLICY_NO         VARCHAR2(50 BYTE)           NOT NULL,
  TRAN_DATE         NUMBER(12)                   ,
  POS_DATE          NUMBER(12)                  NOT NULL,
  PREMIUM_AMOUNT    NUMBER(12,2)                NOT NULL--,
  /*TAX_AMOUNT        NUMBER(12,2)                NOT NULL,
  EVAT              NUMBER(12,2),
  LOCAL_GOV_TAX     NUMBER(12,2),
  DOC_STAMPS        NUMBER(12,2),
  FIRE_SERVICE_TAX  NUMBER(12,2),
  OTHER_CHARGES     NUMBER(12,2)*/
);


BEGIN
DBMS_OUTPUT.PUT_LINE('BI_COLLECTION_FACT--created....');      
END;   
/




CREATE TABLE  BI_PRODUCTION_FACT
(
  POLICY_CODE            NUMBER(12) PRIMARY KEY ,  
  POLICY_NO              VARCHAR2(100) NOT NULL,
  LINE_CODE              NUMBER(12) ,
  BRANCH_CODE            NUMBER(12),
  AGENT_CODE             NUMBER(12),
  ASSURED_CODE           NUMBER(12),
  ISSUE_DATE             NUMBER(12),
  INCEPT_DATE            NUMBER(12),
  EXP_DATE               NUMBER(12),  
  ACCT_ENT_DATE          NUMBER(12),
  SPOILED_ACCT_ENT_DATE  NUMBER(12),    
  TSI                    NUMBER(16,5),  
  MODAL_PREMIUM          NUMBER(16,5),
  ANNUAL_PREMIUM         NUMBER(16,5),      
  EVAT                   NUMBER(12,2),
  LOCAL_GOV_TAX          NUMBER(12,2),
  DOC_STAMPS             NUMBER(12,2),
  FIRE_SERVICE_TAX       NUMBER(12,2),
  OTHER_CHARGES          NUMBER(12,2),    
  --COMMISSION_AMT         NUMBER(12,2),
  RET_PREM               NUMBER(12,2),
  FACUL_PREM             NUMBER(12,2),
  TREATY_PREM            NUMBER(12,2),
  POL_FLAG               VARCHAR2(50),
  SPEC_POL_FLAG          VARCHAR2(1),
  LINE_CD                VARCHAR2(2 BYTE) NOT NULL,
  ISS_CD                 VARCHAR2(2 BYTE),
  PREM_SEQ_NO            NUMBER(12),
  CURRENCY_RT            NUMBER(12,9),
  SUBLINE_CD             VARCHAR2(7 BYTE),
  PERIL_CD               NUMBER(5),
  POLICY_ID              NUMBER(12),     
  BRANCH_NAME            VARCHAR2(500),
  BOOKING_DATE           NUMBER(12),
  ENDORSEMENT_NO         VARCHAR2(100),
  RENEW_NO               NUMBER(12),   
  DIST_FLAG              VARCHAR2(50),
  REC_TYPE               VARCHAR2(20),
  RET_PREM_ACCT_ENT      NUMBER,
  DIST_TSI_RET           NUMBER,
  DIST_TSI_FACUL         NUMBER,
  DIST_TSI_TREATY        NUMBER,
  BRANCH_CODE_DIST       NUMBER,
  EFF_DATE               NUMBER,
  --ACCT_NEG_DATE           NUMBER(12),
  CHECK_ISSUE_DATE          NUMBER(12),
  CHECK_INCEPT_DATE         NUMBER(12),
  CHECK_BOOKING_DATE        NUMBER(12),
  CHECK_ACCT_ENT_DATE       NUMBER(12),
  CHECK_SPLD_ACCT_ENT_DATE  NUMBER(12),
  ENDT_SEQ_NO               NUMBER(6),
  POLICY_TYPE               VARCHAR2(300),
  LINE_SUBLINE_CODE         NUMBER,
  CRED_BRANCH_CODE	 NUMBER(12)							
);



BEGIN
DBMS_OUTPUT.PUT_LINE('BI_PRODUCTION_FACT--created....');      
END;   
/

CREATE TABLE  BI_PRODUCTION_FACT_ACCT_ENT
(
  POLICY_CODE            NUMBER(12) PRIMARY KEY ,  
  POLICY_NO              VARCHAR2(100) NOT NULL,
  LINE_CODE              NUMBER(12) NOT NULL,
  BRANCH_CODE            NUMBER(12),
  AGENT_CODE             NUMBER(12),
  ASSURED_CODE           NUMBER(12),
  ISSUE_DATE             NUMBER(12),
  INCEPT_DATE            NUMBER(12),
  EXP_DATE               NUMBER(12),  
  ACCT_ENT_DATE          NUMBER(12),
  SPOILED_ACCT_ENT_DATE  NUMBER(12),  
  BOOKING_MONTH          VARCHAR2(10 BYTE),
  BOOKING_YEAR           NUMBER(4),       
  TSI                    NUMBER(16,2),  
  MODAL_PREMIUM          NUMBER(16,2),
  ANNUAL_PREMIUM         NUMBER(16,2),      
  EVAT                   NUMBER(12,2),
  LOCAL_GOV_TAX          NUMBER(12,2),
  DOC_STAMPS             NUMBER(12,2),
  FIRE_SERVICE_TAX       NUMBER(12,2),
  OTHER_CHARGES          NUMBER(12,2),    
  COMMISSION_AMT         NUMBER(12,2),
  RET_PREM               NUMBER(12,2),
  FACUL_PREM             NUMBER(12,2),
  POL_FLAG               VARCHAR2(50),
  SPEC_POL_FLAG          VARCHAR2(1),
  LINE_CD                VARCHAR2(2 BYTE) NOT NULL,
  ISS_CD                 VARCHAR2(2 BYTE),
  PREM_SEQ_NO            NUMBER(12),
  CURRENCY_RT            NUMBER(12,9),
  OFFICE_CODE            NUMBER(12),
  SUBLINE_CD             VARCHAR2(7 BYTE),
  PERIL_CD               NUMBER(5),
  POLICY_ID              NUMBER(12),     
  BRANCH_NAME            VARCHAR2(500),
  BOOKING_DATE           NUMBER(12),
  ENDORSEMENT_NO         VARCHAR2(100),
  RENEW_NO               NUMBER(12) 
);



BEGIN
DBMS_OUTPUT.PUT_LINE('BI_PRODUCTION_FACT_ACCT_ENT--created....');      
END;   
/


CREATE TABLE BI_CLAIMS_FACT
(
  CLAIM_SEQNO            NUMBER(12),
  CLAIM_ID               NUMBER(12),
  LINE_SUBLINE_CODE      NUMBER(12),
  ASSD_NO                NUMBER(12),
  CLAIM_NO               VARCHAR2(24 BYTE),
  POLICY_NO              VARCHAR2(30 BYTE),
  ISSUE_SOURCE           VARCHAR2(7 BYTE),
  CLAIMS_BRANCH_CODE     NUMBER(12),
  CLAIM_STATUS           VARCHAR2(30 BYTE),
  EXPENSE_AMOUNT         NUMBER(16,5),
  LOSS_AMOUNT            NUMBER(16,5),
  EXP_RETENTION_AMT      NUMBER(16,5),
  EXP_PROPOR_TREATY      NUMBER(16,5),
  EXP_FACULTATIVE        NUMBER(16,5),
  EXP_NONPROPOR_TREATY   NUMBER(16,5),
  LOSS_RETENTION_AMT     NUMBER(16,5),
  LOSS_PROPOR_TREATY     NUMBER(16,5),
  LOSS_FACULTATIVE       NUMBER(16,5),
  LOSS_NONPROPOR_TREATY  NUMBER(16,5),
  LOSS_DATE              NUMBER(12),
  FILE_DATE              NUMBER(12),
  EFFECTIVITY_DATE       NUMBER(12),
  CLOSE_DATE             NUMBER(12),
  CONSTRAINT  bi_claims_fact_fk1 FOREIGN KEY (line_subline_code)            REFERENCES bi_line_sub_line_dim(line_code),
  CONSTRAINT  bi_claims_fact_fk2 FOREIGN KEY (loss_date)                    REFERENCES bi_time_dim(time_code),
  CONSTRAINT  bi_claims_fact_fk3 FOREIGN KEY (claims_branch_code)           REFERENCES bi_branch_dim(branch_code),
  CONSTRAINT  bi_claims_fact_fk4 FOREIGN KEY (file_date)                    REFERENCES bi_time_dim(time_code),
  CONSTRAINT  bi_claims_fact_fk5 FOREIGN KEY (effectivity_date)             REFERENCES bi_time_dim(time_code),
  CONSTRAINT  bi_claims_fact_fk6 FOREIGN KEY (close_date)                    REFERENCES bi_time_dim(time_code)  
);

BEGIN
DBMS_OUTPUT.PUT_LINE('BI_CLAIMS_FACT--created....');      
END; 
/



CREATE TABLE BI_CLAIMS_AGENT_FACT
(
  LOSS_DATE              NUMBER,
  FILE_DATE              NUMBER,
  EFFECTIVITY_DATE       NUMBER,
  CLOSE_DATE             NUMBER,
  LOSS_AMOUNT            NUMBER,
  EXPENSE_AMOUNT         NUMBER,
  LOSS_RETENTION         NUMBER,
  EXPENSE_RETENTION      NUMBER,
  LOSS_PROPOR_TREATY     NUMBER,
  EXP_PROPOR_TREATY      NUMBER,
  LOSS_FACULTATIVE       NUMBER,
  EXP_FACULTATIVE        NUMBER,
  LOSS_NONPROPOR_TREATY  NUMBER,
  EXP_NONPROPOR_TREATY   NUMBER,
  CLAIM_ID               NUMBER(12),
  ASSD_NO                NUMBER(12),
  PARENT_NO              NUMBER(12),
  ISSUE_YY               NUMBER(2),
  RENEW_NO               NUMBER(2),
  PERIL_CD               NUMBER(5),
  POL_SEQ_NO             NUMBER(10),
  LINE_CD                VARCHAR2(2 BYTE),
  ISS_CD                 VARCHAR2(2 BYTE),
  POL_ISS_CD             VARCHAR2(2 BYTE),
  INTM_TYPE              VARCHAR2(2 BYTE),
  CLM_STAT_CD            VARCHAR2(2 BYTE),
  OLD_STAT_CD            VARCHAR2(2 BYTE),
  PARENT_NAME            VARCHAR2(150 BYTE),
  CLAIM_NO               VARCHAR2(30 BYTE),
  POLICY_NO              VARCHAR2(30 BYTE),
  SUBLINE_CD             VARCHAR2(10 BYTE),
  LINE_CODE              NUMBER
);


BEGIN
DBMS_OUTPUT.PUT_LINE('BI_CLAIMS_AGENT_FACT--created....');      
END; 
/


CREATE TABLE BI_COLLECTION_TAX_FACT
(
  COLLECTION_CODE   NUMBER(12)                  NOT NULL,
  LINE_CODE         NUMBER(12)                  NOT NULL,
  BRANCH_CODE       NUMBER(12)                  ,
  AGENT_CODE        NUMBER(12)                  ,
  ASSURED_CODE      NUMBER(12)                  ,
  POLICY_NO         VARCHAR2(50 BYTE)           ,
  TRAN_DATE         NUMBER(12)                  ,
  POS_DATE          NUMBER(12)                ,
  PREMIUM_AMOUNT    NUMBER(12,2)               ,
  TAX_AMOUNT        NUMBER(12,2),
  EVAT              NUMBER(12,2),
  LOCAL_GOV_TAX     NUMBER(12,2),
  DOC_STAMPS        NUMBER(12,2),
  FIRE_SERVICE_TAX  NUMBER(12,2),
  OTHER_CHARGES     NUMBER(12,2),
  BOOK_TAG          VARCHAR2(1),
  COLLECTION_AMOUNT NUMBER,
  GIBR_BRANCH_CODE  NUMBER(12)                  ,
  TRAN_FLAG         VARCHAR2(1),
  BILL_NO           VARCHAR2(100),
  TRAN_CLASS        VARCHAR2(5),
  COMMISSION_AMT    NUMBER ,
  WTAX_AMT          NUMBER, 
  INPUT_VAT_AMT     NUMBER   
);


BEGIN
DBMS_OUTPUT.PUT_LINE('BI_COLLECTION_TAX_FACT--created....');      
END;
/


CREATE TABLE  BI_PRODUCTION_TAX_FACT
(
  POLICY_CODE            NUMBER(12) PRIMARY KEY ,  
  POLICY_NO              VARCHAR2(100) NOT NULL,
  LINE_CODE              NUMBER(12) NOT NULL,
  BRANCH_CODE            NUMBER(12),
  AGENT_CODE             NUMBER(12),
  ASSURED_CODE           NUMBER(12),
  ISSUE_DATE             NUMBER(12),
  INCEPT_DATE            NUMBER(12),
  EXP_DATE               NUMBER(12),  
  ACCT_ENT_DATE          NUMBER(12),
  SPOILED_ACCT_ENT_DATE  NUMBER(12),      
  TSI                    NUMBER(16,2),  
  MODAL_PREMIUM          NUMBER(16,2),
  ANNUAL_PREMIUM         NUMBER(16,2),      
  EVAT                   NUMBER(12,2),
  LOCAL_GOV_TAX          NUMBER(12,2),
  DOC_STAMPS             NUMBER(12,2),
  FIRE_SERVICE_TAX       NUMBER(12,2),
  OTHER_CHARGES          NUMBER(12,2),    
  COMMISSION_AMT         NUMBER(12,2),
  RET_PREM               NUMBER(12,2),
  FACUL_PREM             NUMBER(12,2),
  POL_FLAG               VARCHAR2(50),
  SPEC_POL_FLAG          VARCHAR2(1),
  LINE_CD                VARCHAR2(2 BYTE) NOT NULL,
  ISS_CD                 VARCHAR2(2 BYTE),
  PREM_SEQ_NO            NUMBER(12),
  CURRENCY_RT            NUMBER(12,9),
  OFFICE_CODE            NUMBER(12),
  SUBLINE_CD             VARCHAR2(7 BYTE),
  POLICY_ID              NUMBER(12),     
  BRANCH_NAME            VARCHAR2(500),
  BOOKING_DATE           NUMBER(12),
  ENDORSEMENT_NO         VARCHAR2(100),
  RENEW_NO               NUMBER(12),
  DIST_FLAG              VARCHAR2(50),
  REC_TYPE               VARCHAR2(20),
  WHOLDING_TAX		 NUMBER,
  EFF_DATE               NUMBER,
  ENDT_SEQ_NO            NUMBER(6),
  POLICY_TYPE            VARCHAR2(300),
  CRED_BRANCH_CODE	 NUMBER(12)
);
  

BEGIN
DBMS_OUTPUT.PUT_LINE('BI_PRODUCTION_TAX_FACT--created....');      
END;
/

CREATE TABLE BI_GIIS_CLM_STAT
(
  CLM_STAT_CD    VARCHAR2(2 BYTE)               NOT NULL,
  CLM_STAT_DESC  VARCHAR2(30 BYTE)              NOT NULL,
  CLM_STAT_TYPE  VARCHAR2(2 BYTE)               NOT NULL,
  REMARKS        VARCHAR2(4000 BYTE),
  USER_ID        VARCHAR2(8 BYTE)               NOT NULL,
  LAST_UPDATE    DATE                           NOT NULL,
  CPI_REC_NO     NUMBER(12),
  CPI_BRANCH_CD  VARCHAR2(2 BYTE)
 );


BEGIN
DBMS_OUTPUT.PUT_LINE('BI_GIIS_CLM_STAT--created....');      
END;
/

   CREATE TABLE bi_prod_bud_act_fact
   (BUD_ACT_SEQNO NUMBER(12) PRIMARY KEY,
    BRANCH_CODE   NUMBER(12), 
    LINE_CODE     NUMBER(12), 
    BUD_ACT_DATE  NUMBER(12), 
    ACTUAL_AMT    NUMBER(16,2), 
    BUDGET_AMT    NUMBER(16,2), 
    PRD_AMT       NUMBER(16,2),
    MX_AMT        NUMBER(16,2)
   );
    
    
BEGIN
DBMS_OUTPUT.PUT_LINE('BI_PROD_BUD_ACT_FACT--created....');      
END;
/


/*CREATE TABLE BUD_ACT_PROD
(
  ISS_CD   VARCHAR2(2 BYTE)                     NOT NULL,
  ACCT_YR  NUMBER(4)                            NOT NULL,
  JAN_BUD  NUMBER(12,2),
  JAN_ACT  NUMBER(12,2),
  FEB_BUD  NUMBER(12,2),
  FEB_ACT  NUMBER(12,2),
  MAR_BUD  NUMBER(12,2),
  MAR_ACT  NUMBER(12,2),
  APR_BUD  NUMBER(12,2),
  APR_ACT  NUMBER(12,2),
  MAY_BUD  NUMBER(12,2),
  MAY_ACT  NUMBER(12,2),
  JUN_BUD  NUMBER(12,2),
  JUN_ACT  NUMBER(12,2),
  JUL_BUD  NUMBER(12,2),
  JUL_ACT  NUMBER(12,2),
  AUG_BUD  NUMBER(12,2),
  AUG_ACT  NUMBER(12,2),
  SEP_BUD  NUMBER(12,2),
  SEP_ACT  NUMBER(12,2),
  OCT_BUD  NUMBER(12,2),
  OCT_ACT  NUMBER(12,2),
  NOV_BUD  NUMBER(12,2),
  NOV_ACT  NUMBER(12,2),
  DEC_BUD  NUMBER(12,2),
  DEC_ACT  NUMBER(12,2),
  JAN_PRD  NUMBER(12,2),
  JAN_MX   NUMBER(12,2),
  FEB_PRD  NUMBER(12,2),
  FEB_MX   NUMBER(12,2),
  MAR_PRD  NUMBER(12,2),
  MAR_MX   NUMBER(12,2),
  APR_PRD  NUMBER(12,2),
  APR_MX   NUMBER(12,2),
  MAY_PRD  NUMBER(12,2),
  MAY_MX   NUMBER(12,2),
  JUN_PRD  NUMBER(12,2),
  JUN_MX   NUMBER(12,2),
  JUL_PRD  NUMBER(12,2),
  JUL_MX   NUMBER(12,2),
  AUG_PRD  NUMBER(12,2),
  AUG_MX   NUMBER(12,2),
  SEP_PRD  NUMBER(12,2),
  SEP_MX   NUMBER(12,2),
  OCT_PRD  NUMBER(12,2),
  OCT_MX   NUMBER(12,2),
  NOV_PRD  NUMBER(12,2),
  NOV_MX   NUMBER(12,2),
  DEC_PRD  NUMBER(12,2),
  DEC_MX   NUMBER(12,2)
);


BEGIN
DBMS_OUTPUT.PUT_LINE('BUD_ACT_PROD--created....');      
END;
/

*/

CREATE TABLE BI_PROD_DIST_FACT
(
  PROD_DIST_CODE    NUMBER(12)                  PRIMARY KEY ,
  POLICY_ID         NUMBER(12)                  NOT NULL,
  POLICY_NO         VARCHAR2(50),
  LINE_CODE         NUMBER(12),
  BRANCH_CODE       NUMBER(12),
  CRED_BRANCH_CODE  NUMBER(12),
  POL_FLAG          VARCHAR2(50),
  DIST_FLAG         VARCHAR2(50),
  EFF_DATE          NUMBER(12),
  ISSUE_DATE        NUMBER(12),
  BOOKING_DATE      NUMBER(12),
  ACCT_ENT_DATE     NUMBER(12),
  ACCT_NEG_DATE     NUMBER(12),
  NR_DIST_TSI       NUMBER(16,5),
  NR_DIST_PREM      NUMBER(16,5),
  NR_DIST_SPCT      NUMBER(16,5),
  TR_DIST_TSI       NUMBER(16,5),
  TR_DIST_PREM      NUMBER(16,5),
  TR_DIST_SPCT      NUMBER(16,5),
  FA_DIST_TSI       NUMBER(16,5),
  FA_DIST_PREM      NUMBER(16,5),
  ENDORSEMENT_NO    VARCHAR2(100),
  SPEC_POL_FLAG     VARCHAR2(5),
  ASSURED_CODE      NUMBER,
  CONSTRAINT  bi_prod_dist_fact_fk1 FOREIGN KEY (line_code)   REFERENCES bi_line_dim(line_code),
  CONSTRAINT  bi_prod_dist_fact_fk2 FOREIGN KEY (branch_code) REFERENCES bi_branch_dim(branch_code),
  CONSTRAINT  bi_prod_dist_fact_fk3 FOREIGN KEY (cred_branch_code)  REFERENCES bi_branch_dim(branch_code),
  CONSTRAINT  bi_prod_dist_fact_fk4 FOREIGN KEY (eff_date)  REFERENCES bi_time_dim(time_code),
  CONSTRAINT  bi_prod_dist_fact_fk5 FOREIGN KEY (issue_date)  REFERENCES bi_time_dim(time_code),
  CONSTRAINT  bi_prod_dist_fact_fk6 FOREIGN KEY (booking_date)  REFERENCES bi_time_dim(time_code),
  CONSTRAINT  bi_prod_dist_fact_fk7 FOREIGN KEY (acct_ent_date)  REFERENCES bi_time_dim(time_code),
  CONSTRAINT  bi_prod_dist_fact_fk8 FOREIGN KEY (acct_neg_date)  REFERENCES bi_time_dim(time_code) ,
  CONSTRAINT  bi_prod_dist_fact_fk9 FOREIGN KEY (assured_code)  REFERENCES bi_assured_dim(assured_code) 
);

BEGIN
DBMS_OUTPUT.PUT_LINE('BUD_ACT_PROD--created....');      
END;
/


CREATE TABLE BI_CLAIMS_LP_AGENT_FACT
(
  CLAIM_REC           NUMBER(12) PRIMARY KEY,
  POLICY_ID           NUMBER,
  LINE_CODE           NUMBER,
  LOSSES_PAID         NUMBER(16,5),
  EXPENSES_PAID       NUMBER(16,5),
  SHR_PCT             NUMBER,
 -- LINE_SUBLINE_CODE   NUMBER,
  CLAIM_ID            NUMBER(12)                NOT NULL,
  BRANCH_CODE         NUMBER(12),
  AGENT_CODE          NUMBER(12),
  ASSURED_CODE        NUMBER(12),
  TRAN_ID             NUMBER(12),
  INTM_NO             NUMBER(12),
  -- CLAIMS_BRANCH_CODE  NUMBER(12),
  CONVERT_RATE        NUMBER(12,9),
  LOSS_RESERVE        NUMBER(16,5),
  EXPENSE_RESERVE     NUMBER(16,5),
  CLM_RES_HIST_ID     NUMBER(5),
  PERIL_CD            NUMBER(5),
  ITEM_NO             NUMBER(9),
  CANCEL_TAG          VARCHAR2(1 BYTE),
  DIST_SW             VARCHAR2(1 BYTE),
  POL_ISS_CD          VARCHAR2(2 BYTE),
  LOSS_CAT_DES        VARCHAR2(25 BYTE),
  CLAIM_NO            VARCHAR2(26 BYTE),
  POLICY_NO           VARCHAR2(30 BYTE),
  CLAIM_STATUS        VARCHAR2(30 BYTE),
  CLAIM_STATUS_GRP    VARCHAR2(30 BYTE),
  TRAN_DATE           NUMBER,
  TRAN_FLAG           VARCHAR2(4000 BYTE),
  INTM_NAME           VARCHAR2(4000 BYTE),
  ISSUE_SOURCE        VARCHAR2(7 BYTE),
  EFFECTIVITY_DATE    NUMBER,
  LOSS_DATE           NUMBER,
  DATE_PAID           NUMBER,
  FILE_DATE           NUMBER,
  CANCEL_DATE         NUMBER,
  CONSTRAINT  bi_claims_lp_agent_fact_fk1 FOREIGN KEY (line_code)   REFERENCES bi_line_dim(line_code),
  CONSTRAINT  bi_claims_lp_agent_fact_fk2 FOREIGN KEY (branch_code) REFERENCES bi_branch_dim(branch_code),
  CONSTRAINT  bi_claims_lp_agent_fact_fk3 FOREIGN KEY (agent_code)  REFERENCES bi_agent_dim(agent_code),
  CONSTRAINT  bi_claims_lp_agent_fact_fk4 FOREIGN KEY (assured_code)  REFERENCES bi_assured_dim(assured_code),
 -- CONSTRAINT  bi_claims_lp_agent_fact_fk5 FOREIGN KEY (posting_date)  REFERENCES bi_time_dim(time_code),
  CONSTRAINT  bi_claims_lp_agent_fact_fk5 FOREIGN KEY (tran_date)  REFERENCES bi_time_dim(time_code),
  CONSTRAINT  bi_claims_lp_agent_fact_fk6 FOREIGN KEY (loss_date)  REFERENCES bi_time_dim(time_code),
  CONSTRAINT  bi_claims_lp_agent_fact_fk7 FOREIGN KEY (file_date)  REFERENCES bi_time_dim(time_code),
 -- CONSTRAINT  bi_claims_lp_agent_fact_fk9 FOREIGN KEY (booking_date)  REFERENCES bi_time_dim(time_code),
  CONSTRAINT  bi_claims_lp_agent_fact_fk8 FOREIGN KEY (date_paid)  REFERENCES bi_time_dim(time_code),
  --CONSTRAINT  bi_claims_lp_agent_fact_fk11 FOREIGN KEY (close_date) REFERENCES bi_time_dim(time_code),
  --CONSTRAINT  bi_claims_lp_agent_fact_fk12 FOREIGN KEY (close_date2)  REFERENCES bi_time_dim(time_code)  ,
  CONSTRAINT  bi_claims_lp_agent_fact_fk9 FOREIGN KEY (cancel_date)  REFERENCES bi_time_dim(time_code)
);

BEGIN
DBMS_OUTPUT.PUT_LINE('BI_CLAIMS_LP_AGENT_FACT--created....');      
END;
/

CREATE TABLE BI_CLAIMS_LOSSES_PAID_FACT
(
  CLAIM_REC           NUMBER(12) PRIMARY KEY,
  POLICY_ID           NUMBER,
  LINE_CODE           NUMBER,
  LOSSES_PAID         NUMBER(16,5),
  EXPENSES_PAID       NUMBER(16,5),
  SHR_PCT             NUMBER,
  LINE_SUBLINE_CODE   NUMBER,
  CLAIM_ID            NUMBER(12)                NOT NULL,
  BRANCH_CODE         NUMBER(12),
  ASSURED_CODE        NUMBER(12),
  TRAN_ID             NUMBER(12),
  CLAIMS_BRANCH_CODE  NUMBER(12),
  CONVERT_RATE        NUMBER(12,9),
  PERIL_CD            NUMBER(5),
  ITEM_NO             NUMBER(9),
  CANCEL_TAG          VARCHAR2(1 BYTE),
  DIST_SW             VARCHAR2(1 BYTE),
  TRAN_FLAG           VARCHAR2(4000 BYTE),
  POL_ISS_CD          VARCHAR2(2 BYTE),
  LOSS_CAT_DES        VARCHAR2(25 BYTE),
  CLAIM_NO            VARCHAR2(26 BYTE),
  POLICY_NO           VARCHAR2(30 BYTE),
  CLAIM_STATUS        VARCHAR2(30 BYTE),
  CLAIM_STATUS_GRP    VARCHAR2(30 BYTE),
  TRAN_DATE           NUMBER,
  ISSUE_SOURCE        VARCHAR2(7 BYTE),
  EFFECTIVITY_DATE    NUMBER,
  LOSS_DATE           NUMBER,
  DATE_PAID           NUMBER,
  FILE_DATE           NUMBER,
  CANCEL_DATE         NUMBER,
  CONSTRAINT  bi_claims_losses_pd_fact_fk1 FOREIGN KEY (line_code)   REFERENCES bi_line_dim(line_code),
  CONSTRAINT  bi_claims_losses_pd_fact_fk2 FOREIGN KEY (branch_code) REFERENCES bi_branch_dim(branch_code),
--  CONSTRAINT  bi_claims_losses_paid_fact_fk3 FOREIGN KEY (agent_code)  REFERENCES bi_agent_dim(agent_code),
  CONSTRAINT  bi_claims_losses_pd_fact_fk3 FOREIGN KEY (assured_code)  REFERENCES bi_assured_dim(assured_code),
  CONSTRAINT  bi_claims_losses_pd_fact_fk4 FOREIGN KEY (effectivity_date)  REFERENCES bi_time_dim(time_code),
  CONSTRAINT  bi_claims_losses_pd_fact_fk5 FOREIGN KEY (tran_date)  REFERENCES bi_time_dim(time_code),
  CONSTRAINT  bi_claims_losses_pd_fact_fk6 FOREIGN KEY (loss_date)  REFERENCES bi_time_dim(time_code),
  CONSTRAINT  bi_claims_losses_pd_fact_fk7 FOREIGN KEY (file_date)  REFERENCES bi_time_dim(time_code),
 -- CONSTRAINT  bi_claims_losses_paid_fact_fk9 FOREIGN KEY (booking_date)  REFERENCES bi_time_dim(time_code),
  CONSTRAINT  bi_claims_losses_pd_fact_fk8 FOREIGN KEY (date_paid)  REFERENCES bi_time_dim(time_code),
  --CONSTRAINT  bi_claims_losses_paid_fact_fk11 FOREIGN KEY (close_date) REFERENCES bi_time_dim(time_code),
  --CONSTRAINT  bi_claims_losses_paid_fact_fk12 FOREIGN KEY (close_date2)  REFERENCES bi_time_dim(time_code)  ,
  CONSTRAINT  bi_claims_losses_pd_fact_fk9 FOREIGN KEY (cancel_date)  REFERENCES bi_time_dim(time_code),
  CONSTRAINT  bi_claims_losses_pd_fact_fk10 FOREIGN KEY (claims_branch_code)  REFERENCES bi_branch_dim(branch_code),
  CONSTRAINT  bi_claims_losses_pd_fact_fk11 FOREIGN KEY (line_subline_code)  REFERENCES bi_line_sub_line_dim(line_code)
);

BEGIN
DBMS_OUTPUT.PUT_LINE('BI_CLAIMS_LOSSES_PAID_FACT--created....');      
END;
/


CREATE TABLE BI_OUTSTANDING_FACT
(
  CLAIM_REC        NUMBER(12) PRIMARY KEY,
  CLAIM_ID         NUMBER(12)                   NOT NULL,
  POLICY_NO        VARCHAR2(30 BYTE),
  CLAIM_NO         VARCHAR2(26 BYTE),
  LINE_CODE        NUMBER,
  BRANCH_CODE      NUMBER(12),
  AGENT_CODE       NUMBER(12),
  ASSURED_CODE     NUMBER(12),
  PERIL_CD         NUMBER(5),
  POSTING_DATE     NUMBER,
  TRAN_DATE        NUMBER,
  LOSS_DATE        NUMBER,
  FILE_DATE        NUMBER,
  BOOKING_DATE     NUMBER,
  TRAN_FLAG        VARCHAR2(100 BYTE),
  OS_LOSS          NUMBER(16,5),
  OS_EXPENSE       NUMBER(16,5),
  SHR_PCT          NUMBER(12,9),
  SHARE_TYPE       VARCHAR2(100 BYTE),
  DATE_PAID        NUMBER,
  LOSS_RESERVE     NUMBER(16,5),
  LOSSES_PAID      NUMBER(16,5),
  EXPENSE_RESERVE  NUMBER(16,5),
  EXPENSES_PAID    NUMBER(16,5),
  CLOSE_DATE       NUMBER,
  CLOSE_DATE2      NUMBER,
  CANCEL_TAG       VARCHAR2(1 BYTE),
  CANCEL_DATE      NUMBER,
  TAKEN_UP         CHAR(1 BYTE),
  CONSTRAINT  bi_outstanding_fact_fk1 FOREIGN KEY (line_code)   REFERENCES bi_line_dim(line_code),
  CONSTRAINT  bi_outstanding_fact_fk2 FOREIGN KEY (branch_code) REFERENCES bi_branch_dim(branch_code),
  CONSTRAINT  bi_outstanding_fact_fk3 FOREIGN KEY (agent_code)  REFERENCES bi_agent_dim(agent_code),
  CONSTRAINT  bi_outstanding_fact_fk4 FOREIGN KEY (assured_code)  REFERENCES bi_assured_dim(assured_code),
  CONSTRAINT  bi_outstanding_fact_fk5 FOREIGN KEY (posting_date)  REFERENCES bi_time_dim(time_code),
  CONSTRAINT  bi_outstanding_fact_fk6 FOREIGN KEY (tran_date)  REFERENCES bi_time_dim(time_code),
  CONSTRAINT  bi_outstanding_fact_fk7 FOREIGN KEY (loss_date)  REFERENCES bi_time_dim(time_code),
  CONSTRAINT  bi_outstanding_fact_fk8 FOREIGN KEY (file_date)  REFERENCES bi_time_dim(time_code),
  CONSTRAINT  bi_outstanding_fact_fk9 FOREIGN KEY (booking_date)  REFERENCES bi_time_dim(time_code),
  CONSTRAINT  bi_outstanding_fact_fk10 FOREIGN KEY (date_paid)  REFERENCES bi_time_dim(time_code),
  CONSTRAINT  bi_outstanding_fact_fk11 FOREIGN KEY (close_date) REFERENCES bi_time_dim(time_code),
  CONSTRAINT  bi_outstanding_fact_fk12 FOREIGN KEY (close_date2)  REFERENCES bi_time_dim(time_code)  ,
  CONSTRAINT  bi_outstanding_fact_fk14 FOREIGN KEY (cancel_date)  REFERENCES bi_time_dim(time_code)
  --CONSTRAINT  bi_outstanding_fact_fk15 FOREIGN KEY (check_incept_date)  REFERENCES bi_time_dim(time_code),
  --CONSTRAINT  bi_outstanding_fact_fk16 FOREIGN KEY (check_booking_date)  REFERENCES bi_time_dim(time_code),
  --CONSTRAINT  bi_outstanding_fact_fk17 FOREIGN KEY (check_acct_ent_date)  REFERENCES bi_time_dim(time_code),
  --CONSTRAINT  bi_outstanding_fact_fk18 FOREIGN KEY (check_spld_acct_ent_date)  REFERENCES bi_time_dim(time_code)
);

BEGIN
DBMS_OUTPUT.PUT_LINE('BI_OUTSTANDING_FACT--created....');      
END;
/



CREATE TABLE BI_CLAIMS_REG_FACT
(
  CLAIM_ID         NUMBER(12),
  CLAIM_NO         VARCHAR2(50 BYTE),
  ITEM_NO          NUMBER(9),
  POLICY_NO        VARCHAR2(50 BYTE)            NOT NULL,
  CLM_RES_HIST_ID  NUMBER(12),
  CLAIM_STATUS     VARCHAR2(30 BYTE),
  PREM_AMT         NUMBER(12,2),
  LOSS_RESERVE     NUMBER(12,2),
  LOSSES_PAID      NUMBER(12,2),
  EXPENSE_RESERVE  NUMBER(12,2),
  EXPENSES_PAID    NUMBER(12,2),
  ANN_TSI_AMT      NUMBER(16,2),
  ASSURED_CODE     NUMBER(12),
  CLAIM_FILE_DATE  NUMBER(12),
  DSP_LOSS_DATE    NUMBER(12),
  CLM_ISS_CODE     NUMBER(12),
  LOSS_DATE        NUMBER(12),
  EFF_DATE         NUMBER(12),
  EXP_DATE         NUMBER(12),
  ITEM_TITLE       VARCHAR2(300 BYTE),
  AGENT            VARCHAR2(300 BYTE),
  RECOVERED_AMT    NUMBER(16,2),
  CANCEL_TAG       VARCHAR2(2 BYTE),
  CANCEL_DATE      NUMBER(12),
  POL_ISS_CODE     NUMBER(12),
  LINE_CODE        NUMBER(12)
);


BEGIN
DBMS_OUTPUT.PUT_LINE('BI_CLAIMS_REG_FACT--created....');      
END;
/



CREATE TABLE BI_CLAIMS_BRDRX_FACT
(
  CLAIM_ID          NUMBER(12),
  ITEM_NO           NUMBER(9),
  POLICY_NO         VARCHAR2(50 BYTE)           NOT NULL,
  CLAIM_NO          VARCHAR2(50 BYTE),
  ISS_CODE          VARCHAR2(12 BYTE),
  BRANCH_CODE       NUMBER(12),
  RI_CODE           NUMBER(12),
  LINE_CODE         VARCHAR2(12 BYTE),
  SUBLINE_CODE      VARCHAR2(12 BYTE),
  LOSS_YEAR         NUMBER(9),
  ASSURED_CODE      NUMBER(12),
  LOSS_DATE         NUMBER(12),
  CLAIM_FILE_DATE   NUMBER(12),
  INCEPT_DATE       NUMBER(12),
  EXPIRY_DATE       NUMBER(12),
  POL_ISS_CD        VARCHAR2(12 BYTE),
  ISSUE_YY          NUMBER(12),
  POL_SEQ_NO        NUMBER(12),
  RENEW_NO          NUMBER(12),
  PERIL_CD          NUMBER(12),
  LOSS_CAT_CD       VARCHAR2(12 BYTE),
  ANN_TSI_AMT       NUMBER(16,2),
  DIST_SW           VARCHAR2(10 BYTE),
  CONVERT_RATE      NUMBER(12,2),
  LOSS_RESERVE      NUMBER(12,2),
  LOSSES_PAID       NUMBER(12,2),
  EXPENSE_RESERVE   NUMBER(12,2),
  EXPENSES_PAID     NUMBER(12,2),
  GRP_ITEM_NO       NUMBER(12),
  CLM_RES_HIST_ID   NUMBER(12),
  GRP_ITEM_TITLE    VARCHAR2(50 BYTE),
  CONTROL_CD        NUMBER(12),
  CONTROL_TYPE_CD   NUMBER(12),
  BOOKING_YEAR      NUMBER(4),
  BOOKING_MONTH     VARCHAR2(10 BYTE),
  DATE_PAID         NUMBER(12),
  POSTING_DATE      NUMBER(12),
  CANCEL_TAG        VARCHAR2(1 BYTE),
  CANCEL_DATE       NUMBER(12),
  TRAN_ID           NUMBER(12),
  TRAN_DATE         NUMBER(12),
  BRDRX_TYPE        VARCHAR2(100 BYTE),
  CLOSE_DATE        NUMBER(12),
  CLOSE_DATE2       NUMBER(12),
  CURRENCY_RATE     NUMBER(4),
  INTM_NO           NUMBER(12),
  INTM_NAME         VARCHAR2(4000 BYTE),
  LOSS_CAT_DES      VARCHAR2(25 BYTE),
  CLAIM_STATUS      VARCHAR2(30 BYTE),
  ITEM_TITLE        VARCHAR2(4000 BYTE),
  CRED_BRANCH_CODE  NUMBER(12),
  REC_COUNT         NUMBER,
  ACC_POSTING_DATE  NUMBER(12),
  ACC_DATE_PAID     NUMBER(12),
  ACC_TRAN_ID       NUMBER(12),
  BUSS_SOURCE       NUMBER(10),
  BOOKING_DATE      NUMBER(12)
);

BEGIN
DBMS_OUTPUT.PUT_LINE('BI_CLAIMS_BRDRX_FACT--created....');      
END;
/


CREATE TABLE BI_CLAIMS_BRDRX_TAKE_UP_FACT
(
  CLAIM_ID             NUMBER(12),
  CLAIM_NO             VARCHAR2(50 BYTE),
  POLICY_NO            VARCHAR2(50 BYTE)        NOT NULL,
  ANN_TSI_AMT          NUMBER,
  ASSURED_NO           NUMBER(12),
  BUSS_SOURCE          NUMBER(2),
  CLM_RES_HIST_ID      NUMBER(12),
  GROUPED_ITEM_NO      NUMBER,
  ITEM_NO              NUMBER,
  LOSS_YEAR            NUMBER(9),
  OS_EXPENSE           NUMBER(12,2),
  OS_LOSS              NUMBER(12,2),
  TRAN_FLAG            VARCHAR2(10 BYTE),
  ACCT_DATE            NUMBER(12),
  CLM_FILE_DATE        NUMBER(12),
  EXPIRY_DATE          NUMBER(12),
  INCEPT_DATE          NUMBER(12),
  LOSS_DATE            NUMBER(12),
  POSTING_DATE         NUMBER(12),
  TRAN_DATE            NUMBER(12),
  ISS_BRANCH_CODE      NUMBER(12),
  POL_ISS_BRANCH_CODE  NUMBER(12),
  LINE_CODE            NUMBER(12),
  LOSS_CAT_DES         VARCHAR2(50 BYTE),
  ITEM_TITLE           VARCHAR2(4000 BYTE)
);

BEGIN
DBMS_OUTPUT.PUT_LINE('BI_CLAIMS_BRDRX_TAKE_UP_FACT--created....');      
END;
/


BEGIN  
DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------------------------'); 
END;   
/
