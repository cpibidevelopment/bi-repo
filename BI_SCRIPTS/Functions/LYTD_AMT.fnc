CREATE OR REPLACE FUNCTION BIADMIN.LYTD_AMT(p_year NUMBER, p_month_no NUMBER, p_branch_code NUMBER,p_tocompute NUMBER)
RETURN NUMBER
IS
 v_output NUMBER;
 v_date1  DATE;
 v_date2  DATE;
 
BEGIN

   SELECT (TRUNC(to_date,'Year')) from_date,  to_date
     INTO v_date1, v_date2
     FROM (
            SELECT MAX(calendar_date) to_date
              FROM bi_time_dim b
             WHERE year_no = p_year - 1
               AND month_no = p_month_no);
   
  SELECT  SUM(NVL(DECODE(p_tocompute,1,actual_amt,2,budget_amt), 0)) 
    INTO v_output
    FROM BI_PROD_BUD_ACT_FACT a, bi_time_dim b
   WHERE A.BUD_ACT_DATE = b.time_code
     AND a.branch_code = p_branch_code
     AND calendar_date BETWEEN v_date1 AND v_date2;
    RETURN v_output;
END;