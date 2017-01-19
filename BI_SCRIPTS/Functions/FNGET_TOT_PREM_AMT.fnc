CREATE OR REPLACE FUNCTION BIADMIN.fnget_tot_prem_amt (
      p_claim_id   IN   gicl_claims.claim_id%TYPE,
      p_item_no    IN   gicl_item_peril.item_no%TYPE,
      p_peril_cd   IN   gicl_item_peril.peril_cd%TYPE
   )
      RETURN NUMBER
   IS
      v_tot_prem_amt   gipi_itmperil.prem_amt%TYPE;   
      BEGIN
        SELECT
          SUM (tot_prem_amt)  tot_prem_amt
           INTO v_tot_prem_amt
           FROM BI_CLAIMS_REG_MV_TMP
          WHERE peril_cd = p_peril_cd
            AND item_no = p_item_no
            AND claim_id = p_claim_id;
          RETURN v_tot_prem_amt; 
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            v_tot_prem_amt := 0;
      END; 
/

