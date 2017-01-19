CREATE OR REPLACE PACKAGE BODY BIADMIN.pkg_transform 
AS 
   FUNCTION get_ri_comm(p_iss_cd VARCHAR2, p_prem_seq_no NUMBER,p_line_cd VARCHAR2) 
   RETURN NUMBER 
   IS 
     v_output NUMBER;
   BEGIN
          SELECT SUM(ri_comm_amt)
            INTO v_output   
            FROM gipi_invperil a, giis_peril b
           WHERE  a.iss_cd =p_iss_cd
             AND a.prem_seq_no = p_prem_seq_no
             AND b.line_cd = p_line_cd
             AND a.peril_cd = b.peril_cd;
          RETURN v_output;
   EXCEPTION 
      WHEN OTHERS THEN 
          RETURN NULL;   
   END;
   FUNCTION Get_Policy_No (
       v_policy_id   gipi_polbasic.policy_id%TYPE
    )
       RETURN VARCHAR2
    IS
       v_policy_no   VARCHAR2 (50) := NULL;

       CURSOR pol (v_policy_id gipi_polbasic.policy_id%TYPE)
       IS
          SELECT    line_cd
                 || '-'
                 || subline_cd
                 || '-'
                 || iss_cd
                 || '-'
                 || LTRIM (TO_CHAR (issue_yy, '09'))
                 || '-'
                 || LTRIM (TO_CHAR (pol_seq_no, '0999999'))
                 || '-'
                 || LTRIM (TO_CHAR (renew_no, '09'))
                 || DECODE (
                       NVL (endt_seq_no, 0),
                       0, '',
                          ' / '
                       || endt_iss_cd
                       || '-'
                       || LTRIM (TO_CHAR (endt_yy, '09'))
                       || '-'
                       || LTRIM (TO_CHAR (endt_seq_no, '0999999'))
                    ) policy
            FROM gipi_polbasic
           WHERE policy_id = v_policy_id;
    BEGIN
       FOR rec IN pol (v_policy_id)
       LOOP
          v_policy_no := rec.policy;
          EXIT;
       END LOOP rec;

       RETURN (v_policy_no);
    END;
    
    FUNCTION Get_Pol_No (
       v_policy_id   gipi_polbasic.policy_id%TYPE
    )
       RETURN VARCHAR2
    IS
       v_policy_no   VARCHAR2 (50) := NULL;

       CURSOR pol (v_policy_id gipi_polbasic.policy_id%TYPE)
       IS
          SELECT    line_cd
                 || '-'
                 || subline_cd
                 || '-'
                 || iss_cd
                 || '-'
                 || LTRIM (TO_CHAR (issue_yy, '09'))
                 || '-'
                 || LTRIM (TO_CHAR (pol_seq_no, '0999999'))
                 || '-'
                 || LTRIM (TO_CHAR (renew_no, '09'))
                   policy
            FROM gipi_polbasic
           WHERE policy_id = v_policy_id;
    BEGIN
       FOR rec IN pol (v_policy_id)
       LOOP
          v_policy_no := rec.policy;
          EXIT;
       END LOOP rec;

       RETURN (v_policy_no);
    END;
        
    PROCEDURE saver(p1 BOOLEAN DEFAULT TRUE)
     IS
     BEGIN
        IF p1 
        THEN
          COMMIT;
        ELSE 
          ROLLBACK;
        END IF;
     
     END;     
     PROCEDURE gen_time_code(p1 DATE) 
     IS
       v_record BI_TIME_DIM%ROWTYPE;
     BEGIN
        SELECT  NULL,
                p1  calendar_date , 
                TO_CHAR(p1,'YYYY') year_no,
                CASE WHEN TO_CHAR( p1,'MM') BETWEEN 1 AND 3 
                     THEN
                            1
                     WHEN TO_CHAR( p1,'MM') BETWEEN 4 AND 6  
                     THEN
                            2
                     WHEN TO_CHAR( p1,'MM') BETWEEN 7 AND 9  
                     THEN
                            3
                     WHEN TO_CHAR( p1,'MM') BETWEEN 10 AND 12  
                     THEN
                            4             
                END  quarter_no ,
                TO_CHAR(p1,'MM') month_no ,
                TO_CHAR(p1,'MONTH') month_name,                
                CEIL(TO_CHAR(p1,'DD')) /7 week_no,
                TO_CHAR(p1,'DD') date_of_month
        INTO    v_record
        FROM    DUAL;   
        
      SELECT MAX(time_code)+1
       INTO  v_record.time_code
       FROM bi_time_dim;
             
        INSERT INTO BI_TIME_DIM  VALUES v_record;
     END;     
     FUNCTION get_time_code(p1 DATE) 
     RETURN  BI_TIME_DIM.time_code%TYPE
     IS  
       v_output    BI_TIME_DIM.time_code%TYPE;
     BEGIN     
           SELECT time_code
             INTO v_output 
             FROM BI_TIME_DIM
            WHERE calendar_date = p1;
       RETURN v_output;     
     EXCEPTION 
        WHEN NO_DATA_FOUND THEN 
         RETURN NULL;                    
     END;
     PROCEDURE process_date(p1 IN  VARCHAR2, p_time_code OUT BI_TIME_DIM.time_code%TYPE) 
     IS
     v_date DATE;
     BEGIN
          v_date := TO_DATE(LPAD(p1, 8, '0'), 'YYYYMMDD');
          
          p_time_code:=get_time_code(v_date);
          IF p_time_code  IS NULL  AND v_date IS NOT NULL 
          THEN
            gen_time_code(v_date);
            p_time_code:=get_time_code(v_date);
          END IF; 
     EXCEPTION 
        WHEN OTHERS THEN 
            dbms_output.put_line(V_DATE);
     END;    
     PROCEDURE process_date(p1 IN  DATE, p_time_code OUT BI_TIME_DIM.time_code%TYPE) 
     IS
     BEGIN
          p_time_code:=get_time_code(p1);
          IF p_time_code  IS NULL  AND p1 IS NOT NULL 
          THEN
            gen_time_code(p1);
            p_time_code:=get_time_code(p1);
          END IF; 
     END;  
     PROCEDURE populate_tax
     IS        
     BEGIN
         
     
     
         FORALL i IN  v_production_tax.FIRST..v_production_tax.LAST
                  INSERT INTO (SELECT  a.policy_code,
                                       a.policy_no ,           
                                       a.line_code, 
                                       a.branch_code,    
                                       a.agent_code,
                                       a.assured_code,  
                                       a.issue_date, 
                                       a.incept_date, 
                                       a.exp_date,
                                       a.acct_ent_date,
                                       a.spoiled_acct_ent_date  , 
                                       a.tsi,
                                       a.modal_premium,           
                                       a.annual_premium,
                                       a.evat, 
                                       a.local_gov_tax, 
                                       a.doc_stamps, 
                                       a.fire_service_tax, 
                                       a.other_charges,
                                       a.commission_amt, 
                                       a.ret_prem, 
                                       a.facul_prem, 
                                       a.pol_flag,
                                       a.spec_pol_flag,
                                       a.line_cd,
                                       a.iss_cd ,
                                       a.prem_seq_no , 
                                       a.currency_rt, 
                                       a.office_code ,                                             
                                       a.subline_cd,   
                                       a.policy_id ,
                                       a.branch_name,
                                       a.booking_date,
                                       a.endorsement_no ,
                                       a.renew_no,
                                       a.dist_flag,
                                       a.rec_type, 
                                       a.wholding_tax,
                                       a.eff_date,
                                       a.endt_seq_no, 
                                       a.policy_type,
                                       a.cred_branch_code,
                                       a.endt_type,
                                       a.reinstate_tag             
                                 FROM bi_production_tax_fact a
                                )
                          VALUES v_production_tax(i);
                          NULL;
     END;
     FUNCTION GET_branch_CODE (P_branch_NAME VARCHAR2)
     RETURN NUMBER
     AS
            v_branch_code   BI_BRANCH_DIM.BRANCH_CODE%TYPE := 0;
            v_group         BI_BRANCH_DIM.BRANCH_GROUP%TYPE;
            v_city          BI_BRANCH_DIM.CITY%TYPE;
            v_region        BI_BRANCH_DIM.REGION%TYPE;
            v_iss_cd        BI_BRANCH_DIM.ISS_CD%TYPE; 
            v_slv_name      BI_BRANCH_DIM.SLV_NAME%TYPE;
            v_lvl_name      BI_BRANCH_DIM.LVL_NAME%TYPE;
     BEGIN
               
       FOR branch IN (SELECT branch_code
                        FROM BI_BRANCH_DIM
                       WHERE branch_name = P_branch_NAME)
       LOOP
          v_branch_code := branch.branch_code;
       END LOOP;

       IF v_branch_code IS NULL OR v_branch_code = 0
       THEN
          FOR branch
             IN (SELECT  a.iss_name,
                                   UPPER (b.iss_grp_desc) iss_grp_desc,
                                   a.city,
                                   UPPER (c.region_desc) region_desc,
                                   DECODE(A.iss_level,10, 'HEAD OFFICE', 15, 'SPECIAL PROJECTS',
                                                      20, 'NATIONAL CAPITAL REGION',
                                                      30, 'LUZON OPERATIONS',
                                                      40, 'VISMIN OPERATIONS',
                                                      60, 'HO-PROVINCES',
                                                      70, 'REINSURANCE', ' ')lvl_name,
                                 DECODE(a.iss_cd, 'HA', ' ', 'HB', ' ', 'CS', ' ', 'CU', ' ', 
                                              'HF', ' ', 'HO', ' ','SI', ' ', 
                                              'MK', ' ', 'GM', ' ','CU', ' ', 
                                              'ST', ' ', 'DG', ' ','LU', ' ', 
                                              'AN', ' ', 'GB', ' ', 'CY', ' ',
                                              'GP', ' ', 'LB', ' ', 'NG' , ' ',
                                              'LG', ' ' , 'SU',' ','CE',' ',
                                              'TC',' ','SP',' ','GP',' ','GB',' ','') ||
                                 DECODE(a.cpi_branch_cd, 'HA', 'AGENCIES',
                                                         'HB', 'BROKERS', 
                                                         'DG', 'DAGUPAN',
                                                         'ST', 'SANTIAGO',
                                                         'GB', 'GENCARS',
                                                         'LG', 'LEGASPI',
                                                         'AN', 'GENERAL AGENCIES',
                                                         'MK', 'MAKATI SERVICE OFFICE',
                                                         'CE', 'CEBU',
                                                         'SP', 'SAN PABLO', a.iss_name) slv_name,                   
                                   a.iss_cd
                   FROM GIIS_ISSOURCE a, GIIS_GRP_ISSOURCE b, GIIS_REGION c
                  WHERE     a.iss_grp = b.iss_grp(+)
                        AND a.region_cd = c.region_cd(+)
                        AND UPPER (a.iss_name) = NVL(P_BRANCH_NAME,UPPER(a.iss_name)))
          LOOP
             v_group := branch.iss_grp_desc;
             v_city := branch.city;
             v_region := branch.region_desc;
             v_iss_cd := branch.iss_cd;
             v_slv_name   :=branch.slv_name;
             v_lvl_name := branch.lvl_name;
          END LOOP;

          SELECT NVL (MAX (branch_code), 0) + 1
            INTO v_branch_code
            FROM BI_BRANCH_DIM;

          INSERT INTO BI_branch_DIM
               VALUES (v_branch_code,
                       P_branch_NAME,
                       v_group,
                       v_city,
                       v_region,
                       v_lvl_name ,
                       v_slv_name,
                       v_iss_cd);

          COMMIT;
       END IF;

         RETURN v_branch_code;
     END;
     FUNCTION get_pol_flag_desc(p_pol_flag  GIPI_POLBASIC.pol_flag%TYPE)
     RETURN CG_REF_CODES.rv_meaning%TYPE
     IS
        v_output CG_REF_CODES.rv_meaning%TYPE;
     BEGIN
        SELECT  rv_meaning 
          INTO  v_output
          FROM  cg_ref_codes
         WHERE  rv_domain = 'GIPI_POLBASIC.POL_FLAG'
          AND   rv_low_value = p_pol_flag;
        RETURN  v_output;
     EXCEPTION 
        WHEN OTHERS THEN 
           RETURN NULL; 
     END; 
     FUNCTION get_office_name(p_iss_cd GIIS_ISSOURCE.iss_cd%TYPE) 
     RETURN GIIS_ISSOURCE.iss_name%TYPE
     IS
       v_output GIIS_ISSOURCE.iss_name%TYPE;
     BEGIN
          SELECT iss_name
            INTO v_output
            FROM  GIIS_ISSOURCE
           WHERE  iss_cd = p_iss_cd;
          RETURN v_output;
     EXCEPTION            
     WHEN OTHERS THEN 
          RETURN NULL;
     END;            
     FUNCTION get_line_info(p_line_cd GIIS_LINE.line_cd%TYPE, p_subline_cd GIIS_SUBLINE.subline_cd%TYPE, p_peril_cd GIIS_PERIL.peril_cd%TYPE)
     RETURN line_info     
     IS
       v_output line_info;
     BEGIN           
                                                         
       IF p_peril_cd IS NULL                 
       THEN    
             SELECT a.line_name , b.subline_name, NULL
                INTO  v_output
                FROM  GIIS_LINE a, GIIS_SUBLINE b 
                WHERE  a.line_cd  =b.line_cd
                  AND  a.line_cd = p_line_cd
                  AND  b.subline_cd= p_subline_cd; 
       
       ELSE
           SELECT a.line_name , b.subline_name, c.peril_name
                INTO  v_output
                FROM  GIIS_LINE a, GIIS_SUBLINE b , GIIS_PERIL c
                WHERE  a.line_cd  =b.line_cd
                  AND  a.line_cd = c.line_cd
                  AND  a.line_cd = p_line_cd
                  AND  b.subline_cd= p_subline_cd 
                  AND  c.peril_cd=p_peril_cd ;
       END IF;
                  
              RETURN v_output;
              
     EXCEPTION          
          WHEN NO_DATA_FOUND THEN 
          RETURN   v_output;                            
     END;     
    FUNCTION get_line_cd (P_LINE_NAME       VARCHAR2,
                           P_SUBLINE_NAME    VARCHAR2,
                           P_PERIL_NAME      VARCHAR2
                          )
     RETURN NUMBER
     AS
       v_line_code   bi_line_dim.line_code%TYPE := 0;
     BEGIN  
       FOR line
          IN (SELECT *
                FROM bi_line_dim
               WHERE line_name = P_LINE_NAME AND subline_name = P_SUBLINE_NAME AND peril_name =   P_PERIL_NAME   
             )
       LOOP
          v_line_code := line.line_code;
       END LOOP;

       IF v_line_code IS NULL OR v_line_code = 0
       THEN
       
       

          SELECT  NVL (MAX (line_code), 0) + 1
            INTO v_line_code
            FROM bi_line_dim;
       
          INSERT INTO bi_line_dim
                      (line_code, line_name, subline_name,  peril_name)   
               VALUES (v_line_code, P_LINE_NAME, P_SUBLINE_NAME,  P_PERIL_NAME);

          COMMIT;
       END IF;

       RETURN v_line_code;
     END;
     
   PROCEDURE refresh_mviews(p_mview  VARCHAR2)
   IS
   BEGIN
       DBMS_MVIEW.refresh( p_mview,method=>'c', atomic_refresh => true);
   END;
   PROCEDURE rerfresh_mviews
   IS
   BEGIN
        refresh_mviews(v_mview_tax);
        refresh_mviews(v_mview_production_fact);
        refresh_mviews(v_mview_production_fact_agent);
        refresh_mviews(v_mview_line_dim_view);
        refresh_mviews(v_mview_collection_fact_tmp);
        refresh_mviews(v_mview_collection_fact);
   END;   
    PROCEDURE generate_production_tax
     IS  
       TYPE branch_dim IS TABLE OF NUMBER INDEX BY bi_branch_dim.branch_name%TYPE;
       v_branch_dim  branch_dim;
       CURSOR c_production IS       
       SELECT ROWNUM                                                        policy_code,
           policy_no                                                      policy_no,
           line_code line_code, 
           NULL                                                             branch_code,    
           agent_code,
           assured_code,  
           issue_date, 
           incept_date, 
           exp_date,
           acct_ent_date,
           spoiled_acct_ent_date  , 
           tsi,
           modal_premium,           
           NULL                                                           annual_premium,
           evat                                                           evat, 
           local_gov_tax                                                  local_gov_tax, 
           doc_stamps                                                     doc_stamps, 
           fire_service_tax                                               fire_service_tax, 
           other_charges                                                  other_charges,
           commission_amt                                                 commission_amt, 
           ret_prem, 
           facul_prem, 
           pol_flag,
           spec_pol_flag                                                  spec_pol_flag,
           line_cd, 
           iss_cd ,
           prem_seq_no , 
           currency_rt,   
           NULL ,            
           subline_cd    ,
           policy_id,
           iss_name,
           booking_date,
           endorsement_no,
           renew_no ,
           dist_flag,
           'O'                                                          rec_type,
           wholding_tax,
           eff_date,
           endt_seq_no, 
           policy_type,
           cred_branch_code,
           endt_type,
           reinstate_tag
       FROM  bi_production_tax_fact_mv   
        /*remove to include Special Policies* JJJPajilan 4.17.2016*/ 
      --WHERE  (NVL(pol_flag,' ') != 'Spoiled'
        --AND  NVL(spec_pol_flag,'Y') = 'Y' )
         --OR  (spoiled_acct_ent_date IS NOT NULL  OR NVL(pol_flag,' ') = 'Spoiled'  )
       ;
        v_tax_info bi_tax_mv%ROWTYPE;    
        FUNCTION get_tax_info(p_iss_cd  gipi_invoice.iss_cd%TYPE, p_prem_seq_no  gipi_inv_tax.prem_seq_no%TYPE)
        RETURN bi_tax_mv%ROWTYPE
        IS
              v_output bi_tax_mv%ROWTYPE;
        BEGIN
                 SELECT * 
                   INTO v_output 
                   FROM bi_tax_mv
                  WHERE prem_seq_no =p_prem_seq_no 
                    AND iss_cd =p_iss_cd  ;
                                  
                 RETURN v_output;
         EXCEPTION 
              WHEN NO_DATA_FOUND THEN
                 RETURN v_output;
            
        END;                                                
     BEGIN
           EXECUTE IMMEDIATE 'TRUNCATE TABLE bi_production_tax_fact';
           v_branch_dim.delete;
           FOR I IN (SELECT branch_code, branch_name 
                       FROM bi_branch_dim
                   )
           LOOP
              v_branch_dim(i.branch_name):=i.branch_code;
           END LOOP; 
           OPEN   c_production;            
           LOOP  
             FETCH  c_production BULK COLLECT INTO v_production_tax  LIMIT v_limit;    
             EXIT WHEN v_production_tax.COUNT=0;           
             
             FOR i IN v_production_tax.FIRST..v_production_tax.LAST
             LOOP 
                process_date(TO_DATE(v_production_tax(i).issue_date,'YYYYMMDD'),v_production_tax(i).issue_date);                   
                process_date(TO_DATE(v_production_tax(i).incept_date,'YYYYMMDD'),v_production_tax(i).incept_date);
                process_date(TO_DATE(v_production_tax(i).acct_ent_date,'YYYYMMDD'),v_production_tax(i).acct_ent_date);
                process_date(TO_DATE(v_production_tax(i).spoiled_acct_ent_date,'YYYYMMDD'),v_production_tax(i).spoiled_acct_ent_date);
                process_date(TO_DATE(v_production_tax(i).booking_date,'YYYYMMDD'),v_production_tax(i).booking_date);
                process_date(TO_DATE(v_production_tax(i).exp_date,'YYYYMMDD'),v_production_tax(i).exp_date);
                process_date(TO_DATE(v_production_tax(i).eff_date,'YYYYMMDD'),v_production_tax(i).eff_date);
               BEGIN  
                   v_production_tax(i).branch_code:=v_branch_dim(v_production_tax(i).branch_name);
                EXCEPTION 
                   WHEN NO_DATA_FOUND THEN
                     NULL;
                END;   
                                     
             END LOOP;           
             populate_tax;
             saver;
           END LOOP;
    END;
     PROCEDURE generate_collection_tax
     IS
           TYPE branch_dim IS TABLE OF NUMBER INDEX BY bi_branch_dim.branch_name%TYPE;
           v_branch_dim      branch_dim;
           v_tax_info        bi_tax_mv%ROWTYPE; 
           TYPE collection   IS TABLE OF coll_tax_rec;
           v_collection      collection:= collection();
           v_line_code       BI_LINE_DIM.line_code%TYPE;
           v_pos_date        BI_COLLECTION_FACT.pos_date%TYPE;
           v_branch_code     BI_BRANCH_DIM.branch_code%TYPE;
           v_assured_code    BI_ASSURED_DIM.assured_code%TYPE;
           v_agent_code      BI_AGENT_DIM.agent_code%TYPE;
           v_tran_date       BI_TIME_DIM.time_code%TYPE;
           v_due_date        BI_TIME_DIM.time_code%TYPE;
           v_incept_date     BI_TIME_DIM.time_code%TYPE;
           v_or_date         BI_TIME_DIM.time_code%TYPE;
           v_eff_date        BI_TIME_DIM.time_code%TYPE;
           v_tax_amt        NUMBER; --BI_COLLECTION_FACT.tax_amount%TYPE;
           v_collection_code BI_COLLECTION_FACT.collection_code%TYPE;
           v_policy_no       BI_COLLECTION_FACT.policy_no%TYPE;
           v_endorsement_no  BI_COLLECTION_FACT.policy_no%TYPE;  
           v_counter         NUMBER; 
           v_doc_stamps         NUMBER;
           v_local_gov_tax      NUMBER;
           v_fire_service_tax   NUMBER;
           v_evat               NUMBER;
           v_other_charges      NUMBER;  
           v_lgt_tax_cd         NUMBER:=giacp.n('LGT');
           v_evat_tax_cd        NUMBER:=giacp.n('EVAT');
           v_fst_tax_cd         NUMBER:=giacp.n('FST');
           v_doc_stamp_cd       NUMBER:=giacp.n('DOC_STAMPS');  
           v_wtax               NUMBER;
           v_input_vat          NUMBER;
           v_comm_amt           NUMBER;           
           PROCEDURE load_collection
           IS
           BEGIN
                 v_branch_dim.delete;
                 FOR I IN (SELECT branch_code, branch_name 
                                   FROM bi_branch_dim
                               )
                 LOOP
                          v_branch_dim(i.branch_name):=i.branch_code;
                 END LOOP;
                            
           END;       
           PROCEDURE bulk_insert
           IS
           BEGIN
              FORALL i IN v_collection.FIRST..v_collection.LAST
                INSERT INTO
                        (
                           SELECT
                                   collection_code,
                                   line_code, 
                                   branch_code, 
                                   agent_code, 
                                   assured_code, 
                                   policy_no,
                                   endorsement_no,
                                   tran_date, 
                                   pos_date, 
                                   premium_amount, 
                                   tax_amount, 
                                   evat,
                                   local_gov_tax, 
                                   doc_stamps, 
                                   fire_service_tax,
                                   other_charges,
                                   book_tag, 
                                   collection_amount, 
                                   gibr_branch_code, 
                                   tran_flag, 
                                   bill_no ,
                                   tran_class,
                                   commission_amt,
                                   wtax_amt, 
                                   input_vat_amt,
                                   policy_id,
                                   due_date,
                                   eff_date,
                                   or_date,
                                   incept_date,
                                   pol_flag,
                                   age,
                                   invoice_prem_amt                                   
                           FROM BI_COLLECTION_TAX_FACT
                           )                      
                   VALUES v_collection(I);   
                 v_collection.DELETE; 
           END;
           FUNCTION get_tax_info(p_iss_cd  gipi_invoice.iss_cd%TYPE, p_prem_seq_no  gipi_inv_tax.prem_seq_no%TYPE)
           RETURN bi_tax_mv%ROWTYPE
           IS
                  v_output bi_tax_mv%ROWTYPE;
           BEGIN
                     SELECT * 
                       INTO v_output 
                       FROM bi_tax_mv
                      WHERE prem_seq_no =p_prem_seq_no 
                        AND iss_cd =p_iss_cd  ;
                                      
                     RETURN v_output;
           EXCEPTION 
                  WHEN NO_DATA_FOUND THEN
                     RETURN v_output;
                
           END; 
           PROCEDURE  get_comm_amt(p_tran_id NUMBER, p_share_cd NUMBER, p_comm_amt OUT NUMBER, p_wtax  OUT NUMBER, p_input_vat OUT NUMBER )           
           IS
             v_output NUMBER;
             v_shared NUMBER:=(NVL ( p_share_cd, 100) / 100);
           BEGIN
               p_comm_amt:=0;
               p_wtax:=0;
               p_input_vat:=0;
               SELECT  comm_amt * v_shared, wtax_amt *  v_shared, input_vat_amt * v_shared 
                 INTO  p_comm_amt,p_wtax , p_input_vat
                 FROM  giac_comm_payts
                WHERE  gacc_tran_id = p_tran_id ;                
           EXCEPTION 
            WHEN OTHERS THEN
                 NULL;
           END;
           PROCEDURE reset_var
           IS
           BEGIN                 
             v_line_code        :=NULL;
             v_branch_code      :=NULL;
             v_agent_code       :=NULL;
             v_assured_code     :=NULL;
             v_policy_no        :=NULL;
             v_tran_date        :=NULL;
             v_pos_date         :=NULL;
             v_doc_stamps       :=NULL;
             v_local_gov_tax    :=NULL;
             v_fire_service_tax :=NULL;
             v_evat             :=NULL;
             v_other_charges    :=NULL;  
             v_tax_amt          :=NULL;
             v_due_date         :=NULL;
             v_incept_date      :=NULL;
             v_or_date          :=NULL;
             v_eff_date         :=NULL;      
           END;
   BEGIN
      load_collection;
      
      EXECUTE IMMEDIATE 'TRUNCATE TABLE bi_collection_tax_fact';
                           
      FOR paid
              IN ( SELECT  * 
                     FROM  bi_collection_tax_fact_mv                                  
                 )
      LOOP
              BEGIN  
                  v_branch_code :=v_branch_dim(paid.iss_name);
              EXCEPTION 
                   WHEN NO_DATA_FOUND THEN
                        NULL;
              END;
              process_date(TRUNC (paid.posting_date),  v_pos_date);
              process_date(TRUNC (paid.due_date),  v_due_date);
              process_date(TRUNC (paid.incept_date),  v_incept_date);
              process_date(TRUNC (paid.or_date),  v_or_date);
              process_date(TRUNC (paid.eff_date),  v_eff_date);
              v_assured_code  := paid.assd_no;
              v_agent_code    := paid.intm_no;
              v_policy_no     := pkg_transform.get_pol_no (paid.policy_id);
              v_endorsement_no  := pkg_transform.get_policy_no (paid.policy_id);
              v_line_code     := paid.line_code;
                    
              FOR tax
                 IN (SELECT SUM (NVL (a.tax_amt, 0)) tax_amt, a.B160_TAX_CD TAX_CD
                       FROM giac_tax_collns a, giac_acctrans b
                      WHERE a.gacc_tran_id = b.tran_id
                        AND a.gacc_tran_id = paid.gacc_tran_id
                        AND a.b160_iss_cd = NVL (paid.b140_iss_cd, a.b160_iss_cd)
                        AND a.b160_prem_seq_no = NVL (paid.b140_prem_seq_no, a.b160_prem_seq_no)
                     GROUP BY  a.B160_TAX_CD
                    )
              LOOP
                  v_tax_amt := NVL(tax.tax_amt,0) + NVL(v_tax_amt,0);                   
                  IF tax.tax_cd = v_lgt_tax_cd 
                  THEN
                      v_local_gov_tax  := tax.tax_amt;
                  ELSIF tax.tax_cd = v_fst_tax_cd 
                  THEN
                       v_fire_service_tax   := tax.tax_amt;
                  ELSIF tax.tax_cd =v_evat_tax_cd   
                  THEN
                        v_evat     := tax.tax_amt;
                  ELSIF tax.tax_cd =v_doc_stamp_cd
                  THEN
                        v_doc_stamps      := tax.tax_amt;
                  ELSE
                        v_other_charges     := NVL(tax.tax_amt,0)+ NVL(v_other_charges ,0);
                  END IF; 
              END LOOP;
             v_tax_amt := NVL(v_tax_amt,0);              
             process_date(TRUNC (paid.tran_date),  v_tran_date);
             process_date(TRUNC (paid.due_date),  v_due_date);
             process_date(TRUNC (paid.eff_date),  v_eff_date);
             process_date(TRUNC (paid.or_date),  v_or_date);
             process_date(TRUNC (paid.incept_date),  v_incept_date);
             v_collection_code:=paid.collection_code;
             v_counter:=NVL(v_collection.COUNT(),0);  
             v_collection.EXTEND;
             v_counter:=v_counter+1;
             v_collection(v_counter).collection_code:=v_collection_code;
             v_collection(v_counter).line_code:=v_line_code;
             v_collection(v_counter).branch_code:=v_branch_code;
             v_collection(v_counter).agent_code:=v_agent_code;
             v_collection(v_counter).assured_code:=v_assured_code;
             v_collection(v_counter).policy_no:= v_policy_no;
             v_collection(v_counter).endorsement_no:= v_endorsement_no;
             v_collection(v_counter).tran_date:=v_tran_date;
             v_collection(v_counter).pos_date:=v_pos_date;
             v_collection(v_counter).premium_amount:=paid.modal_premium;
             v_collection(v_counter).tax_amount:=paid.tax_amt;
             v_collection(v_counter).book_tag:= paid.book_tag;
             v_collection(v_counter).policy_id:= paid.policy_id;
             v_collection(v_counter).collection_amount := paid.collection_amt ;
             v_collection(v_counter).tran_flag:= paid.tran_flag;
             v_collection(v_counter).bill_no:= paid.bill_no;
             v_collection(v_counter).tran_class:= paid.tran_class;             
             get_comm_amt(paid.gacc_tran_id, paid.share_percentage,v_comm_amt,v_wtax,v_input_vat);                          
             v_collection(v_counter).commission_amt := v_comm_amt; --get_comm_amt(paid.gacc_tran_id, paid.share_percentage);
             v_collection(v_counter).wtax_amt := v_wtax;
             v_collection(v_counter).input_vat_amt := v_input_vat;
             v_collection(v_counter).doc_stamps:= NVL(v_doc_stamps,0) * (NVL ( paid.share_percentage, 100) / 100);
             v_collection(v_counter).local_gov_tax:=  NVL(v_local_gov_tax,0)* (NVL ( paid.share_percentage, 100) / 100);
             v_collection(v_counter).fire_service_tax:= NVL(v_fire_service_tax,0)* (NVL ( paid.share_percentage, 100) / 100);
             v_collection(v_counter).evat:=  NVL(v_evat,0)* (NVL ( paid.share_percentage, 100) / 100);
             v_collection(v_counter).other_charges:=  NVL(v_other_charges,0)* (NVL ( paid.share_percentage, 100) / 100);
             v_collection(v_counter).due_date:=v_due_date;
             v_collection(v_counter).eff_date:=v_eff_date;
             v_collection(v_counter).or_date:=v_or_date;
             v_collection(v_counter).incept_date:=v_incept_date;
             v_collection(v_counter).pol_flag:= paid.pol_flag;
             v_collection(v_counter).age:= paid.age;
             v_collection(v_counter).invoice_prem_amt:= paid.invoice_prem_amt;
             reset_var;                                                       
             IF v_counter> v_limit
             THEN                 
                bulk_insert;       
                saver;
             END IF;
      END LOOP;      
      IF v_counter> 0
      THEN                 
                bulk_insert;       
                saver;
      END IF;            
   END;  
   PROCEDURE generate_budget
   IS
     v_rec         bi_prod_bud_act_fact%ROWTYPE;
     v_branch_code bi_prod_bud_act_fact.branch_code%TYPE;
     v_date       VARCHAR2(8);
     v_column     VARCHAR2(100);
     v_seqno      NUMBER:= 1;
     PROCEDURE populate
     IS
     BEGIN
       INSERT INTO bi_prod_bud_act_fact VALUES v_rec;
       v_rec:=NULL;
     END; 
     FUNCTION get_iss_dim(p_iss_cd  bi_branch_dim.iss_cd%TYPE)
     RETURN NUMBER
     IS
       v_output bi_line_dim.line_code%TYPE;
     BEGIN
          SELECT branch_code 
           INTO v_output  
           FROM bi_branch_dim
          WHERE iss_cd = p_iss_cd  ;
          RETURN v_output;
     EXCEPTION 
     WHEN OTHERS THEN 
          RETURN NULL;
     END;            
     FUNCTION get_amount(p_column_name VARCHAR2, p_iss_cd  bi_branch_dim.iss_cd%TYPE,p_year bud_act_prod.acct_yr%TYPE )
     RETURN NUMBER
     IS 
       v_output NUMBER;
     BEGIN
         EXECUTE IMMEDIATE 'SELECT ' || p_column_name ||  
                             ' FROM bud_act_prod  
                             WHERE iss_cd = :iss_cd
                               AND acct_yr =:acct_yr'  
                   INTO v_output     
                   USING p_iss_cd, p_year;
        RETURN v_output;                      
     END;     
   BEGIN
         EXECUTE IMMEDIATE 'TRUNCATE TABLE bi_prod_bud_act_fact  ';
         FOR I IN ( SELECT *
                      FROM bud_act_prod
                  )
         LOOP
                  v_branch_code:= get_iss_dim(i.iss_cd);  
                  FOR x IN (SELECT * 
                             FROM ALL_TAB_COLS
                            WHERE table_name = 'BUD_ACT_PROD'
                              AND column_id >=3
                              AND column_name LIKE '%ACT%'
                            ORDER BY column_name
                            )
                  LOOP
                       
                        v_date   :=TO_CHAR(TO_DATE('01-' || SUBSTR(x.column_name,1,3) ||'-' || i.acct_yr, 'DD-MON-YYYY'),'YYYYMMDD');   
                        v_rec.branch_code:=   v_branch_code;        
                        process_date( TO_DATE(v_date ,'YYYYMMDD'), v_rec.bud_act_date);                       
                        v_rec.bud_act_seqno:=v_seqno;                        
                        v_rec.actual_amt:=get_amount(x.column_name , i.iss_cd, i.acct_yr);   
                        v_column:= SUBSTR(x.column_name,1,3) || '_BUD';
                        v_rec.budget_amt:=get_amount(v_column , i.iss_cd, i.acct_yr); 
                        v_column:= SUBSTR(x.column_name,1,3) || '_MX';
                        v_rec.mx_amt:=get_amount(v_column , i.iss_cd, i.acct_yr);        
                        v_column:= SUBSTR(x.column_name,1,3) || '_PRD';                          
                        v_rec.prd_amt:=get_amount(x.column_name , i.iss_cd, i.acct_yr);                      
                        
                        populate;
                        saver;     
                        v_seqno:=v_seqno+1;                                                                                       
                  END LOOP;                                    
         END LOOP;     
   END;
    PROCEDURE generate_production
     IS  
       TYPE branch_dim IS TABLE OF NUMBER INDEX BY bi_branch_dim.branch_name%TYPE;
       v_branch_dim  branch_dim;
       CURSOR c_production IS       
              SELECT  
                   a.policy_code,
                   a.policy_no                                                      policy_no,
                   a.item_no,
                   a.item_title,
                   a. line_code, 
                   NULL                                                             branch_code,    
                   a.agent_code,
                   a.assured_code,  
                   a.issue_date, 
                   a.incept_date, 
                   a.exp_date,
                   a.acct_ent_date,
                   a.spoiled_acct_ent_date  ,                    
                   a.tsi,
                   a.prem_amt   modal_premium,           
--                   NULL                                                             annual_premium,
--                   a.evat                                                           evat, 
--                   a.local_gov_tax                                                  local_gov_tax, 
--                   a.doc_stamps                                                     doc_stamps, 
--                   a.fire_service_tax                                               fire_service_tax, 
--                   a.other_charges                                                  other_charges, 
--                   a.ret_prem, 
--                   a.facul_prem, 
--                   a.treaty_prem,
                   a.pol_flag,
                   a.spec_pol_flag                   ,
                   a.line_cd, 
                   a.iss_cd ,
                   a.prem_seq_no , 
                   a.currency_rt,          
                   a.subline_cd    ,                    
                   a.peril_cd ,    
                   a.policy_id,
                   a.iss_name,
                   a.booking_date,
                   a.endorsement_no,
                   a.renew_no,
                   a.dist_flag,
                   'O',
--                   ret_prem_acct_ent,
--                   dist_tsi_ret,
--                   dist_tsi_facul,
--                   dist_tsi_treaty,       
                   branch_code_dist,
                   eff_date ,
                   a.check_issue_date             ,
                   a.check_incept_date, 
                   a.check_booking_date, 
                   a.check_acct_ent_date, 
                   a.check_spld_acct_ent_date,
                   a.endt_seq_no,
                   a.policy_type,
                  -- a.line_subline_code,
                   a.cred_branch_code     
              FROM bi_production_fact_mv a
               /*remove to include Special Policies* JJJPajilan 4.17.2016*/ 
             --WHERE  ( (NVL(pol_flag,' ') != 'Spoiled'
              -- AND  NVL(spec_pol_flag,'Y') = 'Y' )
                -- OR  (spoiled_acct_ent_date IS NOT NULL OR NVL(pol_flag,' ') = 'Spoiled' ))
                 ;                                                     
           
        v_tax_info bi_tax_mv%ROWTYPE;    
        FUNCTION get_tax_info(p_iss_cd  gipi_invoice.iss_cd%TYPE, p_prem_seq_no  gipi_inv_tax.prem_seq_no%TYPE)
        RETURN bi_tax_mv%ROWTYPE
        IS
              v_output bi_tax_mv%ROWTYPE;
        BEGIN
                 SELECT * 
                   INTO v_output 
                   FROM bi_tax_mv
                  WHERE prem_seq_no =p_prem_seq_no 
                    AND iss_cd =p_iss_cd  ;
                                  
                 RETURN v_output;
         EXCEPTION 
              WHEN NO_DATA_FOUND THEN
                 RETURN v_output;            
        END;      
         PROCEDURE populate
         IS        
         BEGIN
             
             FORALL i IN  v_production.FIRST..v_production.LAST
                      INSERT INTO (SELECT  policy_code,
                                           policy_no  ,
                                           item_no,
                                           item_title,
                                           line_code, 
                                           branch_code,    
                                           agent_code,
                                           assured_code,  
                                           issue_date, 
                                           incept_date, 
                                           exp_date,
                                           acct_ent_date,
                                           spoiled_acct_ent_date  ,                    
                                           tsi,
                                           modal_premium,           
--                                           annual_premium,
--                                           evat, 
--                                           local_gov_tax, 
--                                           doc_stamps, 
--                                           fire_service_tax, 
--                                           other_charges,
--                                          -- commission_amt, 
--                                           ret_prem, 
--                                           facul_prem, 
--                                           treaty_prem,
                                           pol_flag,
                                           spec_pol_flag,
                                           line_cd, 
                                           iss_cd ,
                                           prem_seq_no , 
                                           currency_rt,       
                                           subline_cd    ,                                           
                                           peril_cd ,        
                                           policy_id,
                                           branch_name,
                                           booking_date,
                                           endorsement_no,
                                           renew_no   ,
                                           dist_flag, 
                                           rec_type   ,
--                                           ret_prem_acct_ent,
--                                           dist_tsi_ret,
--                                           dist_tsi_facul,
--                                           dist_tsi_treaty   ,
                                           branch_code_dist,
                                           eff_date ,
                                           check_issue_date   ,
                                           check_incept_date, 
                                           check_booking_date, 
                                           check_acct_ent_date, 
                                           check_spld_acct_ent_date,
                                           endt_seq_no,
                                           policy_type   ,
                                           --line_subline_code,
                                           a.cred_branch_code                                       
                                     FROM bi_production_fact a
                                    )
                              VALUES v_production(i);
                              NULL;
         END;                                          
     BEGIN
           EXECUTE IMMEDIATE 'TRUNCATE TABLE bi_production_fact';            
           OPEN   c_production;            
           LOOP  
             FETCH  c_production BULK COLLECT INTO v_production LIMIT v_limit;    
             EXIT WHEN v_production.COUNT=0;           
             
             FOR i IN v_production.FIRST..v_production.LAST
             LOOP 
                process_date(TO_DATE(v_production(i).issue_date,'YYYYMMDD'),v_production(i).issue_date);                   
                process_date(TO_DATE(v_production(i).incept_date,'YYYYMMDD'),v_production(i).incept_date);
                process_date(TO_DATE(v_production(i).acct_ent_date,'YYYYMMDD'),v_production(i).acct_ent_date);
                process_date(TO_DATE(v_production(i).spoiled_acct_ent_date,'YYYYMMDD'),v_production(i).spoiled_acct_ent_date);
                process_date(TO_DATE(v_production(i).booking_date,'YYYYMMDD'),v_production(i).booking_date);
                process_date(TO_DATE(v_production(i).exp_date,'YYYYMMDD'),v_production(i).exp_date);
                process_date(TO_DATE(v_production(i).eff_date,'YYYYMMDD'),v_production(i).eff_date);
                process_date(TO_DATE(v_production(i).check_issue_date,'YYYYMMDD'),v_production(i).check_issue_date);
                process_date(TO_DATE(v_production(i).check_incept_date,'YYYYMMDD'),v_production(i).check_incept_date);
                process_date(TO_DATE(v_production(i).check_booking_date,'YYYYMMDD'),v_production(i).check_booking_date);
                process_date(TO_DATE(v_production(i).check_acct_ent_date,'YYYYMMDD'),v_production(i).check_acct_ent_date);
                process_date(TO_DATE(v_production(i).check_spld_acct_ent_date,'YYYYMMDD'),v_production(i).check_spld_acct_ent_date);
               BEGIN                     
                     SELECT branch_code
                       INTO v_production(i).branch_code
                       FROM bi_branch_dim
                      WHERE iss_cd = v_production(i).iss_cd;
                EXCEPTION 
                   WHEN NO_DATA_FOUND  THEN
                     NULL;                     
                END;                    
             END LOOP;           
             populate;
             saver;
           END LOOP;
    END;         
   PROCEDURE generate_claims
   IS 
     TYPE t_claims IS TABLE OF bi_claims_fact%ROWTYPE;
     v_claims  t_claims;
     v_tran_flag   CONSTANT  cg_ref_codes.rv_domain%TYPE:='GIAC_ACCTRANS.TRAN_FLAG';
     CURSOR c_claims IS 
       SELECT    rownum claim_seqno,
                 claim_id   ,           
                 line_code   , 
                 assd_no    ,             
                 claim_no     ,             
                 policy_no    ,         
                 issue_source ,         
                 branch_code    ,           
                 claim_status  ,        
                 exp_amount ,       
                 loss_amount     ,      
                 exp_retention_amt   ,      
                 exp_propor_treaty ,    
                 exp_facultative   ,    
                 exp_nonpropor_treaty  ,
                 loss_retention_amt  ,           
                 loss_propor_treaty,             
                 loss_facultative      ,         
                 loss_nonpropor_treaty ,         
                 loss_date        ,
                 file_date     ,   
                 effectivity_date ,
                 close_date,
                 pol_iss_code    ,
                 clm_stat_cd ,
                 item_no ,
                 item_title
            from bi_claims_mv;
         b number;          

--         PROCEDURE cancel_rec
--         IS
--         BEGIN
--              UPDATE  bi_claims_Fact  
--                 SET  loss_retention_amt =0, 
--                      loss_propor_treaty = 0,
--                      loss_nonpropor_treaty = 0,
--                      loss_facultative = 0,
--                      exp_retention_amt =0, 
--                      exp_propor_treatY = 0,
--                      exp_nonpropor_treaty = 0,
--                      exp_facultative = 0,
--                      claim_amt = 0,
--                      loss_amount = 0,
--                      expense_amount = 0
--            WHERE     claim_status IN ( 'WITHDRAWN','CANCELLED','DENIED');         
--         END;  
     BEGIN 
     EXECUTE IMMEDIATE 'TRUNCATE TABLE bi_claims_fact';               
       OPEN c_claims;
         LOOP     
               FETCH c_claims BULK COLLECT INTO v_claims LIMIT v_limit;
               
               EXIT WHEN v_claims.COUNT = 0;
               FOR  i in v_claims.FIRST..v_claims.LAST
               LOOP                                                                                                                    
                    process_date(TO_DATE(LPAD(v_claims(i).loss_date, 8, '0'),'YYYYMMDD'),v_claims(i).loss_date);
                    process_date(TO_DATE(LPAD(v_claims(i).file_date, 8, '0'),'YYYYMMDD'),v_claims(i).file_date);
                    process_date(TO_DATE(LPAD(v_claims(i).effectivity_date, 8, '0'),'YYYYMMDD'),v_claims(i).effectivity_date);
                    process_date(TO_DATE(LPAD(v_claims(i).close_date, 8, '0'),'YYYYMMDD'),v_claims(i).close_date);
               END LOOP;                 
               FORALL  i IN v_claims.FIRST..v_claims.LAST
                    INSERT INTO bi_claims_fact VALUES v_claims(i); 
               saver;
         END LOOP;
         NULL;
       CLOSE c_claims; 
       null;                    
   END;          
   
         PROCEDURE generate_claims_agent
         IS 
         TYPE t_claims_agent IS TABLE OF bi_claims_agent_fact%ROWTYPE;
         v_claims_agent  t_claims_agent;
         CURSOR c_claims_agent IS 
         SELECT     loss_date,    
                    file_date,    
                    effectivity_date,    
                    close_date,    
                    loss_amount,    
                    expense_amount,
                    loss_retention_amt,
                    exp_retention_amt,
                    loss_propor_treaty,
                    exp_propor_treaty,
                    loss_facultative,
                    exp_facultative,
                    loss_nonpropor_treaty,
                    exp_nonpropor_treaty,
                    claim_id,    
                    assd_no,
                    parent_no,
                    issue_yy,    
                    renew_no,
                    peril_cd,    
                    pol_seq_no,    
                    line_cd,    
                    iss_cd,    
                    pol_iss_cd,    
                    intm_type,    
                    clm_stat_cd,    
                    old_stat_cd,    
                    parent_name,    
                    claim_no,    
                    policy_no,    
                    subline_cd,
                    line_code    
         FROM bi_claims_agent_mv;
         
   BEGIN 
      EXECUTE IMMEDIATE 'TRUNCATE TABLE bi_claims_agent_fact';               
       OPEN c_claims_agent;
         LOOP     
               FETCH c_claims_agent BULK COLLECT INTO v_claims_agent LIMIT v_limit;
               
               EXIT WHEN v_claims_agent.COUNT = 0;
               FOR  i in v_claims_agent.FIRST..v_claims_agent.LAST
               LOOP                                                                                                                    
                    process_date(TO_DATE(LPAD(v_claims_agent(i).loss_date, 8, '0'),'YYYYMMDD'),v_claims_agent(i).loss_date);
                    process_date(TO_DATE(LPAD(v_claims_agent(i).file_date, 8, '0'),'YYYYMMDD'),v_claims_agent(i).file_date);
                    process_date(TO_DATE(LPAD(v_claims_agent(i).effectivity_date, 8, '0'),'YYYYMMDD'),v_claims_agent(i).effectivity_date);
                    process_date(TO_DATE(LPAD(v_claims_agent(i).close_date, 8, '0'),'YYYYMMDD'),v_claims_agent(i).close_date);
               END LOOP;                 
               FORALL  i IN v_claims_agent.FIRST..v_claims_agent.LAST
                    INSERT INTO bi_claims_agent_fact VALUES v_claims_agent(i); 
               saver;
         END LOOP;
         NULL;
       CLOSE c_claims_agent;                     
   END;
   
      
   PROCEDURE generate_production_tax_rev
     IS
        v_policy_code  bi_production_tax_fact.policy_code%TYPE;    
        v_index        PLS_INTEGER;
        TYPE prod_acct IS TABLE OF bi_production_tax_fact%ROWTYPE;
        v_prod_acct prod_acct;
        CURSOR c_prod_acct IS   
                         SELECT  a.*
                          FROM  bi_production_tax_fact a
                          WHERE a.spoiled_acct_ent_date IS NOT NULL  OR NVL(pol_flag,' ') = 'Spoiled'                         
                          /* AND EXISTS (SELECT   1 
                                         FROM   bi_production_fact_agent_mv e  
                                         WHERE  a.policy_id = e.policy_id
                                           AND  a.iss_cd = e.iss_cd
                                           AND  a.prem_seq_no = e.prem_seq_no
                                           AND  e.exists_giac_new = 0) */;
       PROCEDURE delete_reverse 
       IS
       BEGIN
           DELETE 
             FROM bi_production_tax_fact 
            WHERE substr(rec_type,1,1) ='R';       
       END;
       FUNCTION get_max_policy_code
       RETURN NUMBER
       IS
        v_output NUMBER;
       BEGIN
             SELECT  MAX(policy_code)+1
              INTO    v_output 
              FROM   bi_production_tax_fact ;             
             RETURN  v_output;
       END;
     BEGIN  
            delete_reverse ;                    
            saver;                                                            
            v_policy_code :=    get_max_policy_code;                                                                
            OPEN c_prod_acct ;
            LOOP
                FETCH c_prod_acct BULK COLLECT INTO v_prod_acct LIMIT v_limit*2;
                EXIT WHEN  v_prod_acct.COUNT = 0;              
                FOR i IN v_prod_acct.FIRST..v_prod_acct.LAST
                LOOP
                       IF v_prod_acct(i).spoiled_acct_ent_date IS NOT NULL OR NVL(v_prod_acct(i).pol_flag,' ') = 'Spoiled' 
                       THEN                    
                           v_prod_acct(i).modal_premium  := v_prod_acct(i).modal_premium * -1 ;
                           v_prod_acct(i).commission_amt := v_prod_acct(i).commission_amt * -1 ;
                           v_prod_acct(i).evat           := v_prod_acct(i).evat* -1 ;
                           v_prod_acct(i).local_gov_tax  := v_prod_acct(i).local_gov_tax* -1 ;
                           v_prod_acct(i).doc_stamps     := v_prod_acct(i).doc_stamps* -1 ;
                           v_prod_acct(i).fire_service_tax := v_prod_acct(i).fire_service_tax* -1 ;
                           v_prod_acct(i).other_charges  := v_prod_acct(i).other_charges* -1 ;  
                           v_prod_acct(i).facul_prem     := v_prod_acct(i).facul_prem* -1 ;
                           v_prod_acct(i).ret_prem       := v_prod_acct(i).ret_prem* -1 ;    
                           v_prod_acct(i).acct_ent_date  := v_prod_acct(i).spoiled_acct_ent_date;   
                           v_prod_acct(i).tsi             := v_prod_acct(i).tsi *-1;                    
                           v_prod_acct(i).rec_type       := 'R-' || v_prod_acct(i).policy_code;          
                           v_prod_acct(i).policy_code := v_policy_code;                    
                           v_policy_code:=v_policy_code+1;
                           saver;    
                       END IF;
                END LOOP;    
                FORALL  i IN v_prod_acct.FIRST..v_prod_acct.LAST
                INSERT INTO  bi_production_tax_fact  VALUES v_prod_acct(i);
                saver;
            END LOOP;
            CLOSE c_prod_acct;                                                                                             
     END;     
     PROCEDURE generate_production_dist
     IS 
         v_production_dist  production_dist;
         CURSOR c_production_dist 
             IS 
              SELECT  rownum prod_dist_code,
                      policy_id, 
                      policy_no , 
                      line_code ,
                      branch_code,    
                      cred_branch_code, 
                      pol_flag,   
                      dist_flag   ,   
                      eff_date,
                      issue_date,
                      booking_date,
                      acct_ent_date,
                      acct_neg_date  ,
                      nr_dist_tsi,
                      nr_dist_prem,
                      nr_dist_spct,
                      tr_dist_tsi,
                      tr_dist_prem,
                      tr_dist_spct,
                      fa_dist_tsi,
                      fa_dist_prem ,
                      endorsement_no , 
                      spec_pol_flag  ,
                      assured_code
                FROM  bi_prod_dist_fact_mv;  
          PROCEDURE populate_prod_dist 
          IS
          BEGIN
              FORALL i in v_production_dist.FIRST..v_production_dist.LAST
                 INSERT INTO ( SELECT   prod_dist_code, policy_id, 
                      policy_no , 
                      line_code ,
                      branch_code,    
                      cred_branch_code, 
                      pol_flag,   
                      dist_flag   ,   
                      eff_date,
                      issue_date,
                      booking_date,
                      acct_ent_date,
                      acct_neg_date  ,
                      nr_dist_tsi,
                      nr_dist_prem,
                      nr_dist_spct,
                      tr_dist_tsi,
                      tr_dist_prem,
                      tr_dist_spct,
                      fa_dist_tsi,
                      fa_dist_prem   ,
                      endorsement_no , 
                      spec_pol_flag,
                      assured_code
                FROM  bi_prod_dist_fact)  VALUES  v_production_dist(i);
          END;                                                                       
     BEGIN
           EXECUTE IMMEDIATE 'TRUNCATE TABLE bi_prod_dist_fact';
           
           OPEN  c_production_dist;            
           LOOP  
             FETCH  c_production_dist  BULK COLLECT INTO v_production_dist  LIMIT v_limit;    
             EXIT WHEN v_production_dist.COUNT=0;                        
             FOR i IN v_production_dist.FIRST..v_production_dist.LAST
             LOOP 
                process_date(TO_DATE(v_production_dist(i).issue_date,'YYYYMMDD'),v_production_dist(i).issue_date);      
                process_date(TO_DATE(v_production_dist(i).acct_ent_date,'YYYYMMDD'),v_production_dist(i).acct_ent_date);
                process_date(TO_DATE(v_production_dist(i).acct_neg_date,'YYYYMMDD'),v_production_dist(i).acct_neg_date);
                process_date(TO_DATE(v_production_dist(i).booking_date,'YYYYMMDD'),v_production_dist(i).booking_date);
                process_date(TO_DATE(v_production_dist(i).eff_date,'YYYYMMDD'),v_production_dist(i).eff_date);                 
             END LOOP; 
              populate_prod_dist ;
              saver;
           END LOOP;               
     END;
  PROCEDURE generate_claims_losses_paid
   IS 
     TYPE t_claims IS TABLE OF BI_CLAIMS_LOSSES_PAID_FACT%ROWTYPE;
     v_claims  t_claims;
     CURSOR c_claims IS 
                        SELECT rownum claim_rec,
                            a.policy_id,  
                            a.line_code        ,                
--                            a.loss_amount         ,
--                            a.expense_amount         ,         
                            a.losses_paid           , 
                            a.expenses_paid            ,
--                            a.exp_retention_amt         ,
--                            a.exp_propor_treaty              ,  
--                            a.exp_facultative           ,
--                            a.exp_nonpropor_treaty,
--                            a.loss_retention_amt,
--                            a.loss_propor_treaty,
--                            a.loss_facultative,
--                            a.loss_nonpropor_treaty,
--                            a.claim_amount,
                            a.shr_pct,
                            a.claim_id,
                            a.branch_code,
--                            a.agent_code,
                            a.assured_code,
                            a.tran_id,
--                            a.intm_no,
                            a.claims_branch_code,
                            a.convert_rate,
--                            a.loss_reserve,
--                            a.expense_reserve,
                            a.peril_cd,
                            a.item_no,
                            a.cancel_tag,
                            a.dist_sw,
                            a.tran_flag,
--                            a.share_type,
                            a.pol_iss_cd,
                            a.loss_cat_des,
                            a.claim_no,
                            a.policy_no,
                            a.claim_status,
                            a.claim_status_grp,
                            REPLACE(a.tran_date,' ',NULL),
--                            a.with_loss_payment,
--                            a.with_expense_payment,
--                            a.intm_name,
                            a.issue_source,
                            REPLACE(a.effectivity_date,' ',NULL),
                            REPLACE(a.loss_date,' ',NULL),
                            REPLACE(a.date_paid,' ',NULL),
                            REPLACE(a.file_date,' ',NULL),
                            REPLACE(a.cancel_date ,' ',NULL)    
                            from BI_CLAIMS_LOSSES_PAID_MV a;
                         b number;                                          
   BEGIN 
     
      EXECUTE IMMEDIATE 'TRUNCATE TABLE BI_CLAIMS_LOSSES_PAID_FACT';
               
       OPEN c_claims;
        LOOP     
               FETCH c_claims BULK COLLECT INTO v_claims LIMIT v_limit;
               
               EXIT WHEN v_claims.COUNT = 0;
               FOR  i in v_claims.FIRST..v_claims.LAST
               LOOP                 
                                            
                  process_date(v_claims(i).tran_date,v_claims(i).tran_date);
                  process_date(v_claims(i).effectivity_date,v_claims(i).effectivity_date);
                  process_date(v_claims(i).loss_date,v_claims(i).loss_date);
                  process_date(v_claims(i).date_paid,v_claims(i).date_paid);
                  process_date(v_claims(i).file_date,v_claims(i).file_date);
                  process_date(v_claims(i).cancel_date,v_claims(i).cancel_date);
                 
                 NULL; 
               END LOOP;
                 
               FORALL  i IN v_claims.FIRST..v_claims.LAST
                    INSERT INTO BI_CLAIMS_LOSSES_PAID_FACT VALUES v_claims(i); 
               saver;
         END LOOP;
         NULL;
       CLOSE c_claims;             
   END;    
    PROCEDURE generate_claims_lp_agent
   IS 
     TYPE t_claims IS TABLE OF BI_CLAIMS_LP_AGENT_FACT%ROWTYPE;
     v_claims  t_claims;
     CURSOR c_claims IS 
                        SELECT rownum claim_rec,
                            a.policy_id,  
                            a.line_code        ,                
--                            a.loss_amount         ,
--                            a.expense_amount         ,         
                            a.losses_paid           , 
                            a.expenses_paid            ,
--                            a.exp_retention_amt         ,
--                            a.exp_propor_treaty              ,  
--                            a.exp_facultative           ,
--                            a.exp_nonpropor_treaty,
--                            a.loss_retention_amt,
--                            a.loss_propor_treaty,
--                            a.loss_facultative,
--                            a.loss_nonpropor_treaty,
--                            a.claim_amount,
                            a.shr_pct,
                          --  a.line_subline_code,
                            a.claim_id,
                            a.branch_code,
                            a.agent_code,
                            a.assured_code,
                            a.tran_id,
                            a.intm_no,
                         --   a.claims_branch_code,
                            a.convert_rate,
                            a.loss_reserve,
                            a.expense_reserve,
                            a.clm_res_hist_id,
                            a.peril_cd,
                            a.item_no,
                            a.cancel_tag,
                            a.dist_sw,
--                            a.share_type,
                            a.pol_iss_cd,
                            a.loss_cat_des,
                            a.claim_no,
                            a.policy_no,
                            a.claim_status,
                            a.claim_status_grp,
                            REPLACE(a.tran_date,' ',NULL),
                             a.tran_flag,
--                            a.with_loss_payment,
--                            a.with_expense_payment,
                            a.intm_name,
                            a.issue_source,
                            REPLACE(a.effectivity_date,' ',NULL),
                            REPLACE(a.loss_date,' ',NULL),
                            REPLACE(a.date_paid,' ',NULL),
                            REPLACE(a.file_date,' ',NULL),
                            REPLACE(a.cancel_date ,' ',NULL)    
                            from bi_claims_lp_agent_mv a;                     
   BEGIN 
     
      EXECUTE IMMEDIATE 'TRUNCATE TABLE BI_CLAIMS_LP_AGENT_FACT';
               
       OPEN c_claims;
        LOOP     
               FETCH c_claims BULK COLLECT INTO v_claims LIMIT v_limit;
               
               EXIT WHEN v_claims.COUNT = 0;
               FOR  i in v_claims.FIRST..v_claims.LAST
               LOOP                 
                                            
                  process_date(v_claims(i).tran_date,v_claims(i).tran_date);
                  process_date(v_claims(i).effectivity_date,v_claims(i).effectivity_date);
                  process_date(v_claims(i).loss_date,v_claims(i).loss_date);
                  process_date(v_claims(i).date_paid,v_claims(i).date_paid);
                  process_date(v_claims(i).file_date,v_claims(i).file_date);
                  process_date(v_claims(i).cancel_date,v_claims(i).cancel_date);
                 
                 NULL; 
               END LOOP;
                 
               FORALL  i IN v_claims.FIRST..v_claims.LAST
                    INSERT INTO BI_CLAIMS_LP_AGENT_FACT VALUES v_claims(i); 
               saver;
         END LOOP;
         NULL;
       CLOSE c_claims;             
   END;   
   
   PROCEDURE generate_claims_brdrx
   IS 
     TYPE t_claims IS TABLE OF bi_claims_brdrx_fact%ROWTYPE;
     v_claims  t_claims;
     CURSOR c_claims IS 
                        SELECT  a.claim_id         ,                
                            a.item_no          ,
                            a.policy_no         ,         
                            a.claim_no           , 
                            a.iss_cd            ,
                            a.branch_code         ,
                            a.ri_cd              ,  
                            a.line_code            ,
                            a.subline_cd       ,
                            a.loss_year           ,   
                            a.assd_no           ,  
                            a.loss_date,             
                            a.clm_file_date,
                            a.incept_date,    
                            a.expiry_date   ,
                            a.pol_iss_cd       , 
                            a.issue_yy         ,
                            a.pol_seq_no        ,   
                            a.renew_no           ,     
                            a.peril_cd  ,
                            a.loss_cat_cd,      
                            a.ann_tsi_amt ,  
                            a.dist_sw      ,
                            a.convert_rate  ,      
                            a.loss_reserve   ,         
                            a.losses_paid     ,  
                            a.expense_reserve  ,     
                            a.expenses_paid     ,
                            a.grouped_item_no        ,
                            a.clm_res_hist_id     , 
                            a.grouped_item_title       ,   
                            a.control_cd         ,
                            a.control_type_cd    ,
                            a.booking_year       ,
                            a.booking_month       ,
                            a.date_paid          ,  
                            a.posting_date       ,
                            a.cancel_tag            , 
                            a.cancel_date         ,
                            a.tran_id             ,
                            a.tran_date         ,
                            a.brdrx_type       ,
                            a.close_date ,
                            a.close_date2 ,
                            a.currency_rate,
                            a.intm_no,
                            a.intm_name,
                            a.loss_cat_des,
                            a.clm_stat_desc,
                            a.item_title,
                            a.cred_branch_code,
                            a.rec_count,
--                            a.reversal,
                            a.posting_date_2,
                            a.date_paid_2,
                            a.tran_id_2,
                            NVL(a.buss_source, 0),
                            a.booking_date
                          from bi_claims_brdrx_fact_tmp_mv a;
                         b varchar2(100);                                       
   BEGIN 
     
      EXECUTE IMMEDIATE 'TRUNCATE TABLE bi_claims_brdrx_fact';
               
       OPEN c_claims;
        LOOP     
               FETCH c_claims BULK COLLECT INTO v_claims LIMIT v_limit;
               
               EXIT WHEN v_claims.COUNT = 0;
               FOR  i in v_claims.FIRST..v_claims.LAST
               LOOP                 
--                  kumag := v_claims(i).rec_count;
--                  select loss_date
--                          into b
--                          from  bi_claims_brdrx_fact_tmp_mv a
--                                                    where rec_count = 97585;

                   --process_date(    to_Date(LPAD(b, 'YYYYMMDD'), kumag) ;
                  process_date(v_claims(i).loss_date,v_claims(i).loss_date) ;
                  process_date(v_claims(i).claim_file_date,v_claims(i).claim_file_date);
                  process_date(v_claims(i).incept_date,v_claims(i).incept_date);
                  process_date(v_claims(i).expiry_date, v_claims(i).expiry_date);
                  process_date(v_claims(i).date_paid,v_claims(i).date_paid);
                  process_date(v_claims(i).posting_date,v_claims(i).posting_date);
                  process_date(v_claims(i).cancel_date,v_claims(i).cancel_date);
                  process_date(v_claims(i).tran_date,v_claims(i).tran_date);
                  process_date(v_claims(i).close_date,v_claims(i).close_date);
                  process_date(v_claims(i).close_date2,v_claims(i).close_date2);
                  process_date(v_claims(i).acc_posting_date,v_claims(i).acc_posting_date);
                  process_date(v_claims(i).acc_date_paid,v_claims(i).acc_date_paid);
                  process_date(v_claims(i).booking_date,v_claims(i).booking_date);
                  
               END LOOP;
                 
               FORALL  i IN v_claims.FIRST..v_claims.LAST
                    INSERT INTO bi_claims_brdrx_fact VALUES v_claims(i); 
               saver;
         END LOOP;
         NULL;
       CLOSE c_claims;           
   END;
   
   PROCEDURE generate_claims_take_up
   IS 
     TYPE t_claims IS TABLE OF bi_claims_brdrx_take_up_fact%ROWTYPE;
     v_claims  t_claims;
     CURSOR c_claims IS 
                        SELECT  a.claim_id, 
                                a.claim_no, 
                                a.policy_no, 
                                a.ann_tsi_amt, 
                                a.assd_no, 
                                a.buss_source, 
                                a.clm_res_hist_id, 
                                a.grouped_item_no, 
                                a.item_no, 
                                a.loss_year,
                                a.os_expense, 
                                a.os_loss, 
                                a.tran_flag, 
                                a.acct_date,
                                a.clm_file_date, 
                                a.expiry_date, 
                                a.incept_date,
                                a.loss_date, 
                                a.posting_date, 
                                a.tran_date, 
                                a.iss_branch_code,
                                a.pol_iss_branch_code, 
                                a.line_code, 
                                a.loss_cat_des, 
                                a.item_title
                          from bi_claims_brdrx_take_up_f_mv a;
                         b varchar2(100); 
                         
       kumag VARCHAR2(100);                                         
   BEGIN 
     
      EXECUTE IMMEDIATE 'TRUNCATE TABLE bi_claims_brdrx_take_up_fact';
               
       OPEN c_claims;
        LOOP     
               FETCH c_claims BULK COLLECT INTO v_claims LIMIT v_limit;
               
               EXIT WHEN v_claims.COUNT = 0;
               FOR  i in v_claims.FIRST..v_claims.LAST
               LOOP                 
               
                  process_date(v_claims(i).acct_date,v_claims(i).acct_date) ;
                  process_date(v_claims(i).clm_file_date,v_claims(i).clm_file_date) ;
                  process_date(v_claims(i).expiry_date,v_claims(i).expiry_date) ;
                  process_date(v_claims(i).incept_date,v_claims(i).incept_date) ;
                  process_date(v_claims(i).loss_date,v_claims(i).loss_date) ;
                  process_date(v_claims(i).posting_date,v_claims(i).posting_date) ;
                  process_date(v_claims(i).tran_date,v_claims(i).tran_date) ;
                  
               END LOOP;
                 
               FORALL  i IN v_claims.FIRST..v_claims.LAST
                    INSERT INTO bi_claims_brdrx_take_up_fact VALUES v_claims(i); 
               saver;
         END LOOP;
         NULL;
       CLOSE c_claims;           
   END;
   
   PROCEDURE generate_claims_reg
   IS 
     TYPE t_claims IS TABLE OF bi_claims_reg_fact%ROWTYPE;
     v_claims  t_claims;
     CURSOR c_claims IS 
                        SELECT a.claim_id,
                               a.claim_no,
                               a.item_no,
                               a.policy_no,
                               a.clm_res_hist_id,
                               a.clm_stat_desc,
                               a.prem_amt,
                               a.loss_reserve,
                               a.losses_paid,
                               a.expense_reserve,
                               a.expenses_paid,
                               a.ann_tsi_amt,
                               a.assd_no,
                               a.clm_file_date,
                               a.dsp_loss_date,
                               a.clm_iss_branch,
                               a.loss_date,
                               a.eff_date,
                               a.exp_date,
                               a.item_title,
                               a.agent,
                               a.recovered_amt,
                               a.cancel_tag,
                               a.cancel_date,
                               a.pol_iss_branch,
                               a.line_code
                          from bi_claims_reg_fact_tmp_mv a;
                         b varchar2(100); 
                         
       kumag VARCHAR2(100);                                         
   BEGIN 
     
      EXECUTE IMMEDIATE 'TRUNCATE TABLE bi_claims_reg_fact';
               
       OPEN c_claims;
        LOOP     
               FETCH c_claims BULK COLLECT INTO v_claims LIMIT v_limit;
               
               EXIT WHEN v_claims.COUNT = 0;
               FOR  i in v_claims.FIRST..v_claims.LAST
               LOOP                 
               
                  process_date(v_claims(i).dsp_loss_date,v_claims(i).dsp_loss_date) ;
                  process_date(v_claims(i).claim_file_date,v_claims(i).claim_file_date);
                  process_date(v_claims(i).loss_date,v_claims(i).loss_date) ;
                  process_date(v_claims(i).eff_date,v_claims(i).eff_date) ;
                  process_date(v_claims(i).exp_date,v_claims(i).exp_date) ;
                  process_date(v_claims(i).cancel_date,v_claims(i).cancel_date) ;
                  
               END LOOP;
                 
               FORALL  i IN v_claims.FIRST..v_claims.LAST
                    INSERT INTO bi_claims_reg_fact VALUES v_claims(i); 
               saver;
         END LOOP;
         NULL;
       CLOSE c_claims;           
   END;
   
  PROCEDURE generate_claims_outstanding
   IS 
     TYPE t_claims IS TABLE OF bi_outstanding_fact%ROWTYPE;
     v_claims  t_claims;
     CURSOR c_claims IS 
                        SELECT
                            a.claim_rec,  
                            a.claim_id         ,                
                            a.policy_no          ,
                            a.policy_id ,
                            a.claim_no         ,         
                            a.line_code           , 
                            a.branch_code            ,
                            a.intm_no         ,
                            a.assd_no              ,  
                            a.peril_cd            ,
                            REPLACE(a.posting_date,' ',NULL) , 
                            REPLACE(a.tran_date,' ',NULL),
                            REPLACE(a.loss_date,' ',NULL),
                            REPLACE(a.file_date,' ',NULL),
                            REPLACE(a.booking_date,' ',NULL),
                            a.tran_flag       , 
                            a.os_loss         ,
                            a.os_expense        ,   
                            a.shr_pct           ,     
                            a.share_type  ,
                            REPLACE(a.date_paid,' ',NULL),      
                            a.loss_reserve ,  
                            a.losses_paid      ,
                            a.expense_reserve  ,      
                            a.expenses_paid ,         
                            REPLACE(a.close_date ,' ',NULL)   ,  
                            REPLACE(a.close_date2,' ',NULL) ,     
                            a.cancel_tag    ,
                           REPLACE(a.cancel_date ,' ',NULL)   ,
                            a.taken_up
                          from bi_outstanding_mv a;
                         b number;                                          
   BEGIN 
     
      EXECUTE IMMEDIATE 'TRUNCATE TABLE bi_outstanding_fact';
               
       OPEN c_claims;
        LOOP     
               FETCH c_claims BULK COLLECT INTO v_claims LIMIT v_limit;
               
               EXIT WHEN v_claims.COUNT = 0;
               FOR  i in v_claims.FIRST..v_claims.LAST
               LOOP                 
                                                 
                  process_date(v_claims(i).posting_date,v_claims(i).posting_date);
                  process_date(v_claims(i).tran_date,v_claims(i).tran_date);
                  process_date(v_claims(i).loss_date,v_claims(i).loss_date);
                  process_date(v_claims(i).file_date,v_claims(i).file_date);
                  process_date(v_claims(i).booking_date,v_claims(i).booking_date);
                  process_date(v_claims(i).date_paid,v_claims(i).date_paid);
                  process_date(v_claims(i).close_date,v_claims(i).close_date);
                  process_date(v_claims(i).close_date2,v_claims(i).close_date2);
                  process_date(v_claims(i).cancel_date,v_claims(i).cancel_date);
                 
                 NULL; 
               END LOOP;
                 
               FORALL  i IN v_claims.FIRST..v_claims.LAST
                    INSERT INTO bi_outstanding_fact VALUES v_claims(i); 
               saver;
         END LOOP;
         NULL;
       CLOSE c_claims;             
   END;
   
   PROCEDURE generate_renewal
   IS 
     TYPE t_renewal IS TABLE OF bi_renewal_fact%ROWTYPE;
     v_renewal  t_renewal;
     CURSOR c_renewal IS 
                        SELECT  ROWNUM POLICY_CODE,
                                POLICY_ID,
                                POLICY_NO ,
                                LINE_CODE,
                                BRANCH_CODE,
                                CRED_BRANCH_CODE,
                                AGENT_CODE,
                                ASSURED_CODE,
                                EXP_DATE,
                                PREM_AMT,
                                NEW_POLICY_ID,
                                PREM_RENEW_AMT,
                                RENEWAL_TAG ,
                                '',
                                '',
                                EXPIRY_TAG,
                                MAX_EXPIRY_DATE
                        FROM BI_RENEWAL_TAX_FACT_MV ;
                         b varchar2(100); 
                         
       kumag VARCHAR2(100);                                         
   BEGIN 
     
      EXECUTE IMMEDIATE 'TRUNCATE TABLE bi_renewal_fact';
               
       OPEN c_renewal;
        LOOP     
               FETCH c_renewal BULK COLLECT INTO v_renewal LIMIT v_limit;
               
               EXIT WHEN v_renewal.COUNT = 0;
               FOR  i in v_renewal.FIRST..v_renewal.LAST
               LOOP                 
               
                  process_date(v_renewal(i).exp_date,v_renewal(i).exp_date) ;
                  process_date(v_renewal(i).max_exp_date,v_renewal(i).max_exp_date) ;
                  
               END LOOP;
                 
               FORALL  i IN v_renewal.FIRST..v_renewal.LAST
                    INSERT INTO bi_renewal_fact VALUES v_renewal(i); 
               saver;
         END LOOP;
         NULL;
       CLOSE c_renewal;           
   END;
END;
/
