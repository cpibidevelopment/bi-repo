SET SERVEROUTPUT ON
SET FEEDBACK  OFF  

BEGIN  
 DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------------------------'); 
 DBMS_OUTPUT.PUT_LINE('##Processing table-taken up##');
 DBMS_OUTPUT.PUT_LINE('Dropping table...');  
END;   
/


BEGIN
        process_object('BI_NOT_TAKEN_UP',  'TABLE','DROP'); 
END;        
/



CREATE TABLE BI_NOT_TAKEN_UP
AS (
  SELECT 
    a.loss_reserve, 
    a.losses_paid,
    a.expense_reserve,
    a.expenses_paid, 
    a.claim_id, 
    a.peril_cd, 
    a.agent_code,
    a.line_code,
    a.branch_code,
    a.cancel_tag,
    a.shr_pct/100 shr_pct,
    book.calendar_date BOOKING_DATE,
    paid.calendar_date PAID_DATE,
    cncl.calendar_date CANCEL_DATE,
    clos.calendar_date CLOSE_DATE,
    clos2.calendar_date CLOSE_DATE2
   FROM bi_outstanding_fact a, bi_time_dim clos, bi_time_dim clos2, bi_time_dim book, bi_time_dim paid, bi_time_dim cncl 
     WHERE a.close_date = clos.time_code(+)
     AND a.close_date2 = clos2.time_code(+)
     AND a.booking_date = book.time_code(+)
     AND a.date_paid = paid.time_code(+)
     AND a.cancel_date = cncl.time_code(+)
    -- AND NVL(book.calendar_date, '28-JAN-2016')  <= '28-JAN-2016'
    -- AND (NVL(paid.calendar_date, '28-JAN-2016')) <= '28-JAN-2016'
   --  AND DECODE (a.cancel_tag, 'Y', cncl.calendar_date, '29-JAN-2016') > '28-JAN-2016'
    -- AND (CASE WHEN (clos.calendar_date > '28-JAN-2016' OR clos.calendar_date IS NULL) THEN 1 ELSE 0 END = 1
    -- OR CASE WHEN (clos2.calendar_date > '28-JAN-2016' OR clos2.calendar_date IS NULL) THEN 1 ELSE 0 END = 1)     
     AND a.taken_up = 'N'
 --AND date_paid IS NULL
 --AND ((( CASE WHEN (b.calendar_date > '28-JAN-2016' OR b.calendar_date IS NULL) THEN  (a.loss_reserve * a.shr_pct/100) ELSE 0 END ) - (  CASE WHEN (b.calendar_date > '28-JAN-2016' OR b.calendar_date IS NULL) THEN  (a.losses_paid * a.shr_pct/100) ELSE 0 END ))
--   GROUP BY a.claim_id, a.peril_cd, a.agent_code, loss_date, file_date, claim_id, a.peril_cd, a.agent_code,
--   book.calendar_date,
--   paid.calendar_date,
--  a.cancel_tag,
--  cncl.calendar_date,
--  clos.calendar_date,
--  clos2.calendar_date
);

CREATE INDEX BI_NOT_TAKEN_UP_INDX1 ON BI_NOT_TAKEN_UP(claim_id, peril_cd, agent_code);





BEGIN      
 DBMS_OUTPUT.PUT_LINE('BI_CLAIMS_LOSSES_PAID_MV--created....');  
 END;
/









