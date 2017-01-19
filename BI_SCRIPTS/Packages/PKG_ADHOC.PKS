CREATE OR REPLACE PACKAGE BIADMIN.pkg_adhoc
IS
   /********************************************************
    Description: 
    Date Created: October 2, 2015   
   *********************************************************/
   PROCEDURE process_dim_cols(p_table_fact VARCHAR2, p_column_fact VARCHAR2,p_table_dim VARCHAR2, p_column_dim_compare  VARCHAR2,p_column_dim_code VARCHAR2, p_column_for_update VARCHAR2  DEFAULT NULL);
   FUNCTION  get_time_dim (p_date VARCHAR2) RETURN NUMBER;   
   FUNCTION  get_line_dim(p_line  VARCHAR2, p_subline  VARCHAR2, p_peril VARCHAR2) RETURN NUMBER;
   FUNCTION  get_line_dim(p_line  VARCHAR2, p_subline  VARCHAR2) RETURN NUMBER;       
   FUNCTION  get_branch(p_iss_cd VARCHAR2) RETURN NUMBER;      
   FUNCTION  get_time(p_time_code NUMBER) RETURN DATE;
   
END;
/