whenever sqlerror exit sql.sqlcode

set echo     off
set feedback off
set verify   off
set heading  off
set termout  off
set timing   off
set trimspool on

set pagesize   0
set linesize 320

define p_period   = '&1'
define p_filename = '&2'

set pagesize 20000
set linesize 300
set newpage 0

spool &p_filename

select /*+ PARALLEL(VTSREG_DTV 4) */ ACCT_PERIOD||'|'||TAXED_GEO_STATE||'|'||TAXED_GEO_COUNTY||'|'||TAXED_GEO_CITY||'|'||DIVISION_CODE||'|'||TRANSACTION_DATE||'|'||INV_GROSS_AMT||'|'||INV_TOTAL_TAX||'|'||INV_COMBINED_RATE||'|'||CUSTOMER_ID||'|'||TRANS_TAXED_GEO_FLAG||'|'||TRANS_TYPE||'|'||SUB_TYPE||'|'||TRANS_CD||'|'||PROD_CODE||'|'||PROD_EXEMPT_FLAG||'|'||PROD_EXTD_AMT||'|'||TAX_BASIS||'|'||VIRTUAL_PRODUCT||'|'||ST_TAXED_AMT||'|'||ST_NON_TAXED_AMT||'|'||ST_EXEMPT_REAS_CODE||'|'||ST_EXEMPT_AMT||'|'||ST_RATE||'|'||ST_NON_TAXED_REAS_CODE||'|'||ST_TAX_TYPE||'|'||ST_TAX||'|'||CO_TAXED_AMT||'|'||CO_NON_TAXED_AMT||'|'||CO_EXEMPT_REAS_CODE||'|'||CO_EXEMPT_AMT||'|'||CO_RATE||'|'||CO_NON_TAXED_REAS_CODE||'|'||CO_TAX_TYPE||'|'||CO_TAX||'|'||CI_TAXED_AMT||'|'||CI_NON_TAXED_AMT||'|'||CI_EXEMPT_REAS_CODE||'|'||CI_EXEMPT_AMT||'|'||CI_RATE||'|'||CI_NON_TAXED_REAS_CODE||'|'||CI_TAX_TYPE||'|'||CI_TAX||'|'||DI_TAXED_AMT||'|'||DI_NON_TAXED_AMT||'|'||DI_EXEMPT_REAS_CODE||'|'||DI_EXEMPT_AMT||'|'||DI_RATE||'|'||DI_NON_TAXED_REAS_CODE||'|'||DI_TAX_TYPE||'|'||DI_TAX||'|'||TOTAL_TAX
    from  trs_mgr.vtsreg_dtv where acct_period = '&p_period';
/

spool off