CREATE OR REPLACE PACKAGE BIADMIN.pkg_transform 
AS
    /************************************************************
    Date Created: August 14, 2015
    Developer: Edward
    Description: This package constains procedures that will perform transformation and loading based from 
                 materialized views. 
                *Production
                *Production Distribution  
                *Collection     
                *Claims    
   **************************************************************/          
       TYPE coll_tax_rec     IS RECORD (
                                  COLLECTION_CODE    NUMBER(12),
                                  LINE_CODE          NUMBER(12)  ,
                                  BRANCH_CODE        NUMBER(12)  ,
                                  AGENT_CODE         NUMBER(12)   ,
                                  ASSURED_CODE       NUMBER(12)  ,
                                  POLICY_NO          VARCHAR2(50) ,
                                  ENDORSEMENT_NO          VARCHAR2(50) ,    
                                  TRAN_DATE          NUMBER(12)  ,
                                  POS_DATE           NUMBER(12)   ,
                                  PREMIUM_AMOUNT     NUMBER(12,2), 
                                  TAX_AMOUNT         NUMBER(12,2)  ,
                                  EVAT               NUMBER(12,2),
                                  LOCAL_GOV_TAX      NUMBER(12,2),
                                  DOC_STAMPS         NUMBER(12,2),
                                  FIRE_SERVICE_TAX   NUMBER(12,2),
                                  OTHER_CHARGES      NUMBER(12,2),
                                  BOOK_TAG          VARCHAR2(1),
                                  COLLECTION_AMOUNT NUMBER,
                                  GIBR_BRANCH_CODE  NUMBER(12)                  ,
                                  TRAN_FLAG         VARCHAR2(1),
                                  BILL_NO           VARCHAR2(100),
                                  TRAN_CLASS        VARCHAR2(5),
                                  COMMISSION_AMT    NUMBER ,
                                  WTAX_AMT          NUMBER, 
                                  INPUT_VAT_AMT     NUMBER,
                                  POLICY_ID         NUMBER(12),
                                  DUE_DATE          NUMBER(12),
                                  EFF_DATE          NUMBER(12),
                                  OR_DATE           NUMBER(12),
                                  INCEPT_DATE       NUMBER(12),
                                  POL_FLAG          VARCHAR2(100 BYTE),
                                  AGE               NUMBER,
                                  INVOICE_PREM_AMT  NUMBER(12,2)
                                );                 
       TYPE coll_rec     IS RECORD (
                                  COLLECTION_CODE    NUMBER(12),
                                  LINE_CODE          NUMBER(12)  ,
                                  BRANCH_CODE        NUMBER(12)  ,
                                  AGENT_CODE         NUMBER(12)   ,
                                  ASSURED_CODE       NUMBER(12)  ,
                                  POLICY_NO          VARCHAR2(50) ,  
                                  TRAN_DATE          NUMBER(12)  ,
                                  POS_DATE           NUMBER(12)   ,
                                  PREMIUM_AMOUNT     NUMBER(12,2));   
                                 
       TYPE prod_tax_rec IS RECORD (POLICY_CODE            NUMBER(12),
                                    POLICY_NO              VARCHAR2(100)  ,
                                    LINE_CODE              NUMBER(12) ,
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
                                    LINE_CD                VARCHAR2(2) , 
                                    ISS_CD                 VARCHAR2(2),
                                    PREM_SEQ_NO            NUMBER(12),
                                    CURRENCY_RT            NUMBER(12,9),
                                    OFFICE_CODE            NUMBER(12),
                                    SUBLINE_CD             VARCHAR2(7),
                                    POLICY_ID              NUMBER(12),
                                    BRANCH_NAME            VARCHAR2(500),
                                    BOOKING_DATE           NUMBER(12),
                                    ENDORSEMENT_NO         VARCHAR2(100),
                                    RENEW_NO               NUMBER(12),
                                    DIST_FLAG              VARCHAR2(50),
                                    REC_TYPE               VARCHAR2(20),
                                    WHOLDING_TAX         NUMBER,
                                    EFF_DATE               NUMBER,
                                    ENDT_SEQ_NO            NUMBER(6),
                                    POLICY_TYPE            VARCHAR2(300),
                                    CRED_BRANCH_CODE       NUMBER,
                                    ENDT_TYPE              VARCHAR2(2 BYTE),
                                    REINSTATE_TAG          VARCHAR2(2 BYTE)
                                  );         
                                  
        TYPE prod_rec IS RECORD  (
                                      POLICY_CODE            NUMBER(12),
                                      POLICY_NO              VARCHAR2(100 )  ,
                                      ITEM_NO                NUMBER(12),
                                      ITEM_TITLE             VARCHAR2(50 BYTE),
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
--                                      ANNUAL_PREMIUM         NUMBER(16,5),      
--                                      EVAT                   NUMBER(12,2),
--                                      LOCAL_GOV_TAX          NUMBER(12,2),
--                                      DOC_STAMPS             NUMBER(12,2),
--                                      FIRE_SERVICE_TAX       NUMBER(12,2),
--                                      OTHER_CHARGES          NUMBER(12,2),    
--                                      --COMMISSION_AMT         NUMBER(12,2),
--                                      RET_PREM               NUMBER(12,2),
--                                      FACUL_PREM             NUMBER(12,2),
--                                      TREATY_PREM            NUMBER(12,2),
                                      POL_FLAG               VARCHAR2(50),
                                      SPEC_POL_FLAG          VARCHAR2(1),
                                      LINE_CD                VARCHAR2(2 BYTE) ,
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
--                                      RET_PREM_ACCT_ENT      NUMBER,
--                                      DIST_TSI_RET           NUMBER,
--                                      DIST_TSI_FACUL         NUMBER,
--                                      DIST_TSI_TREATY        NUMBER,
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
                                      CRED_BRANCH_CODE          NUMBER    
                                  );                                                      
     TYPE production       IS TABLE OF  prod_rec;                                   
     TYPE production_tax   IS TABLE OF  prod_tax_rec;    
     TYPE prod_dist_rec    IS RECORD       
                                (
                                  PROD_DIST_CODE    NUMBER(12),
                                  POLICY_ID         NUMBER(12)  ,
                                  POLICY_NO         VARCHAR2(48),
                                  LINE_CODE         NUMBER,
                                  BRANCH_CODE       NUMBER(12),
                                  CRED_BRANCH_CODE  NUMBER(12),
                                  POL_FLAG          VARCHAR2(100),
                                  DIST_FLAG         VARCHAR2(100),
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
                                  SPEC_POL_FLAG     VARCHAR2(5),
                                  ASSURED_CODE      NUMBER                                  
                                );
     TYPE production_dist  IS TABLE OF prod_dist_rec;              
     TYPE line_info    IS RECORD (line_name GIIS_LINE.line_name%TYPE, subline_name GIIS_SUBLINE.subline_name%TYPE, peril_name GIIS_PERIL.peril_name%TYPE );     
     v_line_info line_info;
     PROCEDURE generate_production_tax;
     PROCEDURE generate_collection_tax;
     PROCEDURE generate_budget;
     PROCEDURE generate_production;     
     PROCEDURE process_date(p1 IN  DATE, p_time_code OUT BI_TIME_DIM.time_code%TYPE) ;
     --PROCEDURE generate_collection;
     PROCEDURE generate_claims_reg;
     PROCEDURE generate_claims;
     PROCEDURE generate_claims_brdrx;
     PROCEDURE generate_claims_take_up;
     --PROCEDURE generate_production_tax_rev;
     --PROCEDURE generate_production_rev;
     PROCEDURE generate_production_dist;
     PROCEDURE generate_claims_agent;
     PROCEDURE rerfresh_mviews;      
     PROCEDURE generate_claims_outstanding;
     PROCEDURE generate_claims_lp_agent;
     PROCEDURE generate_claims_losses_paid;         
     PROCEDURE generate_renewal;   
     v_production                  production;
     v_production_tax              production_tax;
     v_limit                       NUMBER DEFAULT 100000;
     v_mview_tax                   VARCHAR2(100):=  'BI_TAX_MV';
     v_mview_production_fact       VARCHAR2(100):=  'BI_PRODUCTION_FACT_MV';     
     v_mview_production_fact_agent VARCHAR2(100):=  'BI_PRODUCTION_FACT_AGENT_MV';
     v_mview_line_dim_view         VARCHAR2(100):=  'BI_LINE_DIM_VIEW_MV';        
     v_mview_collection_fact_tmp   VARCHAR2(100):=  'BI_COLLECTION_FACT_MV_TMP';            
     v_mview_collection_fact       VARCHAR2(100):=  'BI_COLLECTION_FACT_MV';     
     v_ret_cd                        NUMBER  := GIISP.N('NET_RETENTION');
     v_fac_cd                        NUMBER  := GIISP.N('FACULTATIVE'); 
END;
/
