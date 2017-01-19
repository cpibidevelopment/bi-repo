CREATE OR REPLACE FUNCTION BIADMIN.get_pol_id_of_renew(
 /* rollie 21 june 2004
 ** to get the prem of policy if it is renewed
 **/
  p_line_cd     GIPI_POLBASIC.line_cd%TYPE,
p_subline_cd GIPI_POLBASIC.subline_cd%TYPE,
   p_iss_cd     GIPI_POLBASIC.iss_cd%TYPE,
p_issue_yy     GIPI_POLBASIC.issue_yy%TYPE,
p_pol_seq_no GIPI_POLBASIC.pol_seq_no%TYPE,
p_renew_no      GIPI_POLBASIC.renew_no%TYPE)
RETURN NUMBER AS
   v_pol_id_renew NUMBER := 0;
BEGIN
 ------------------PACKAGE consideration---------------
   SELECT a.pack_policy_id
  INTO v_pol_id_renew
     FROM GIPI_PACK_POLBASIC A
    WHERE A.pack_policy_id = (SELECT b.new_pack_policy_id
                      FROM GIPI_PACK_POLNREP b, GIPI_PACK_POLBASIC c
               WHERE b.old_pack_policy_id = c.pack_policy_id
        AND c.line_cd     = p_line_cd
        AND c.subline_cd  = p_subline_cd
        AND c.iss_cd      = p_iss_cd
        AND c.issue_yy    = p_issue_yy
        AND c.pol_seq_no  = p_pol_seq_no
        AND c.renew_no    = p_renew_no)
 AND pol_flag NOT IN ('4','5');    --added BY GMI 09/26/06
   RETURN v_pol_id_renew;
--  ------------------PACKAGE end-------------------------
EXCEPTION
  WHEN NO_DATA_FOUND THEN
  BEGIN
      SELECT a.policy_id
      INTO v_pol_id_renew
         FROM GIPI_POLBASIC A
        WHERE A.policy_id = (SELECT b.new_policy_id
                          FROM GIPI_POLNREP b, GIPI_POLBASIC c
                   WHERE b.old_policy_id = c.policy_id
            AND c.line_cd     = p_line_cd
            AND c.subline_cd  = p_subline_cd
            AND c.iss_cd      = p_iss_cd
            AND c.issue_yy    = p_issue_yy
            AND c.pol_seq_no  = p_pol_seq_no
            AND c.renew_no    = p_renew_no)
     AND pol_flag NOT IN ('4','5');    --added BY GMI 09/26/06
     RETURN v_pol_id_renew;
  EXCEPTION
      WHEN OTHERS THEN
          RETURN NULL;
  END;
END; 
/

