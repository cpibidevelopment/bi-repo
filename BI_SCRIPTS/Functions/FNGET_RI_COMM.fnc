CREATE OR REPLACE FUNCTION BIADMIN.fnget_ri_comm(p_iss_cd VARCHAR2, p_prem_seq_no NUMBER,p_line_cd VARCHAR2) 
   RETURN NUMBER 
   IS 
     v_output NUMBER;
   BEGIN
          SELECT SUM(ri_comm_amt)
            INTO v_output   
            FROM gipi_invperil a, giis_peril b
           WHERE  a.iss_cd =p_iss_cd
             AND a.prem_seq_no = p_prem_seq_no
             AND b.line_cd = p_line_cd
             AND a.peril_cd = b.peril_cd;
          RETURN v_output;
   EXCEPTION 
      WHEN OTHERS THEN 
          RETURN NULL;   
   END; 
/

