CREATE OR REPLACE FUNCTION BIADMIN.year_ago_amt(p_year NUMBER, p_month_no NUMBER, p_branch_code NUMBER)
RETURN NUMBER
IS
 v_output NUMBER;
BEGIN
   select  SUM(NVL(actual_amt, 0)) 
     into v_output
    from BI_PROD_BUD_ACT_FACT a, bi_time_dim b
   where A.BUD_ACT_DATE = b.time_code
     and year_no = p_year-1
     and month_no =p_month_no 
     and branch_code = p_branch_code;
    --GROUP BY year_no, month_no ;
    RETURN v_output;
END;
/