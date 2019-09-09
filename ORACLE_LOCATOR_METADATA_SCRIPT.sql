/*
This script will explain how to see the metadata of a SDO_GEOMETRY type column. We need this metadata to be inserted in USER_SDO_GEOM_METADATA view in order to create 
Spatial Index on Geometry columns. Without having Spatial Index, we cannot run Location Queries on this column.
*/

--First, get the metadata of a Geometry column that is available.
select diminfo from user_sdo_geom_metadata where table_name = 'TABLE_NAME';
--MDSYS.SDO_DIM_ARRAY([MDSYS.SDO_DIM_ELEMENT], [MDSYS.SDO_DIM_ELEMENT], [MDSYS.SDO_DIM_ELEMENT])

--Now, metadata is of Type sdo_dim_array which is a table of sdo_dim_element type which is an object of 4 columns. Definitions below:
Create Type SDO_DIM_ARRAY as VARRAY(4) of SDO_DIM_ELEMENT; --Mostly, this means that Oracle Locator can handle 4 Dimensions [Not at all sure but].
Create Type SDO_DIM_ELEMENT as OBJECT (
  SDO_DIMNAME VARCHAR2(64),
  SDO_LB NUMBER,
  SDO_UB NUMBER,
  SDO_TOLERANCE NUMBER);
  
--If we want to insert the same metadata into an another Database table (say in UAT by checking the details in QA) then following script will extract the details of this metadata.

declare
  v_dim_array sdo_dim_array;
  v_dim_element sdo_dim_element;
begin
  select diminfo into v_dim_array from user_sdo_geom_metadata where table_name = 'TABLE_NAME';  
  for i in v_dim_array.first .. v_dim_array.last
  loop
    dbms_output.put_line(i);
    v_dim_element := v_dim_array(i);
    dbms_output.put_line(v_dim_element.SDO_DIMNAME||'   '||v_dim_element.SDO_LB||'   '||
    v_dim_element.SDO_UB||'    '||v_dim_element.SDO_TOLERANCE);
    dbms_output.put_line('#########################');
  end loop;  
end;
/
--Output:
1
X   141388.40500000026   687370.3134000003    .05
#########################
2
Y   3466495.2523999996   4099066.4134    .05
#########################
3
M   0   719.0285000000003    .05
#########################

--Once we have this printed, we can create the type and insert it into anywhere.
INSERT INTO user_sdo_geom_metadata 
VALUES ('TABLE_NAME', 'GEOMETRY', 
sdo_dim_array(sdo_dim_element('X',141388.40500000026,687370.3134000003,.05), 
              sdo_dim_element('Y',3466495.2523999996,4099066.4134,.05), 
              sdo_dim_element('M',0,719.0285000000003,.05))
, 26912);  

--Awesome, isn't it?


