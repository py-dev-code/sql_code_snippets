select regexp_substr('SMITH,ALLEN,WARD,JONES','[^,]+', 1, level) from dual
  connect by regexp_substr('SMITH,ALLEN,WARD,JONES', '[^,]+', 1, level) is not null; 