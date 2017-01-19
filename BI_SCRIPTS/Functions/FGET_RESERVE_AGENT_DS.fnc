CREATE OR REPLACE FUNCTION BIADMIN.fget_reserve_agent_ds(p_claim_id gicl_claims.claim_id%TYPE,
                                                 p_share_type gicl_reserve_ds.share_type%TYPE,
                                                 p_peril_cd gicl_reserve_ds.peril_cd%TYPE, 
                                                 p_loss_exp VARCHAR2,
                                                 p_clm_stat_cd VARCHAR2 default  null)
RETURN NUMBER
IS
   v_amount NUMBER;
   v_exist  VARCHAR2(10);
BEGIN  
IF p_clm_stat_cd = 'CC' OR p_clm_stat_cd = 'DN' OR p_clm_stat_cd = 'WD' THEN
          v_amount := 0;
        ELSE
            BEGIN
                SELECT DISTINCT 'x'
                   INTO v_exist
                   FROM gicl_clm_res_hist
                WHERE tran_id IS NOT NULL
                   AND NVL (cancel_tag, 'N') = 'N'
                   AND claim_id = p_claim_id
                   AND peril_cd = p_peril_cd;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                   v_exist := NULL;
            END;

            --get amount per type (Loss or Expense)
            IF v_exist IS NOT NULL
         THEN
            FOR p IN (SELECT NVL (SUM (c.convert_rate * shr_le_net_amt),
                                  0
                                 ) paid
                        FROM gicl_clm_loss_exp a,
                             gicl_loss_exp_ds b,
                             gicl_advice c
                       WHERE a.claim_id = b.claim_id
                         AND a.clm_loss_id = b.clm_loss_id
                         AND a.claim_id = c.claim_id
                         AND a.advice_id = c.advice_id
                         AND b.claim_id = p_claim_id
                         AND b.peril_cd = p_peril_cd
                         AND a.tran_id IS NOT NULL
                         AND NVL (b.negate_tag, 'N') = 'N'
                         AND b.share_type = p_share_type
                         AND a.payee_type = DECODE (p_loss_exp,
                                                    'E', 'E',
                                                    'L'
                                                   ))
            LOOP
               v_amount := p.paid;
            END LOOP;
         ELSE
            FOR r IN (SELECT DECODE (p_loss_exp,
                                     'E', NVL (SUM (  b.convert_rate
                                                    * a.shr_exp_res_amt
                                                   ),
                                               0
                                              ),
                                     NVL (SUM (  b.convert_rate
                                               * a.shr_loss_res_amt
                                              ),
                                          0
                                         )
                                    ) reserve
                        FROM gicl_reserve_ds a, gicl_clm_res_hist b
                       WHERE a.claim_id = b.claim_id
                         AND a.clm_res_hist_id = b.clm_res_hist_id
                         AND b.dist_sw = 'Y'
                         AND a.claim_id = p_claim_id
                         AND a.peril_cd = p_peril_cd
                         AND NVL (a.negate_tag, 'N') = 'N'
                         AND a.share_type = p_share_type)
            LOOP
               v_amount := r.reserve;
            END LOOP;
         END IF;
        END IF;
  RETURN v_amount;
EXCEPTION 
  WHEN OTHERS THEN 
  RETURN NULL;             
END; 
/

