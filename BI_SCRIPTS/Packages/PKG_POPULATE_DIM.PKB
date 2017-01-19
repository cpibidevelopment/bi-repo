CREATE OR REPLACE PACKAGE BODY BIADMIN.PKG_POPULATE_DIM
IS   
    
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
       v_record    BI_TIME_DIM%ROWTYPE;
       v_time_code BI_TIME_DIM.time_code%TYPE;
     BEGIN
     
        SELECT MAX(time_code)+1
          INTO v_time_code
         FROM  bi_time_dim;
        
        SELECT  NVL(v_time_code,1),
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
                RTRIM(TO_CHAR(p1,'MONTH'),' ') month_name,                
                CEIL(TO_CHAR(p1,'DD')) /7 week_no,
                TO_CHAR(p1,'DD') date_of_month
        INTO    v_record
        FROM    DUAL;   
        
   
             
        INSERT INTO BI_TIME_DIM  VALUES v_record;
     END;   
     PROCEDURE gen_time_dim(p1 DATE, p_range NUMBER, p_behaviour NUMBER DEFAULT 0)   
     IS
       v_date  DATE := p1;
     BEGIN 
   
        DELETE FROM bi_time_dim cascade ;
        
        IF p_behaviour  !=0
        THEN
           v_date:=v_date-p_range;               
        END IF;   
        
           FOR I IN  1..p_range 
           LOOP
                 v_date := v_date +1;
                 gen_time_code(v_date);   
                 saver; 
           END LOOP;
          
     END;  
     PROCEDURE gen_line_cd_dim
     IS      
     BEGIN
          
           DELETE FROM bi_line_dim cascade ;
            
           INSERT INTO bi_line_dim (line_code, line_name, subline_name, peril_name, peril_sname, peril_type) 
                ( SELECT  rownum line_code, line_name,  subline_name,peril_name,   peril_sname, peril_type                                          
                          FROM bi_line_dim_mv 
                 );
                                 
           saver;      
     END; 
     PROCEDURE gen_branch_dim 
     IS
     BEGIN
           
            DELETE FROM BI_BRANCH_DIM cascade ;
         
                INSERT INTO BI_BRANCH_DIM
                         (SELECT  ROWNUM,
                                   a.iss_name,
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
                             FROM  GIIS_ISSOURCE a, GIIS_GRP_ISSOURCE b, GIIS_REGION c
                             WHERE a.iss_grp = b.iss_grp(+)
                             AND   a.region_cd = c.region_cd(+)
                           );
                saver;
           
     END;   
     PROCEDURE gen_assured_dim
     IS
        TYPE rec_assured IS RECORD (assd_no GIIS_ASSURED.assd_no%TYPE, assd_name GIIS_ASSURED.assd_name%TYPE);
        TYPE assured IS TABLE OF rec_assured;
        v_assured assured;
     BEGIN
                    
        DELETE FROM bi_assured_dim  cascade  WHERE assured_grp IS NULL ;
           
     
          
        FOR I IN (SELECT x.assd_no, x.assd_name, x.active_tag, CASE WHEN x.birth_date IS NOT NULL AND x.birth_month IS NOT NULL AND x.birth_year IS NOT NULL 
                                                  THEN NVL2(x.birth_date, x.birth_date, null) || NVL2(x.birth_month, '-' || x.birth_month, null) || NVL2(x.birth_year, '-' || x.birth_year, null) 
                                                  ELSE null END birth_date, x.corporate_tag, y.assured_grp, 
                         /*Columns below are added by JJJPajilan 6/17/2016*/                         
                         x.tran_date, x.designation, x.gsis_no, x.mail_addr1, x.mail_addr2, x.mail_addr3, 
                         x.bill_addr1, x.bill_addr2, x.bill_addr3, x.contact_pers, x.phone_no, x.reference_no,
                         x.institutional_tag, x.first_name, x.last_name, x.middle_initial, x.suffix,x.remarks, x.assd_name2,
                         x.assd_tin, x.cp_no, x.sun_no, x.smart_no, x.globe_no, z.rv_meaning VAT_tag, x.no_tin_reason,x.email_address                         
                    FROM GIIS_ASSURED x, bi_assured_dim y, CG_REF_CODES z
                   WHERE x.assd_no = y.assured_code(+)
                     AND x.vat_tag = z.rv_low_value
                     AND z.rv_domain = 'GIIS_ASSURED.VAT_TAG'
                 )
        LOOP 
            IF (i.assured_grp IS NULL) 
            THEN 
                INSERT INTO bi_assured_dim
                VALUES (i.assd_no, i.assd_name, i.active_tag, i.birth_date, i.corporate_tag, i.assured_grp,
                         i.tran_date, i.designation, i.gsis_no, i.mail_addr1, i.mail_addr2, i.mail_addr3, 
                         i.bill_addr1, i.bill_addr2, i.bill_addr3, i.contact_pers, i.phone_no, i.reference_no,
                         i.institutional_tag, i.first_name, i.last_name, i.middle_initial, i.suffix,i.remarks, i.assd_name2,
                         i.assd_tin, i.cp_no, i.sun_no, i.smart_no, i.globe_no, i.VAT_tag, i.no_tin_reason,i.email_address);
            ELSE
                UPDATE bi_assured_dim SET assured_name = i.assd_name, active_tag = i.active_tag, birth_date = i.birth_date, corporate_tag = i.corporate_tag,
                         tran_date = i.tran_date, designation = i.designation, gsis_no = i.gsis_no, mail_addr1 = i.mail_addr1, mail_addr2 = i.mail_addr2, 
                         mail_addr3 = i.mail_addr3, bill_addr1 = i.bill_addr1, bill_addr2 = i.bill_addr2, bill_addr3 = i.bill_addr3, contact_person = i.contact_pers, 
                         phone_no = i.phone_no, reference_no = i.reference_no, institutional_tag= i.institutional_tag, first_name = i.first_name, last_name = i.last_name, 
                         middle_initial = i.middle_initial, suffix = i.suffix, remarks = i.remarks, assd_name2 = i.assd_name2, assd_tin = i.assd_tin, cp_no = i.cp_no, 
                         sun_no = i.sun_no, smart_no = i.smart_no, globe_no = i.globe_no, VAT_tag = i.VAT_tag, no_tin_reason = i.no_tin_reason, email_address = i.email_address
                WHERE assured_code = i.assd_no;
            END IF;
        END LOOP;      
          saver;      
                    
     END; 
    PROCEDURE gen_agent_dim
    IS
    BEGIN 
        DELETE FROM bi_agent_dim  cascade ;
        INSERT INTO bi_agent_dim 
                   (
                     SELECT     a.intm_no, a.intm_name, b.intm_desc,  
                                d.branch_name, UPPER(NVL(c.intm_name,a.intm_name)) parent_name,UPPER(NVL(c.intm_no,a.intm_no)), a.birthdate, c.ref_intm_cd,
                                a.tin, a.corp_tag, a.special_rate, a.lic_tag, a.mail_addr1, a.mail_addr2, a.mail_addr3,
                                a.bill_addr1, a.bill_addr2, a.bill_addr3 , a.phone_no, a.ca_no,a.lf_tag,a.payt_terms,a.eff_date,a.expiry_date,a.remarks,
                                a.wtax_rate, a.active_tag, a.input_vat_rate, a.old_intm_no,a.ca_date, a.nickname, a.cp_no, a.email_add, a.fax_no, a.home_add,
                                a.master_intm_no, a.sun_no, a.smart_no, a.globe_no, a.pin_code  
                      FROM      giis_intermediary a,
                                giis_intm_type b,
                                giis_intermediary c,
                                bi_branch_dim d
                      WHERE     a.intm_type = b.intm_type(+)
                        AND     a.parent_intm_no = c.intm_no(+)
                        AND     a.iss_cd = d.iss_cd(+)
                  );
            saver;   
    END;
   /* PROCEDURE gen_line_sub_line_dim
    IS
    BEGIN
            DELETE FROM  bi_line_sub_line_dim cascade  ;
               
           INSERT INTO bi_line_sub_line_dim  (line_code, line_name, subline_name) 
                ( SELECT  line_code, line_name,  subline_name
                          FROM bi_line_sub_line_dim_mv 
                 );                
           saver; 
    END;  */
    PROCEDURE gen_policy_dim
    IS
    BEGIN
           
       INSERT INTO bi_policy_dim (SELECT policy_id,
                                         a.line_cd || '-' || a.subline_cd || '-' || a.iss_cd || '-' || LTRIM (TO_CHAR (a.issue_yy, '09')) || '-' || LTRIM (TO_CHAR (a.pol_seq_no, '0999999')) || '-'
                                            || LTRIM (TO_CHAR (renew_no, '09')) policy_no,
                                         get_policy_no(policy_id) endorsement_no,
                                         b.rv_meaning pol_flag, reg_policy_sw spec_pol_flag, renew_no, c.rv_meaning dist_flag, endt_seq_no
                                  FROM gipi_polbasic a, cg_ref_codes b, cg_ref_codes c
                                  WHERE 1=1
                                         AND b.rv_domain = 'GIPI_POLBASIC.POL_FLAG'
                                         AND b.rv_low_value = a.pol_flag
                                         AND c.rv_low_value = a.dist_flag
                                         AND c.rv_domain = 'GIPI_POLBASIC.DIST_FLAG');         
       saver;                 
    END;
    
    PROCEDURE gen_claims_dim
    IS
    BEGIN
           
       INSERT INTO bi_claims_dim   (SELECT claim_id,
                                           a.line_cd || '-' || a.subline_cd || '-' || a.iss_cd || '-' || LTRIM (TO_CHAR (a.clm_yy, '09')) || '-' || LTRIM (TO_CHAR (a.clm_seq_no, '0999999')) claim_no,
                                              a.line_cd
                                           || '-'
                                           || a.subline_cd
                                           || '-'
                                           || a.pol_iss_cd
                                           || '-'
                                           || LTRIM (TO_CHAR (a.issue_yy, '09'))
                                           || '-'
                                           || LTRIM (TO_CHAR (a.pol_seq_no, '0999999'))
                                           || '-'
                                           || LTRIM (TO_CHAR (a.renew_no, '09')) policy_no,
                                           b.clm_stat_desc claim_status
                                    FROM gicl_claims a, giis_clm_stat b
                                    WHERE a.clm_stat_cd = b.clm_stat_cd);         
       saver;                 
    END;
    
    PROCEDURE gen_claim_stat --// Claims Status used in Claims Register (PACKAGE REFERENCE: GICLS202_EXTRACTION_PKG & GICLS203_PKG)
    IS  
    BEGIN         
        DELETE FROM BI_GIIS_CLM_STAT cascade ;
        INSERT INTO BI_GIIS_CLM_STAT              
        (SELECT clm_stat_cd , 
               CASE 
               WHEN clm_stat_desc NOT IN ('CANCELLED','CLOSED','DENIED','WITHDRAWN' )
               THEN
                     'OPEN'
               ELSE
                    clm_stat_desc
               END  clm_stat_desc,
               clm_stat_type , 
               remarks, 
               user_id, 
               last_update, 
               cpi_rec_no , 
               cpi_branch_cd
         FROM giis_clm_stat);         
         saver;         
    END;
        PROCEDURE gen_vehicle_dtl_dim
    IS  
    BEGIN         
        DELETE FROM BI_VEHICLE_DTL_DIM cascade ;
        INSERT INTO BI_VEHICLE_DTL_DIM 
                   (policy_id, 
                    item_no, 
                    motor_no, 
                    coc_yy, 
                    coc_serial_no,
                    coc_type,
                    model_year,
                    plate_no,
                    car_company_cd,
                    car_company,
                    type_of_body_cd,
                    type_of_body,
                    make_cd,
                    make,
                    color_cd,
                    color,
                    basic_color_cd,
                    basic_color,
                    serial_no,
                    mv_file_no)
                   (
                     SELECT     A.POLICY_ID, 
                                A.ITEM_NO, 
                                A.MOTOR_NO,  
                                A.COC_YY, 
                                A.COC_SERIAL_NO,
                                A.COC_TYPE,
                                A.MODEL_YEAR,
                                A.PLATE_NO,
                                A.CAR_COMPANY_CD,
                                D.CAR_COMPANY,
                                A.TYPE_OF_BODY_CD,
                                B.TYPE_OF_BODY,
                                A.MAKE_CD,
                                E.MAKE,
                                A.COLOR_CD,
                                C.COLOR,
                                A.BASIC_COLOR_CD,
                                C.BASIC_COLOR,
                                A.SERIAL_NO,
                                A.MV_FILE_NO
                      FROM      gipi_vehicle a,
                                giis_type_of_body b,
                                giis_mc_color c,
                                giis_mc_car_company d,
                                giis_mc_make e
                      WHERE     A.TYPE_OF_BODY_CD = B.TYPE_OF_BODY_CD (+)
                        AND     A.COLOR_CD = C.COLOR_CD (+)
                        AND     A.BASIC_COLOR_CD = C.BASIC_COLOR (+)
                        and     A.CAR_COMPANY_CD = E.CAR_COMPANY_CD (+)
                        AND     A.CAR_COMPANY_CD = D.CAR_COMPANY_CD (+)
                        AND     A.MAKE_CD = E.MAKE_CD (+)
                  );
            saver;   
    END;
    
    PROCEDURE gen_motor_car_dtl_dim
    IS  
    BEGIN         
        DELETE FROM BI_MOTOR_CAR_DTL_DIM cascade ;
        INSERT INTO BI_MOTOR_CAR_DTL_DIM
                   (
                     SELECT a.CLAIM_ID,
                            a.ITEM_NO,
                            a.MOTOR_NO,
                            a.ITEM_TITLE,
                            a.MODEL_YEAR,
                            a.PLATE_NO,
                            a.DRVR_NAME,
                            a.DRVR_SEX,
                            a.DRVR_AGE,
                            A.MOTCAR_COMP_CD,
                            b.car_company,
                            a.MAKE_CD,
                            b.make,
                            a.color_cd,
                            c.color,
                            a.BASIC_COLOR_CD,
                            c.basic_color,
                            a.SERIAL_NO,
                            a.MV_FILE_NO,
                            a.SERIES_CD FROM gicl_motor_car_dtl a,
                                    (SELECT e.CAR_COMPANY_CD, d.make_cd, d.make, e.car_company
                                        FROM giis_mc_make d,
                                             giis_mc_car_company e
                                       WHERE d.car_company_cd = e.car_company_cd
                                    ) b,
                                    giis_mc_color c
                    WHERE a.MOTCAR_COMP_CD = b.car_company_cd(+)
                    AND   a.make_cd = b.make_cd(+)
                    AND   a.basic_color_cd = c.basic_color_cd(+)
                    AND   a.color_cd = c.color_cd(+)
                  );
            saver;   
    END;
    
    PROCEDURE gen_clm_statgrp_dim
    IS  
    BEGIN         
        DELETE FROM bi_claims_statgrp_dim cascade ;
        INSERT INTO bi_claims_statgrp_dim
                   (
                     SELECT rownum clm_stat_seqno, a.clm_stat_cd, a.clm_stat_desc, a.clm_stat_type, a.remarks, 
                           (
                            CASE 
                                 WHEN clm_stat_cd IN ('LD', 'FN', 'OP')                                       THEN 1 
                                 WHEN clm_stat_cd IN ('NO', 'PV')                                             THEN 2
                                 WHEN clm_stat_cd IN ('AC', 'AR')                                             THEN 3
                                 WHEN clm_stat_cd IN ('FR')                                                   THEN 4 
                                 WHEN clm_stat_cd IN ('FA')                                                   THEN 5 
                                 WHEN clm_stat_cd IN ('OL')                                                   THEN 6 
                                 WHEN clm_stat_cd IN ('LR', 'AL', 'RE')                                       THEN 7
                                 WHEN clm_stat_cd IN ('LS', 'AS')                                             THEN 8
                                 WHEN clm_stat_cd IN ('BL')                                                   THEN 9
                                 WHEN clm_stat_cd IN ('CP', 'RC')                                             THEN 10
                                 WHEN clm_stat_cd IN ('WC')                                                   THEN 11
                                 WHEN clm_stat_cd IN ('AV', 'CR', 'PL')                                       THEN 12
                                 WHEN clm_stat_cd IN ('FP')                                                   THEN 13
                                 WHEN clm_stat_cd IN ('FI')                                                   THEN 14
                                 WHEN clm_stat_cd IN ('PC')                                                   THEN 15
                                 WHEN clm_stat_cd IN ('CC', 'CF', 'RH', 'DN', 'CD', 
                                                       'WD', 'PB', 'CN', 'CH', 'DE')                          THEN 16
                            END
                           ) clm_stat_grp, 
                           (
                            CASE 
                                 WHEN clm_stat_cd IN ('LD', 'FN', 'OP')                                       THEN 'WITH LACKING DOCUMENTS'
                                 WHEN clm_stat_cd IN ('NO', 'PV')                                             THEN 'FOR PREMIUM VERIFICATION'
                                 WHEN clm_stat_cd IN ('AC', 'AR')                                             THEN 'AWAITING ADJUSTER''S REPORT'
                                 WHEN clm_stat_cd IN ('FR')                                                   THEN 'FOR EVALUATION' 
                                 WHEN clm_stat_cd IN ('FA')                                                   THEN 'FOR APPROVAL' 
                                 WHEN clm_stat_cd IN ('OL')                                                   THEN 'AWAITING ASSURED''S CONFIRMATION ON THE OFFERED AMOUNT' 
                                 WHEN clm_stat_cd IN ('LR', 'AL', 'RE')                                       THEN 'WITH LOA TO REPAIR'
                                 WHEN clm_stat_cd IN ('LS', 'AS')                                             THEN 'WITH LOA TO SETTLE'
                                 WHEN clm_stat_cd IN ('BL')                                                   THEN 'AWAITING adjuster''s /repair shop''s bill'
                                 WHEN clm_stat_cd IN ('CP', 'RC')                                             THEN 'FOR CHECK PREPARATION'
                                 WHEN clm_stat_cd IN ('WC')                                                   THEN 'WITH CHECK'
                                 WHEN clm_stat_cd IN ('AV', 'CR', 'PL')                                       THEN 'CHECK RELEASED'
                                 WHEN clm_stat_cd IN ('FP')                                                   THEN 'FOR AUDIT'
                                 WHEN clm_stat_cd IN ('FI')                                                   THEN 'FOR ISSUANCE OF FINAL LOSS ADVICE/FINAL DEMAND LETTER'
                                 WHEN clm_stat_cd IN ('PC')                                                   THEN 'WITH PENDING CASE'
                                 WHEN clm_stat_cd IN ('CC', 'CF', 'RH', 'DN', 'CD', 
                                                       'WD', 'PB', 'CN', 'CH', 'DE')                          THEN 'CLOSED FILE'
                            END
                           ) clm_grp_stat_desc FROM giis_clm_stat a
                  );
            saver;   
    END;
    
    
    
    PROCEDURE gen_clm_fire_item_dim
    IS  
    BEGIN         
        DELETE FROM bi_fire_item_dim cascade ;
        INSERT INTO bi_fire_item_dim
                   (
                     SELECT a.Policy_id, a.Item_No, b.Block_id, b.District_no, b.Block_no, b.Block_desc,
                            c.Province_cd,
                            c.Province_desc,
                            d.Region_cd,
                            d.Region_desc,
                            e.City_cd,
                            e.City,
                            f.EQ_zone,
                            f.EQ_desc,
                            g.Tarf_cd,
                            g.Tarf_desc,
                            h.Fr_item_type,
                            h.Fr_itm_tp_ds,
                            a.Loc_risk1,
                            a.Loc_risk2,
                            a.Loc_risk3,
                            i.Tariff_zone,
                            i.Tariff_zone_desc,
                            j.Typhoon_zone,
                            j.Typhoon_zone_desc,
                            k.Construction_cd,
                            k.Construction_desc,
                            l.Occupancy_cd,
                            l.Occupancy_desc,
                            m.Flood_zone,
                            m.Flood_zone_desc
                            FROM gipi_fireitem a, giis_block b, giis_province c, giis_region d, giis_city e, giis_eqzone f,
                                 giis_tariff g, giis_fi_item_type h, giis_tariff_zone i, giis_typhoon_zone j,
                                 giis_fire_construction k, giis_fire_occupancy l, giis_flood_zone m
                            WHERE a.block_id = b.block_id
                              AND b.province_cd = c.province_cd
                              AND c.region_cd = d.region_cd
                              AND b.city_cd = e.city_cd
                              AND a.eq_zone = f.EQ_ZONE(+)
                              AND a.tarf_cd = g.tarf_cd(+)
                              AND a.fr_item_type = h.fr_item_type(+)
                              AND a.tariff_zone = i.tariff_zone(+)
                              AND a.typhoon_zone = j.typhoon_zone(+)
                              AND a.construction_cd = k.construction_cd(+)
                              AND a.occupancy_cd = l.occupancy_cd(+)
                              AND a.flood_zone = m.flood_zone(+)
                  );
            saver;   
    END;
    
    PROCEDURE main(p_exclude_time NUMBER DEFAULT NULL)
    IS
    BEGIN
        IF p_exclude_time IS NULL
        THEN
            gen_time_dim(TRUNC(SYSDATE),v_time_def_range,1);
        END IF;
        gen_claim_stat;
        gen_assured_dim;
        gen_branch_dim ;        
        gen_agent_dim;
        gen_line_cd_dim;
        gen_vehicle_dtl_dim;
        gen_motor_car_dtl_dim;
        --gen_line_sub_line_dim;
        gen_policy_dim;
        gen_clm_statgrp_dim;
        gen_clm_fire_item_dim;
    END;     
END;
/
