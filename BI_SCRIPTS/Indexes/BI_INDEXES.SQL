CREATE INDEX IDX1_BI_TIME_DIM ON BI_TIME_DIM(CALENDAR_DATE) ;


BEGIN
DBMS_OUTPUT.PUT_LINE('Index created--idx1_bi_time_dim');
END;
/



CREATE INDEX bi_outstanding_Fact_idx2 on bi_outstanding_Fact(booking_Date);


BEGIN
DBMS_OUTPUT.PUT_LINE('Index created--bi_outstanding_Fact_idx2');
END;
/

CREATE INDEX bi_outstanding_Fact_idx3 on bi_outstanding_Fact(close_Date2);


BEGIN
DBMS_OUTPUT.PUT_LINE('Index created--bi_outstanding_Fact_idx3');
END;
/

create index bi_outstanding_fact_idx4  on bi_outstanding_fact(taken_up);


BEGIN
DBMS_OUTPUT.PUT_LINE('Index created--bi_outstanding_Fact_idx4');
END;
/

