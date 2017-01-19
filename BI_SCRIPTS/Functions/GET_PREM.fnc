CREATE OR REPLACE FUNCTION BIADMIN.get_prem(
  /** 
  *** get the total sum premium from all its endts...
  **/
 p_line_cd     GIPI_POLBASIC.line_cd%TYPE,
 p_subline_cd GIPI_POLBASIC.subline_cd%TYPE,
    p_iss_cd     GIPI_POLBASIC.iss_cd%TYPE,
 p_issue_yy     GIPI_POLBASIC.issue_yy%TYPE,
 p_pol_seq_no GIPI_POLBASIC.pol_seq_no%TYPE,
 p_renew_no     GIPI_POLBASIC.renew_no%TYPE)
  RETURN NUMBER AS
    v_prem NUMBER(18,2) := 0;
  BEGIN
  ------------------PACKAGE consideration---------------
    SELECT SUM(c.prem_amt)
   INTO v_prem
      FROM GIPI_PACK_POLBASIC c
     WHERE c.line_cd     = p_line_cd
    AND c.subline_cd  = p_subline_cd
    AND c.iss_cd      = p_iss_cd
    AND c.issue_yy    = p_issue_yy
    AND c.pol_seq_no  = p_pol_seq_no
    AND c.renew_no    = p_renew_no
    AND c.pol_flag NOT IN ('4','5');
  ------------------PACKAGE end-------------------------
   SELECT SUM(c.prem_amt)
   INTO v_prem
      FROM GIPI_POLBASIC c
     WHERE c.line_cd     = p_line_cd
    AND c.subline_cd  = p_subline_cd
    AND c.iss_cd      = p_iss_cd
    AND c.issue_yy    = p_issue_yy
    AND c.pol_seq_no  = p_pol_seq_no
    AND c.renew_no    = p_renew_no
    AND c.pol_flag NOT IN ('4','5');
 RETURN v_prem;
  END; 
/

