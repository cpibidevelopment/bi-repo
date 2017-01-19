CREATE OR REPLACE PACKAGE BODY BIADMIN.pkg_adhoc
IS
    PROCEDURE gen_time_code(p1 DATE, p2 OUT NUMBER) 
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
       p2:= v_record.time_code;             
       INSERT INTO BI_TIME_DIM  VALUES v_record;       
       COMMIT;
     END;
   FUNCTION query_builder(p_table_name VARCHAR2 ,p_column_name VARCHAR2, p_where_clause VARCHAR2 DEFAULT NULL)
   RETURN VARCHAR2
   IS
      v_output VARCHAR2(10000);
   BEGIN
     v_output:='SELECT '  || p_column_name ||  
               '  FROM '  || p_table_name || ' a ' ;
     IF p_where_clause IS NOT NULL 
     THEN
        v_output:= v_output || ' ' || p_where_clause;                  
     END IF;          
     RETURN v_output;
   END;
   PROCEDURE process_dim_cols(p_table_fact VARCHAR2, p_column_fact VARCHAR2,p_table_dim VARCHAR2, p_column_dim_compare  VARCHAR2,p_column_dim_code VARCHAR2, p_column_for_update VARCHAR2  DEFAULT NULL)
   IS
       c_rec               SYS_REFCURSOR;
       v_query_main        VARCHAR2(1000);
       v_query_dtl         VARCHAR2(1000);  
       v_rec               VARCHAR2(1000);
       v_time_dim CONSTANT VARCHAR2(30) := 'BI_TIME_DIM';    
       v_output_dtl        VARCHAR2(1000);
       v_insert            VARCHAR2(1000);      
       v_update            VARCHAR2(1000);    
   BEGIN                
       v_query_main := query_builder(p_table_fact , p_column_fact);       
       OPEN c_rec FOR v_query_main;
         LOOP           
            FETCH c_rec INTO v_rec;
            EXIT WHEN c_rec%NOTFOUND;
            IF v_rec IS NOT NULL
            THEN                                        
                    IF p_table_dim = v_time_dim
                    THEN
                       v_query_dtl := query_builder(p_table_dim, p_column_dim_code  , ' WHERE a.' || p_column_dim_compare || ' = TO_DATE( :v_rec ,''YYYYMMDD'')'  );
                    ELSE
                        v_query_dtl := query_builder(p_table_dim, p_column_dim_code  , ' WHERE a.'  ||p_column_dim_compare  || ' =  :v_rec'  );
                    END IF;  
                    BEGIN
                      --DBMS_OUTPUT.PUT_LINE(v_query_dtl);
                      --EXIT;
                      EXECUTE IMMEDIATE v_query_dtl INTO v_output_dtl USING v_rec;              
                    EXCEPTION 
                    WHEN NO_DATA_FOUND THEN
                        IF p_table_dim = v_time_dim  
                        THEN                
                           gen_time_code(TO_DATE( v_rec ,'YYYYMMDD'), v_output_dtl );
                        END IF;                                                  
                    END;             
                   --DBMS_OUTPUT.PUT_LINE(v_output_dtl);
                   IF p_column_for_update IS NULL
                   THEN 
                           v_update := 'UPDATE   ' || p_table_fact ||
                                       '   SET   ' || p_column_fact  || ' = ' || v_output_dtl  ||
                                       ' WHERE   ' || p_column_fact  || ' =  ' || '''' || v_rec || '''';
                   ELSE
                           v_update := 'UPDATE   ' || p_table_fact ||
                                       '   SET   ' || p_column_for_update   || ' = ' || v_output_dtl  ||
                                       ' WHERE   ' || p_column_fact         || ' =  ' || '''' || v_rec || '''';
                   END IF;
                   EXECUTE IMMEDIATE v_update ;
                   COMMIT;                                                                                                          
            END IF;
         END LOOP;
       CLOSE c_rec;                                                                 
   END;
   FUNCTION  get_time_dim (p_date VARCHAR2) RETURN NUMBER
   IS
     v_output NUMBER;
   BEGIN
     SELECT time_code
       INTO v_output
       FROM bi_time_dim
      WHERE calendar_date = TO_DATE(p_date,'YYYYMMDD');
      RETURN v_output;
   EXCEPTION        
   WHEN OTHERS THEN 
         RETURN NULL;   
   END;   
   FUNCTION  get_line_dim(p_line  VARCHAR2, p_subline  VARCHAR2, p_peril VARCHAR2)
   RETURN NUMBER
   IS
     v_output NUMBER;
   BEGIN
   
     SELECT line_code 
       INTO v_output
       FROM bi_line_dim_mv
      WHERE line_cd = p_line
        AND NVL(peril_cd,-1)  = NVL(p_peril,-1)
        AND subline_cd = p_subline;
     RETURN v_output;
   EXCEPTION 
      WHEN OTHERS THEN 
          RETURN NULL;        
   END;
   FUNCTION  get_line_dim(p_line  VARCHAR2, p_subline  VARCHAR2)
   RETURN NUMBER
   IS   
     v_output NUMBER;
   BEGIN
   
     SELECT line_code 
       INTO v_output
       FROM bi_line_dim_mv
      WHERE line_cd = p_line        
        AND subline_cd = p_subline
        AND peril_cd IS NULL;
     RETURN v_output;
   EXCEPTION 
      WHEN OTHERS THEN 
          RETURN NULL;        
   END;   
   FUNCTION get_branch(p_iss_cd VARCHAR2)
   RETURN NUMBER
   IS 
     v_output NUMBER;
   BEGIN
          
      SELECT  branch_code
        INTO  v_output 
        FROM  BI_BRANCH_DIM
       WHERE  iss_cd  = p_iss_cd;
     RETURN v_output;
   EXCEPTION 
      WHEN OTHERS THEN 
           RETURN NULL;          
   END;   
   FUNCTION  get_time(p_time_code NUMBER) RETURN DATE
   IS
     v_output DATE;
   BEGIN
     SELECT calendar_date
       INTO v_output
       FROM bi_time_dim
      WHERE time_code = p_time_code;
      RETURN v_output;
   EXCEPTION 
     WHEN OTHERS THEN 
        RETURN  NULL;
   END;
END;
/
