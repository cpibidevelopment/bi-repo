CREATE OR REPLACE FUNCTION BIADMIN.fnget_cg_ref(p_low_value cg_ref_codes.rv_low_value%TYPE, p_rv_domain cg_ref_codes.rv_domain%TYPE )
RETURN cg_ref_codes.rv_meaning%TYPE
IS
  v_output cg_ref_codes.rv_meaning%TYPE;
BEGIN
   SELECT rv_meaning
     INTO v_output
     FROM cg_ref_codes
    WHERE rv_domain = p_rv_domain
      AND rv_low_value=p_low_value;  
   RETURN v_output;
EXCEPTION 
  WHEN OTHERS THEN 
     RETURN NULL;
END; 
/

