CREATE OR REPLACE FUNCTION fnget_check_Date
    (--p_scope         NUMBER,
     p_line_cd        gipi_polbasic.line_cd%TYPE,
     p_subline_cd    gipi_polbasic.subline_Cd%TYPE,
     p_iss_cd        gipi_polbasic.iss_cd%TYPE,
     p_issue_yy        gipi_polbasic.issue_yy%TYPE,
     p_pol_seq_no    gipi_polbasic.pol_seq_no%TYPE,
     p_renew_no        gipi_polbasic.renew_no%TYPE,
     p_param_date      NUMBER--,
     --p_from_date       DATE,
     --p_to_date         DATE
     )
   RETURN DATE
IS
  v_check_date    DATE;
BEGIN
    SELECT decode(p_param_Date ,1, a.issue_date,2,a.eff_date,3, (  CASE   WHEN a.booking_mth   IS NOT NULL AND   a.booking_year  IS NOT NULL 
                                                                          THEN 
                                                                           last_day(to_date('01-' || a.booking_mth  || '-'  ||   a.booking_year , 'DD-MONTH-YYYY' ))
                                                                 END ), 4 , 
                  a.acct_ent_date    , 5,a.spld_acct_ent_date                                                                         
                  )  --,
      INTO v_check_date
          /* a.eff_date   eff_date,
           a.booking_mth booking_month,
           a.booking_year booking_year,
           a.acct_ent_date acct_ent_date,
           a.spld_acct_ent_date spld_acct_ent_date*/
      FROM gipi_polbasic a
     WHERE a.line_cd     = p_line_cd
       AND a.subline_cd  = p_subline_cd
        AND a.iss_cd     = p_iss_cd
       AND a.issue_yy    = p_issue_yy
       AND a.pol_seq_no  = p_pol_seq_no
       AND a.renew_no    = p_renew_no
       AND a.endt_seq_no = Get_Endt_Seq_No(a.line_cd,a.subline_cd,a.iss_cd,a.issue_yy,a.pol_seq_no,a.renew_no);
   RETURN v_check_date;
EXCEPTION 
WHEN NO_DATA_FOUND THEN
     RETURN NULL;
END;

