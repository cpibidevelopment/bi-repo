BEGIN
  update bi_run_log set log_end = sysdate
  where log_end is null;  
  commit;
END;
/
