CREATE OR REPLACE FUNCTION BIADMIN.fnget_check_payment(p_claim_id gicl_clm_res_hist.claim_id%TYPE,p_item_no gicl_clm_res_hist.item_no%TYPE, 
                                               p_peril_cd gicl_clm_res_hist.peril_cd%TYPE, p_type VARCHAR2 
                                              )
RETURN VARCHAR2
IS
  v_output VARCHAR2(1);
BEGIN
  SELECT DISTINCT 'Y'
    INTO v_output
    FROM gicl_clm_res_hist
   WHERE tran_id IS NOT NULL
     AND NVL(cancel_tag,'N') = 'N' 
     AND claim_id = p_claim_id
     AND item_no = p_item_no --considered item number by MAC 11/09/2012.
     AND peril_cd = p_peril_cd
     AND (  (expenses_paid<> 0 AND p_type = 'E')
             OR  
             (losses_paid <> 0 AND p_type = 'L')
          );  
  RETURN v_output;
EXCEPTION                  
WHEN OTHERS THEN 
   RETURN NULL;                           
END; 
/

