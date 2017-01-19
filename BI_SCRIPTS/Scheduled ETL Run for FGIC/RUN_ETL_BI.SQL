
column ts new_val x

select 'BI_LOGS-'  || to_char(sysdate,'ddmmyyyy-hh-mi-ss') ts from dual;
 
spool E:\Script\BI_SCRIPTS\logs/&x..log 


SET SERVEROUTPUT ON 
SET LINESIZE 200
SET FEEDBACK OFF
SET ECHO OFF
BEGIN
DBMS_OUTPUT.PUT_LINE('***************************************');
DBMS_OUTPUT.PUT_LINE('Start..');
END;
/

SELECT  TO_CHAR(SYSDATE,'MM-DD-YYYY-HH:MI:SS:AM')  START_TIME
   FROM DUAL;


ALTER PACKAGE giacp  COMPILE;
ALTER PACKAGE giacp  COMPILE BODY;



@E:\Script\BI_SCRIPTS\misc/start_logger.SQL

@E:\Script\BI_SCRIPTS\tables/bi_tables.SQL
@E:\Script\BI_SCRIPTS\indexes/bi_indexes.SQL
@E:\Script\BI_SCRIPTS\materialized_views/mv_others.SQL



ALTER PACKAGE pkg_populate_dim  COMPILE;
ALTER PACKAGE pkg_populate_dim   COMPILE BODY;


SET SERVEROUTPUT ON 
DECLARE
   A NUMBER;
BEGIN
  A:= DBMS_UTILITY.GET_TIME;    
  pkg_populate_dim.main;
  A:= DBMS_UTILITY.GET_TIME-A;    
  A:=A/100;
  DBMS_OUTPUT.PUT_LINE('Finished...1st Part.'  || A);
END; 
/


ALTER PACKAGE pkg_adhoc COMPILE;
ALTER PACKAGE pkg_adhoc COMPILE BODY;

@E:\Script\BI_SCRIPTS\materialized_views/mv_production.SQL
@E:\Script\BI_SCRIPTS\materialized_views/mv_collection_new.SQL
@E:\Script\BI_SCRIPTS\materialized_views/mv_prod_dist.SQL
@E:\Script\BI_SCRIPTS\materialized_views/mv_production_per_peril.SQL
@E:\Script\BI_SCRIPTS\materialized_views/mv_claims.SQL
@E:\Script\BI_SCRIPTS\materialized_views/MV_CLAIMS_OUTSTANDING.SQL
@E:\Script\BI_SCRIPTS\materialized_views/MV_CLAIMS_LOSSES_PAID.SQL
@E:\Script\BI_SCRIPTS\materialized_views/MV_CLAIMS_LP_AGENT.SQL
@E:\Script\BI_SCRIPTS\materialized_views/MV_CLAIMS_REGISTER.SQL
@E:\Script\BI_SCRIPTS\materialized_views/MV_CLAIMS_BORDEREAUX.SQL



ALTER PACKAGE pkg_transform COMPILE;
ALTER PACKAGE pkg_transform  COMPILE BODY;


SET SERVEROUTPUT ON 
DECLARE
   A NUMBER;
BEGIN
  A:= DBMS_UTILITY.GET_TIME;  
  pkg_transform.generate_budget;
  pkg_transform.generate_production_tax; 
  pkg_transform.generate_collection_tax;   
  pkg_transform.generate_production_dist;
  pkg_transform.generate_production;
  pkg_transform.generate_claims;
  pkg_transform.generate_claims_agent;
  pkg_transform.generate_claims_outstanding;
  pkg_transform.generate_claims_lp_agent;
  pkg_transform.generate_claims_losses_paid;
  pkg_transform.generate_claims_brdrx;
  pkg_transform.generate_claims_reg;
  pkg_transform.generate_claims_take_up;
  A:= DBMS_UTILITY.GET_TIME-A;    
  A:=A/100;
  DBMS_OUTPUT.PUT_LINE('Finished...2nd Part.'  || A);
END; 
/

@E:\Script\BI_SCRIPTS\ADHOCS/BI_PROD_COLLECTION_MV.SQL
@E:\Script\BI_SCRIPTS\ADHOCS/bi_motorcar_fact.SQL
@E:\Script\BI_SCRIPTS\ADHOCS/BI_NOT_TAKEN_UP.SQL
@E:\Script\BI_SCRIPTS\misc/end_logger.SQL

SELECT  TO_CHAR(SYSDATE,'MM-DD-YYYY-HH:MI:SS:AM')  END_TIME
   FROM DUAL;

BEGIN
DBMS_OUTPUT.PUT_LINE('End..');
DBMS_OUTPUT.PUT_LINE('***************************************');
END;
/


SPOOL OFF;

EXIT
