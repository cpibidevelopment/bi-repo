CREATE OR REPLACE FUNCTION BIADMIN.fnget_agent(p_claim_id NUMBER)
  RETURN VARCHAR2
  IS
     v_pol_iss_cd    gicl_claims.pol_iss_cd%TYPE;
     v_intm_name     giis_intermediary.intm_name%TYPE;
     v_intm_no       gicl_intm_itmperil.intm_no%TYPE;
     v_ref_intm_cd   giis_intermediary.ref_intm_cd%TYPE;
     v_ri_cd         gicl_claims.ri_cd%TYPE;
     v_ri_name       VARCHAR2(100);
     v_intm          VARCHAR2 (300)                       := NULL;
     var_intm        VARCHAR2 (300)                       := NULL;
  BEGIN
     FOR i IN (SELECT a.pol_iss_cd
                 FROM gicl_claims a
                WHERE a.claim_id = p_claim_id)
     LOOP
        v_pol_iss_cd := i.pol_iss_cd;
     END LOOP;

     IF v_pol_iss_cd = 'RI'
     THEN
        FOR k IN (SELECT DISTINCT g.ri_name, a.ri_cd
                             FROM gicl_claims a, giis_reinsurer  g
                            WHERE a.claim_id = p_claim_id AND a.ri_cd = g.ri_cd(+))
        LOOP
           v_intm := TO_CHAR (k.ri_cd) || '/' || k.ri_name;

           IF var_intm IS NULL
           THEN
              var_intm := v_intm;
           ELSE
              var_intm := v_intm || CHR (10) || var_intm;
           END IF;
        END LOOP;
     ELSE
        FOR j IN (SELECT DISTINCT a.intm_no, b.intm_name, b.ref_intm_cd
                             FROM gicl_intm_itmperil a, giis_intermediary b
                            WHERE a.intm_no = b.intm_no
                              AND a.claim_id = p_claim_id)
        LOOP
           v_intm :=
              TO_CHAR (j.intm_no) || '/' || j.ref_intm_cd || '/'
              || j.intm_name;

           IF var_intm IS NULL
           THEN
              var_intm := v_intm;
           ELSE
              var_intm := v_intm || CHR (10) || var_intm;
           END IF;
        END LOOP;
     END IF;

     RETURN (var_intm);
  END; 
/

