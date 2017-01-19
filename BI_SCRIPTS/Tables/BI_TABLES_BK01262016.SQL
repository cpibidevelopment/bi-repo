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
   process_object('BI_AGENT_DIM',  'TABLE ','DROP');
   process_object('BI_COLLECTION_TAX_FACT',  'TABLE ','DROP');
   process_object('BI_COLLECTION_FACT',  'TABLE ','DROP');
  -- process_object('BI_ASSURED_DIM',  'TABLE ','DROP');
   process_object('BI_PRODUCTION_FACT',  'TABLE ','DROP');
   process_object('BI_PRODUCTION_TAX_FACT',  'TABLE ','DROP');      
   process_object('BI_LINE_DIM',  'TABLE ','DROP');
   process_object('BI_LINE_SUB_LINE_DIM',  'TABLE ','DROP');
   process_object('BI_BRANCH_DIM',  'TABLE ','DROP');
   process_object('BI_TIME_DIM',  'TABLE ','DROP');
   process_object('BI_PRODUCTION_FACT_ACCT_ENT',  'TABLE ','DROP');
   process_object('BI_CLAIMS_FACT',  'TABLE ','DROP');                             
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
        CLAIM_ID                NUMBER(12) /*PRIMARY KEY  */ , 
        POLICY_NO               VARCHAR2(50) NOT NULL ,     
        CLAIM_NO                VARCHAR2(50),       
        LINE_CODE               NUMBER(12),      
        BRANCH_CODE             NUMBER(12), 
        AGENT_CODE              NUMBER(12),
        ASSURED_CODE            NUMBER(12), 
        ISSUE_DATE              NUMBER(12),
        EFFECTIVITY_DATE        NUMBER(12),
        ACCT_ENT_DATE           NUMBER(12),        
        BOOKING_DATE            NUMBER(12),
        TSI                     NUMBER(16),
        MODAL_PREMIUM           NUMBER(16),
        CLAIM_STATUS            VARCHAR2(100),  
        CLAIM_STATUS_GRP        VARCHAR2(100),          
        LOSS_DATE               NUMBER(12), 
        CLM_FILE_DATE           NUMBER(12), 
        CLM_DATE_PAID           NUMBER(12), 
        LOSS_AMT                NUMBER(16), 
        LOSS_RES_AMT            NUMBER(16),
        EXP_AMT                 NUMBER(12,2),
        LOSSES_PAID_AMT         NUMBER(12,2),
        OUTSTANDING_AMT         NUMBER(12,2)   ,
        RETENTION_AMT           NUMBER(12,2)   ,
        PROPOR_TREATY           NUMBER(12,2)   ,
        NONPROPOR_TREATY        NUMBER(12,2)   ,
        FACULTATIVE             NUMBER(12,2)          ,
        TRAN_ID                 NUMBER(12,2)          ,
        PERIL_CD                NUMBER(12,2)   ,
        LOSS_CAT_DES            VARCHAR2 (25 ),
        SPOILED_ACCT_ENT_DATE   NUMBER(12),
        ITEM_NO                 NUMBER(9)                         
);
                         

BEGIN
DBMS_OUTPUT.PUT_LINE('BI_CLAIMS_FACT--created....');      
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
  COMMISSION_AMT    NUMBER   
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
  POLICY_ID         NUMBER(12)                  NOT NULL,
  POLICY_NO         VARCHAR2(48 BYTE),
  LINE_CODE         NUMBER,
  BRANCH_CODE       NUMBER(12),
  CRED_BRANCH_CODE  NUMBER(12),
  POL_FLAG          VARCHAR2(100 BYTE),
  DIST_FLAG         VARCHAR2(100 BYTE),
  EFF_DATE          NUMBER,
  ISSUE_DATE        NUMBER,
  BOOKING_DATE      NUMBER,
  ACCT_ENT_DATE     NUMBER,
  ACCT_NEG_DATE     NUMBER,
  NR_DIST_TSI       NUMBER,
  NR_DIST_PREM      NUMBER,
  NR_DIST_SPCT      NUMBER,
  TR_DIST_TSI       NUMBER,
  TR_DIST_PREM      NUMBER,
  TR_DIST_SPCT      NUMBER,
  FA_DIST_TSI       NUMBER,
  FA_DIST_PREM      NUMBER,
  ENDORSEMENT_NO    VARCHAR2(100),
  SPEC_POL_FLAG     VARCHAR2(5)
);

BEGIN
DBMS_OUTPUT.PUT_LINE('BUD_ACT_PROD--created....');      
END;
/






BEGIN  
DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------------------------'); 
END;   
/
