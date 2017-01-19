CREATE OR REPLACE FUNCTION BIADMIN.get_renew_tag(
  /** rollie 24 june 2004
  *** validates if policy is renewed
  **/
   p_policy_id     GIPI_POLBASIC.policy_id%TYPE,
 p_pack_sw       VARCHAR2 DEFAULT 'N')
  RETURN VARCHAR2 AS
    v_renew_tag   VARCHAR2(1):= 'N';
  BEGIN
  --------------PACKAGE consideration------------
    FOR A IN (
   SELECT 'RENEWED'
     FROM GIPI_PACK_POLNREP b
    WHERE b.old_pack_policy_id = p_policy_id
      AND p_pack_sw = 'Y')
 LOOP
   v_renew_tag := 'Y';
 END LOOP;
  --------------PACKAGE end----------------------
    FOR A IN (
   SELECT 'RENEWED'
     FROM GIPI_POLNREP b
    WHERE b.old_policy_id = p_policy_id
      AND p_pack_sw = 'N')
 LOOP
   v_renew_tag := 'Y';
 END LOOP;
 RETURN (v_renew_tag);
  END; 
/

