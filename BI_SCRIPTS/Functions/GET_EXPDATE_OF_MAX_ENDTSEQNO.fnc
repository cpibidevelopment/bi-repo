CREATE OR REPLACE FUNCTION BIADMIN.get_expdate_of_max_endtseqno(
  /** 
  *** get the total sum premium from all its endts...
  **/
 p_line_cd     GIPI_POLBASIC.line_cd%TYPE,
 p_subline_cd GIPI_POLBASIC.subline_cd%TYPE,
    p_iss_cd     GIPI_POLBASIC.iss_cd%TYPE,
 p_issue_yy     GIPI_POLBASIC.issue_yy%TYPE,
 p_pol_seq_no GIPI_POLBASIC.pol_seq_no%TYPE,
 p_renew_no     GIPI_POLBASIC.renew_no%TYPE)
  RETURN DATE AS
    v_exp_date GIPI_POLBASIC.EXPIRY_DATE%TYPE := NULL;
  BEGIN
     FOR i IN (SELECT MAX(C.ENDT_SEQ_NO) max_endt_seq_no
                FROM GIPI_POLBASIC c
                WHERE c.line_cd     = p_line_cd
                  AND c.subline_cd  = p_subline_cd
                  AND c.iss_cd      = p_iss_cd
                  AND c.issue_yy    = p_issue_yy
                  AND c.pol_seq_no  = p_pol_seq_no
                  AND c.renew_no    = p_renew_no)
     LOOP
        SELECT A.EXPIRY_DATE 
        INTO v_exp_date
        FROM GIPI_POLBASIC a
        WHERE a.line_cd     = p_line_cd
                  AND a.subline_cd  = p_subline_cd
                  AND a.iss_cd      = p_iss_cd
                  AND a.issue_yy    = p_issue_yy
                  AND a.pol_seq_no  = p_pol_seq_no
                  AND a.renew_no    = p_renew_no
                  AND a.endt_seq_no = i.max_endt_seq_no;
     END LOOP;
 RETURN v_exp_date;
  END; 
/

