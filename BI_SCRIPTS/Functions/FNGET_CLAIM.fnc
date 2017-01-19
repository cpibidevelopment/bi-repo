CREATE OR REPLACE FUNCTION BIADMIN.FNGET_CLAIM(
        p_claim_id     gicl_claims.claim_id%TYPE,
        p_item_no      gicl_loss_exp_ds.item_no%TYPE,
        p_peril_cd     gicl_loss_exp_ds.peril_cd%TYPE,
        p_loss_exp     VARCHAR2,
        p_clm_stat_cd  gicl_claims.clm_stat_cd%TYPE
    )
        RETURN NUMBER
    IS
        v_amount       gicl_reserve_ds.shr_loss_res_amt%TYPE := 0;
        v_exist        VARCHAR2 (1);
    BEGIN
        IF p_clm_stat_cd = 'CC' OR p_clm_stat_cd = 'DN' OR p_clm_stat_cd = 'WD' THEN
            v_amount := 0;
        ELSE
            FOR i IN (SELECT DISTINCT 1
                        FROM gicl_clm_res_hist
                       WHERE tran_id IS NOT NULL
                         AND NVL(cancel_tag,'N') = 'N' 
                         AND claim_id = p_claim_id
                         AND item_no = p_item_no --considered item number by MAC 11/09/2012.
                         AND peril_cd = p_peril_cd
                         and decode(p_loss_exp,'E',expenses_paid,losses_paid) <> 0)
                          --AND TRUNC(date_paid) BETWEEN p_start_dt AND p_end_dt) jen.20121025
            LOOP
                v_exist := 'Y';
            EXIT;
            END LOOP;
                 
        /*Modified by: Jen.20121029 
        ** Get the paid amt if claim has payment, else get the reserve amount.*/
            FOR p IN (SELECT SUM(DECODE (NVL (cancel_tag, 'N'),
                                     'N', DECODE (tran_id,
                                                  NULL, DECODE(p_loss_exp, 'E',NVL (convert_rate * expense_reserve, 0),
                                                               NVL (convert_rate * loss_reserve, 0)), 
                                                  DECODE(p_loss_exp, 'E',NVL (convert_rate * expenses_paid, 0),
                                                         NVL (convert_rate * losses_paid, 0))),
                                     DECODE(p_loss_exp, 'E',NVL (convert_rate * expense_reserve, 0),
                                            NVL (convert_rate * loss_reserve, 0)))) paid
                        FROM gicl_clm_res_hist
                       WHERE claim_id = p_claim_id 
                         AND item_no = p_item_no --considered item number by MAC 11/09/2012.
                         AND peril_cd = p_peril_cd 
                         AND NVL(dist_sw,'!') = DECODE (v_exist, NULL, 'Y',NVL(dist_sw,'!'))               
                         AND NVL(tran_id,-1) = DECODE (v_exist, 'Y', tran_id, -1))               
            LOOP
                v_amount :=  NVL(p.paid,0);
            END LOOP;
        END IF;
        RETURN (v_amount);
    END; 
/

