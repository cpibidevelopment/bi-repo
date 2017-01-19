CREATE TABLE CPI.BI_TIME_DIM
(
  TIME_CODE      NUMBER(12),
  CALENDAR_DATE  DATE                           NOT NULL,
  YEAR_NO        NUMBER(4)                      NOT NULL,
  QUARTER_NO     NUMBER(1)                      NOT NULL,
  MONTH_NO       NUMBER(2)                      NOT NULL,
  MONTH_NAME     VARCHAR2(20 BYTE)              NOT NULL,
  WEEK_NO        NUMBER(1)                      NOT NULL,
  DATE_OF_MONTH  NUMBER(2)                      NOT NULL
)