CREATE OR REPLACE FUNCTION BIADMIN.fnget_claim_agent_amount (p_claim_id gicl_clm_res_hist.claim_id%TYPE, 
                                             p_loss_exp VARCHAR2, p_peril_cd VARCHAR2 , p_clm_stat_cd VARCHAR2 default null
                                            ) 
RETURN NUMBER
IS
  v_loss_amt NUMBER;
  v_exist    VARCHAR(10);
BEGIN
      IF p_clm_stat_cd = 'CC' OR p_clm_stat_cd = 'DN' OR p_clm_stat_cd = 'WD'
      THEN
         v_loss_amt := NULL;
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
            WHEN NO_DATA_FOUND
            THEN
               v_exist := NULL;
         END;

         BEGIN
            SELECT SUM (DECODE (NVL (cancel_tag, 'N'),
                                'N', DECODE (tran_id,
                                             NULL, DECODE
                                                       (p_loss_exp,
                                                        'E', NVL
                                                             (  convert_rate
                                                              * expense_reserve,
                                                              0
                                                             ),
                                                        NVL (  convert_rate
                                                             * loss_reserve,
                                                             0
                                                            )
                                                       ),
                                             DECODE (p_loss_exp,
                                                     'E', NVL (  convert_rate
                                                               * expenses_paid,
                                                               0
                                                              ),
                                                     NVL (  convert_rate
                                                          * losses_paid,
                                                          0
                                                         )
                                                    )
                                            ),
                                DECODE (p_loss_exp,
                                        'E', NVL (  convert_rate
                                                  * expense_reserve,
                                                  0
                                                 ),
                                        NVL (convert_rate * loss_reserve, 0)
                                       )
                               )
                       )
              INTO v_loss_amt
              FROM gicl_clm_res_hist
             WHERE claim_id = p_claim_id
               AND peril_cd = p_peril_cd
               AND NVL (dist_sw, '!') =
                               DECODE (v_exist,
                                       NULL, 'Y',
                                       NVL (dist_sw, '!')
                                      )
               AND NVL (tran_id, -1) = DECODE (v_exist, 'x', tran_id, -1);
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               v_loss_amt := 0;
         END;

         IF v_loss_amt IS NULL
         THEN
            RETURN (0);
         END IF;
      END IF;

      RETURN (v_loss_amt);
   END; 
/

