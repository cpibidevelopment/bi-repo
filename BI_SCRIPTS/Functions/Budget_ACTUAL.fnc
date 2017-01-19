DROP VIEW BIADMIN.BUDGET_ACTUAL_PROD;

/* Formatted on 2015/09/24 15:25 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW biadmin.budget_actual_prod (time_code,
                                                         year_no,
                                                         month_no,
                                                         branch_code,
                                                         line_code,
                                                         actual_amt,
                                                         yearagoactual,
                                                         ytd_actual,
                                                         lytd_actual,
                                                         budget_amt,
                                                         ytd_budget,
                                                         prd_amt,
                                                         mx_amt
                                                        )
AS
   SELECT time_code, year_no, month_no, branch_code, line_code, actual_amt,
          NVL (year_ago_amt (year_no, month_no, branch_code), 0) yearagoactual, NVL (ytd_amt (year_no, month_no, branch_code, 1), 0) ytd_actual,
          NVL (lytd_amt (year_no, month_no, branch_code, 1), 0) lytd_actual,
          NVL (budget_amt, 0), NVL (ytd_amt (year_no, month_no, branch_code, 2), 0) ytd_budget,
          NVL (prd_amt, 0), NVL (mx_amt, 0)
     FROM (SELECT   b.time_code, year_no, month_no, branch_code, a.line_code,
                    SUM (actual_amt) actual_amt, SUM (budget_amt) budget_amt,
                    SUM (prd_amt) prd_amt, SUM (mx_amt) mx_amt
               FROM bi_prod_bud_act_fact a, bi_time_dim b
              WHERE a.bud_act_date = b.time_code
           --AND b.year_no IN (2012, 2013, 2014, 2015)
           --AND budget_amt <> 0
           GROUP BY b.time_code, year_no, month_no, branch_code, line_code
           ORDER BY year_no, month_no);

