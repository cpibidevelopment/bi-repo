CREATE OR REPLACE FUNCTION BIADMIN.fget_reserve_ds(
        p_claim_id     gicl_claims.claim_id%TYPE,
        p_item_no      gicl_loss_exp_ds.item_no%TYPE,
        p_peril_cd     gicl_loss_exp_ds.peril_cd%TYPE,
        p_share_type   gicl_loss_exp_ds.share_type%TYPE,
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
            BEGIN
                SELECT DISTINCT 'x'
                  INTO v_exist
                  FROM gicl_clm_res_hist
                 WHERE tran_id IS NOT NULL
                   AND NVL (cancel_tag, 'N') = 'N'
                   AND claim_id = p_claim_id
                   AND item_no = p_item_no --considered item number
                   AND peril_cd = p_peril_cd
                  --added additional condition to check what particular type has payment
                   AND DECODE (p_loss_exp, 'E', expenses_paid, losses_paid) <> 0;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    v_exist := NULL;
            END;

            --get amount per type (Loss or Expense)
            IF v_exist IS NOT NULL THEN
                FOR p IN (SELECT SUM (c.convert_rate * NVL (shr_le_net_amt, 0)) paid
                            FROM gicl_clm_loss_exp a,
                                 gicl_loss_exp_ds b,
                                 gicl_advice c
                           WHERE a.claim_id = b.claim_id
                             AND a.clm_loss_id = b.clm_loss_id
                             AND a.claim_id = c.claim_id
                             AND a.advice_id = c.advice_id
                             AND b.claim_id = p_claim_id
                             AND b.item_no = p_item_no --considered item number
                             AND b.peril_cd = p_peril_cd
                             AND a.tran_id IS NOT NULL
                             AND NVL (b.negate_tag, 'N') = 'N'
                             AND b.share_type = p_share_type
                             AND a.payee_type = DECODE (p_loss_exp, 'L', 'L', 'E') )
                LOOP
                    v_amount := NVL(p.paid,0);
                END LOOP;
            ELSE
                FOR r IN (SELECT DECODE (p_loss_exp,
                                            'L', SUM (  b.convert_rate * NVL (a.shr_loss_res_amt, 0) ),
                                                 SUM (  b.convert_rate * NVL (a.shr_exp_res_amt, 0) )
                                        ) reserve
                            FROM gicl_reserve_ds a, gicl_clm_res_hist b
                           WHERE a.claim_id = b.claim_id
                             AND a.clm_res_hist_id = b.clm_res_hist_id
                             AND b.dist_sw = 'Y'
                             AND a.claim_id = p_claim_id
                             AND b.item_no = p_item_no --considered item number
                             AND a.peril_cd = p_peril_cd
                             AND NVL (a.negate_tag, 'N') = 'N'
                             AND a.share_type = p_share_type)
                LOOP
                v_amount := NVL(r.reserve,0);
                END LOOP;
            END IF;
        END IF;
        RETURN (v_amount);
    END; 
/

