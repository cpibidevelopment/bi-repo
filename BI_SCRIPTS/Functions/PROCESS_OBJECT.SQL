CREATE OR REPLACE PROCEDURE process_object
                            (p_name VARCHAR2,
                             p_object_type VARCHAR2,
                             p_process VARCHAR2
                            )
IS
BEGIN
    EXECUTE IMMEDIATE p_process || '  ' ||  p_object_type || ' ' || UPPER(p_name);
    DBMS_OUTPUT.PUT_LINE( p_process || '  ' ||  p_object_type || ' ' ||  p_name  || ' --Executed');
EXCEPTION
 WHEN OTHERS THEN  
    DBMS_OUTPUT.PUT_LINE( p_name   || '--Not Existing');
END; 