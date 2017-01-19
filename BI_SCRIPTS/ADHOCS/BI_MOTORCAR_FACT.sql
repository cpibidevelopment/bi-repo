SET SERVEROUTPUT ON
SET FEEDBACK  OFF  


BEGIN  
 DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------------------------'); 
 DBMS_OUTPUT.PUT_LINE('##Processing  table bi_motoror_dim##');
 DBMS_OUTPUT.PUT_LINE('Dropping Materialized Views...');  
END;   
/

BEGIN
process_object('bi_motorcar_dim',  'TABLE ','DROP');
END;
/  
  
  CREATE TABLE BI_MOTORCAR_DIM
          AS  
       SELECT  f.line_code,
               a.policy_no,
               b.model_year,
               b.make,
               a.prem_amt,
               d.peril_sname,
               c.car_company manufacturer,
               e.type_of_body
         FROM  bi_production_fact_mv a,
               (select * from GIPI_VEHICLE where item_no = (select min(item_no) from gipi_vehicle)) b,
               GIIS_MC_CAR_COMPANY c,
               GIIS_PERIL d,
               GIIS_TYPE_OF_BODY e,
               bi_line_dim_mv f
        WHERE  a.iss_cd not in ('CS','GH','BL','BU')
          AND  a.line_cd = 'MC'
          AND  a.policy_id = b.policy_id
          AND  b.car_company_cd = c.car_company_cd
          AND  a.peril_cd = d.peril_cd
          AND  a.line_cd = d.line_cd
          AND  b.type_of_body_cd = e.type_of_body_cd
          AND  a.line_cd = f.line_cd
          AND  a.subline_cd =f.subline_cd
          AND  a.peril_cd  =f.peril_cd;
          
BEGIN  
DBMS_OUTPUT.PUT_LINE('bi_motorcar_fact--created....');
END;    
/

BEGIN  
DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------------------------'); 
END;
/
