BEGIN
  INSERT INTO  bi_run_log values (sysdate, null);  
  commit;
END;
/
