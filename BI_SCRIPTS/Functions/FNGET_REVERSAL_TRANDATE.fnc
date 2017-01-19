CREATE OR REPLACE FUNCTION BIADMIN.fnget_reversal_trandate(p_tranid giac_acctrans.tran_id%TYPE)
RETURN VARCHAR2 
IS
  v_output VARCHAR2(8);
BEGIN
  SELECT  TO_CHAR(b.tran_date,'YYYYMMDD')
    INTO v_output
    FROM giac_reversals a, giac_acctrans b
   WHERE a.reversing_tran_id = b.tran_id 
     AND a.gacc_tran_id = p_tranid;  

  RETURN v_output;
EXCEPTION 
  WHEN OTHERS THEN
   RETURN NULL;
END; 
/

