CREATE OR REPLACE FUNCTION BIADMIN.get_net_retention
                              (p_policy_id  bi_production_net_retention.policy_id%TYPE,p_peril_cd bi_production_net_retention.peril_cd%TYPE, 
                                p_iss_cd    bi_production_net_retention.iss_cd%TYPE, p_prem_seq_no bi_production_net_retention.prem_seq_no%TYPE,
                                p_share_cd bi_production_net_retention.share_cd%TYPE DEFAULT NULL,
                                p_acct_ent_date DATE DEFAULT NULL
                               )
    RETURN NUMBER
    IS
        v_output NUMBER;
    BEGIN
     IF p_acct_ent_date  IS  NULL
     THEN 
     
      SELECT SUM(net_retention) 
        INTO v_output
        FROM bi_production_net_retention
      WHERE  policy_id = p_policy_id
        AND  peril_cd= NVL(p_peril_cd,peril_cd)
        AND  iss_cd   = p_iss_cd       
        AND  share_cd = NVL(p_share_cd,share_cd) 
        AND  prem_seq_no = p_prem_seq_no;   
    
    ELSE
      SELECT SUM(
                 CASE WHEN  p_acct_ent_date = TRUNC(acct_ent_date) AND p_acct_ent_date = TRUNC(acct_neg_date)
                      THEN
                         0
                       WHEN   p_acct_ent_date = TRUNC(acct_ent_date)
                       THEN
                                net_retention    
                       ELSE
                               -net_retention                 
                 END            
               )  
        INTO v_output
        FROM bi_production_net_retention
      WHERE  policy_id = p_policy_id
        AND  peril_cd= NVL(p_peril_cd,peril_cd)
        AND  iss_cd   = p_iss_cd       
        AND  TRUNC(acct_ent_date) = p_acct_ent_date 
        AND  share_cd = NVL(p_share_cd,share_cd) 
        AND  prem_seq_no = p_prem_seq_no;  
       
    END IF;   
       RETURN v_output;        
    EXCEPTION     
        WHEN NO_DATA_FOUND THEN 
             RETURN v_output;
    END;
/
