CREATE OR REPLACE FUNCTION BIADMIN.get_dist_tsi
                              (p_policy_id  bi_production_net_retention.policy_id%TYPE,p_peril_cd bi_production_net_retention.peril_cd%TYPE, 
                                p_iss_cd    bi_production_net_retention.iss_cd%TYPE, p_prem_seq_no bi_production_net_retention.prem_seq_no%TYPE,
                                p_share_cd bi_production_net_retention.share_cd%TYPE DEFAULT NULL,
                                p_acct_ent_date DATE DEFAULT NULL
                               )
    RETURN NUMBER
    IS
        v_output NUMBER;
    BEGIN             
      SELECT SUM(dist_tsi) 
        INTO v_output
        FROM bi_production_net_retention
      WHERE  policy_id = p_policy_id
        AND  peril_cd= NVL(p_peril_cd,peril_cd)
        AND  iss_cd   = p_iss_cd       
        AND  share_cd = NVL(p_share_cd,share_cd) 
        AND  prem_seq_no = p_prem_seq_no;              
       RETURN v_output;        
    EXCEPTION     
        WHEN NO_DATA_FOUND THEN 
             RETURN v_output;
    END;
/
