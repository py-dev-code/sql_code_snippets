--CREATING THE WORK TABLES:
/*
DELETE FROM user_sdo_geom_metadata WHERE TABLE_NAME IN ('WORK_TABLE1','WORK_TABLE2','WORK_TABLE3');
DROP TABLE WORK_TABLE1 PURGE;
DROP TABLE WORK_TABLE2 PURGE;
DROP TABLE WORK_TABLE3 PURGE;
*/

DECLARE
    
	v_diminfo   user_sdo_geom_metadata.diminfo%TYPE;
	v_count		NUMBER;

BEGIN
    
	SELECT diminfo 
	  INTO v_diminfo 
	  FROM user_sdo_geom_metadata 
	 WHERE table_name = 'SAMPLE_TABLE' 
	   AND column_name = 'GEOMETRY';
	   
	SELECT COUNT(*) INTO v_count
	  FROM user_sdo_geom_metadata
	 WHERE table_name = 'WORK_TABLE1'
	   AND column_name = 'GEOMETRY';
	   
    IF v_count = 0 THEN
	  INSERT INTO user_sdo_geom_metadata 
      VALUES ('WORK_TABLE1', 'GEOMETRY', v_diminfo, 26912);
	END IF;  
	
	SELECT COUNT(*) INTO v_count
	  FROM user_sdo_geom_metadata
	 WHERE table_name = 'WORK_TABLE2'
	   AND column_name = 'GEOMETRY';	
	
    IF v_count = 0 THEN
	  INSERT INTO user_sdo_geom_metadata 
      VALUES ('WORK_TABLE2', 'GEOMETRY', v_diminfo, 26912);
	END IF;  

	SELECT COUNT(*) INTO v_count
	  FROM user_sdo_geom_metadata
	 WHERE table_name = 'WORK_TABLE3'
	   AND column_name = 'GEOMETRY';
	   
    IF v_count = 0 THEN
	  INSERT INTO user_sdo_geom_metadata 
      VALUES ('WORK_TABLE3', 'GEOMETRY', v_diminfo, 26912);
	END IF;  

   COMMIT;	
END;
/

CREATE TABLE WORK_TABLE1
  (qtr			VARCHAR2(1),
   geometry		mdsys.sdo_geometry
  );
  
CREATE INDEX WORK_TABLE1_idx ON WORK_TABLE1(geometry) indextype IS mdsys.spatial_index;  

CREATE TABLE WORK_TABLE2
  (qtr			VARCHAR2(1),
   geometry		mdsys.sdo_geometry
  );
  
CREATE INDEX WORK_TABLE2_idx ON WORK_TABLE2(geometry) indextype IS mdsys.spatial_index;  

CREATE TABLE WORK_TABLE3
  (qtr			VARCHAR2(1),
   geometry		mdsys.sdo_geometry
  );

CREATE OR REPLACE  PROCEDURE CADASTRAL_CALCULATION
							  (p_latitude		IN	NUMBER,
  							   p_longitude		IN	NUMBER,
  							   p_county			OUT	VARCHAR2,
  							   p_city			OUT VARCHAR2,
  							   p_zip			OUT	VARCHAR2,
  							   p_quadrant		OUT	VARCHAR2,
  							   p_township		OUT	NUMBER,
  							   p_range			OUT	NUMBER,
  							   p_section		OUT	VARCHAR2,
  							   p_quarter1		OUT	VARCHAR2,
  							   p_quarter2		OUT	VARCHAR2,
  							   p_quarter3		OUT	VARCHAR2,
  							   p_err_code		OUT	VARCHAR2,
  							   p_err_msg		OUT	VARCHAR2) IS  

	v_lat				NUMBER;
	v_long				NUMBER;

	v_section 			VARCHAR2(10);
	v_township			VARCHAR2(10);
	v_range				VARCHAR2(10);  

	v_quarter1			VARCHAR2(1);
	v_quarter2			VARCHAR2(1);
	v_quarter3			VARCHAR2(1);  

	v_sec_pnt1_x		NUMBER;
	v_sec_pnt1_y		NUMBER;
	v_sec_pnt2_x		NUMBER;
	v_sec_pnt2_y		NUMBER;
	v_sec_pnt3_x		NUMBER;
	v_sec_pnt3_y		NUMBER;
	v_sec_pnt4_x		NUMBER;
	v_sec_pnt4_y		NUMBER;

	v_qtr1_pnt1_x		NUMBER;
	v_qtr1_pnt1_y		NUMBER;
	v_qtr1_pnt2_x		NUMBER;
	v_qtr1_pnt2_y		NUMBER;
	v_qtr1_pnt3_x		NUMBER;
	v_qtr1_pnt3_y		NUMBER;
	v_qtr1_pnt4_x		NUMBER;
	v_qtr1_pnt4_y		NUMBER;

	v_qtr2_pnt1_x		NUMBER;
	v_qtr2_pnt1_y		NUMBER;
	v_qtr2_pnt2_x		NUMBER;
	v_qtr2_pnt2_y		NUMBER;
	v_qtr2_pnt3_x		NUMBER;
	v_qtr2_pnt3_y		NUMBER;
	v_qtr2_pnt4_x		NUMBER;
	v_qtr2_pnt4_y		NUMBER;  

  BEGIN

	v_sb_prg := 'gis_get_cadastrals';
	v_parameters := 'p_latitude: ' || p_latitude || ', p_longitude: ' || p_longitude;
	
	v_lat := p_latitude;
	v_long := p_longitude;
	
	--Fetching the County, City and ZIP for given lat long.
	BEGIN
	  SELECT c.name
		INTO p_county
	    FROM COUNTY_TABLE c 
	   WHERE sdo_relate(c.geometry, 
						sdo_cs.transform(sdo_geometry(2001,4326,sdo_point_type(v_long, v_lat, NULL),NULL,NULL),26912), 
						'mask=contains querytype=WINDOW') = 'TRUE';
	EXCEPTION
	  WHEN no_data_found THEN
	    p_err_code := 'LOCI_NOT_IN_AZ';
		p_err_msg := 'Given Latitude and Longitude are not in ARIZONA.';
		RETURN;
	END;
	
	BEGIN	
	  SELECT c.name 
		INTO p_city	  
	    FROM CITY_TABLE c 
	   WHERE sdo_relate(c.geometry, 
						sdo_cs.transform(sdo_geometry(2001,4326,sdo_point_type(v_long, v_lat, NULL),NULL,NULL),26912), 
						'mask=contains querytype=WINDOW') = 'TRUE';
	EXCEPTION
	  WHEN no_data_found THEN
		BEGIN
		  SELECT UPPER(z.po_name)
			INTO p_city
			FROM ZIP_CODE_TABLE z 
		   WHERE sdo_relate(z.geometry, 
							sdo_cs.transform(sdo_geometry(2001,4326,sdo_point_type(v_long, v_lat, NULL),NULL,NULL),26912), 
							'mask=contains querytype=WINDOW') = 'TRUE';	
		EXCEPTION
		  WHEN no_data_found THEN
			p_city := NULL;
		END;	
	END;
	
	BEGIN
	  SELECT z.zip_code 
		INTO p_zip
	    FROM ZIP_CODE_TABLE z 
	   WHERE sdo_relate(z.geometry, 
						sdo_cs.transform(sdo_geometry(2001,4326,sdo_point_type(v_long, v_lat, NULL),NULL,NULL),26912), 
						'mask=contains querytype=WINDOW') = 'TRUE';
	
	EXCEPTION
	  WHEN NO_DATA_FOUND THEN
	    p_zip := NULL;
	END;	

	--Fetching the Township, Range and Section for given Lat Long
	SELECT ttext, rtext, section 
      INTO v_township, v_range, v_section
      FROM SECTION_TABLE s 
     WHERE sdo_relate(s.geometry, sdo_cs.transform(sdo_geometry(2001,4326,sdo_point_type(v_long, v_lat,null),null,null),26912), 'mask=contains querytype=WINDOW') = 'TRUE';
	 
	--If section is LG then its an unmapped location for cadastral so we will return Unmapped location 
	IF v_section = 'LG' THEN
	  p_quadrant := 'UNMAPPED LOCATION';
	  p_err_code := '000';
	  p_err_msg := 'SUCCESS';
	  RETURN;
	END IF;

	--Calculating the Quadrant
	p_quadrant := CASE SUBSTR(v_township,-1)||SUBSTR(v_range,-1)
				    WHEN 'NE' THEN 'A'
				    WHEN 'NW' THEN 'B'
				    WHEN 'SW' THEN 'C'
				    WHEN 'SE' THEN 'D'
				    ELSE NULL
				  END;

	--this will extract number from the string including decimal
	SELECT REPLACE(v_township, regexp_replace(v_township, '[^A-Za-z]', ''), NULL) INTO p_township FROM dual;
	SELECT REPLACE(v_range, regexp_replace(v_range, '[^A-Za-z]', ''), NULL) INTO p_range FROM dual;

	FOR r IN (SELECT t.X, t.Y, t.id
			    FROM TABLE(SELECT sdo_util.getvertices(SDO_AGGR_MBR(s.geometry)) 
						     FROM gis_trs s
						    WHERE sdo_relate(s.geometry, 
										     sdo_cs.transform(sdo_geometry(2001,4326,sdo_point_type(v_long, v_lat,null),null,null),26912), 
										     'mask=contains querytype=WINDOW') = 'TRUE') t)				
	LOOP						   
	  IF r.id = 1 THEN

		v_sec_pnt1_x := r.x;
		v_sec_pnt1_y := r.y;

		v_sec_pnt2_y := r.y;
		v_sec_pnt4_x := r.x;
	  END IF;

	  IF r.id = 2 THEN
		v_sec_pnt3_x := r.x;
		v_sec_pnt3_y := r.y;	  

		v_sec_pnt2_x := r.x;
		v_sec_pnt4_y := r.y;
	  END IF;
	END LOOP;	  

	  /*
	  --Below function will be used to create a Rectangle Geometry object
	  SDO_GEOMETRY(
		2003,  -- two-dimensional polygon
		26912,  --SGRID TYPE
		NULL,  --POINT TYPE
		SDO_ELEM_INFO_ARRAY(1,1003,3), -- one rectangle (1003 = exterior)
		SDO_ORDINATE_ARRAY(1,1, 5,7) -- only 2 points needed to define rectangle (lower left and upper right) with Cartesian-coordinate data
	  )*/

	--Creating the Geometries for Quarter1 Recatngle for area covering upto 160 acres
	INSERT INTO WORK_TABLE1
	VALUES ('a', sdo_geometry(2003, 26912, null, sdo_elem_info_array(1,1003,3), 
							  sdo_ordinate_array((v_sec_pnt1_x + (v_sec_pnt3_x-v_sec_pnt1_x)/2), (v_sec_pnt1_y + (v_sec_pnt3_y-v_sec_pnt1_y)/2), 
												  v_sec_pnt3_x, v_sec_pnt3_y)));
	INSERT INTO WORK_TABLE1
	VALUES ('b', sdo_geometry(2003, 26912, null, sdo_elem_info_array(1,1003,3), 
							  sdo_ordinate_array(v_sec_pnt1_x, (v_sec_pnt1_y + (v_sec_pnt4_y-v_sec_pnt1_y)/2), 
											     (v_sec_pnt1_x + (v_sec_pnt3_x-v_sec_pnt1_x)/2), v_sec_pnt3_y)));
	INSERT INTO WORK_TABLE1
	VALUES ('c', sdo_geometry(2003, 26912, null, sdo_elem_info_array(1,1003,3), 
							  sdo_ordinate_array(v_sec_pnt1_x, v_sec_pnt1_y, 
											     (v_sec_pnt1_x + (v_sec_pnt3_x-v_sec_pnt1_x)/2), (v_sec_pnt1_y + (v_sec_pnt3_y-v_sec_pnt1_y)/2))));
	INSERT INTO WORK_TABLE1
	VALUES ('d', sdo_geometry(2003, 26912, null, sdo_elem_info_array(1,1003,3), 
							  sdo_ordinate_array((v_sec_pnt1_x + (v_sec_pnt3_x-v_sec_pnt1_x)/2), v_sec_pnt2_y, 
											     v_sec_pnt3_x, (v_sec_pnt1_y + (v_sec_pnt3_y-v_sec_pnt1_y)/2))));  

	--Calculating the quarter1 value
	BEGIN
	  SELECT q1.qtr 
        INTO v_quarter1
        FROM WORK_TABLE1	q1  
	   WHERE sdo_relate(q1.geometry, sdo_cs.transform(sdo_geometry(2001,4326,sdo_point_type(v_long,v_lat,null),null,null),26912), 'mask=contains querytype=WINDOW') = 'TRUE'
		 AND q1.qtr IS NOT NULL;
	EXCEPTION
      WHEN no_data_found THEN  
	    v_quarter1 := NULL;
	END;


	--Fetching the vertices of the quarter1 to which the given lat long belongs in order to create quarter2 rectangles 
	FOR r IN (SELECT t.X, t.Y, t.id
			    FROM TABLE(SELECT sdo_util.getvertices(geometry) 
						     FROM WORK_TABLE1 
						    WHERE qtr = v_quarter1) t)
	LOOP						   
	  IF r.id = 1 THEN
	    v_qtr1_pnt1_x := r.x;
		v_qtr1_pnt1_y := r.y;
		v_qtr1_pnt2_y := r.y;
		v_qtr1_pnt4_x := r.x;
	  END IF;

	  IF r.id = 2 THEN
		v_qtr1_pnt2_x := r.x;
		v_qtr1_pnt3_x := r.x;
		v_qtr1_pnt3_y := r.y;
		v_qtr1_pnt4_y := r.y;
	  END IF;
	END LOOP;	

	--Creating the Geometries for Quarter2 Recatngle for area covering upto 40 acres  
	INSERT INTO WORK_TABLE2
	VALUES ('a', sdo_geometry(2003, 26912, null, sdo_elem_info_array(1,1003,3), 
							  sdo_ordinate_array((v_qtr1_pnt1_x + (v_qtr1_pnt3_x-v_qtr1_pnt1_x)/2), (v_qtr1_pnt1_y + (v_qtr1_pnt3_y-v_qtr1_pnt1_y)/2), 
												  v_qtr1_pnt3_x, v_qtr1_pnt3_y)));
	INSERT INTO WORK_TABLE2
	VALUES ('b', sdo_geometry(2003, 26912, null, sdo_elem_info_array(1,1003,3), 
							  sdo_ordinate_array(v_qtr1_pnt1_x, (v_qtr1_pnt1_y + (v_qtr1_pnt4_y-v_qtr1_pnt1_y)/2), 
											     (v_qtr1_pnt1_x + (v_qtr1_pnt3_x-v_qtr1_pnt1_x)/2), v_qtr1_pnt3_y)));
	INSERT INTO WORK_TABLE2
	VALUES ('c', sdo_geometry(2003, 26912, null, sdo_elem_info_array(1,1003,3), 
							  sdo_ordinate_array(v_qtr1_pnt1_x, v_qtr1_pnt1_y, 
											     (v_qtr1_pnt1_x + (v_qtr1_pnt3_x-v_qtr1_pnt1_x)/2), (v_qtr1_pnt1_y + (v_qtr1_pnt3_y-v_qtr1_pnt1_y)/2))));
	INSERT INTO WORK_TABLE2
	VALUES ('d', sdo_geometry(2003, 26912, null, sdo_elem_info_array(1,1003,3), 
							  sdo_ordinate_array((v_qtr1_pnt1_x + (v_qtr1_pnt3_x-v_qtr1_pnt1_x)/2), v_qtr1_pnt2_y, 
											     v_qtr1_pnt3_x, (v_qtr1_pnt1_y + (v_qtr1_pnt3_y-v_qtr1_pnt1_y)/2))));   

	--Calculating the quarter2 value
	BEGIN
	  SELECT q2.qtr 
		INTO v_quarter2
        FROM WORK_TABLE2	q2
       WHERE sdo_relate(q2.geometry, sdo_cs.transform(sdo_geometry(2001,4326,sdo_point_type(v_long,v_lat,null),null,null),26912), 'mask=contains querytype=WINDOW') = 'TRUE';
    EXCEPTION
      WHEN no_data_found THEN  
	    v_quarter2 := NULL;
	END; 

	--Fetching the vertices of the quarter2 to which the given lat long belongs in order to create quarter3 rectangles 
	FOR r IN (SELECT t.X, t.Y, t.id
			    FROM TABLE(SELECT sdo_util.getvertices(geometry) 
						     FROM WORK_TABLE2 
						    WHERE qtr = v_quarter2) t)
	LOOP						   
	  IF r.id = 1 THEN
		v_qtr2_pnt1_x := r.x;
		v_qtr2_pnt1_y := r.y;
		v_qtr2_pnt2_y := r.y;
		v_qtr2_pnt4_x := r.x;
	  END IF;

	  IF r.id = 2 THEN
		v_qtr2_pnt2_x := r.x;
		v_qtr2_pnt3_x := r.x;
		v_qtr2_pnt3_y := r.y;
		v_qtr2_pnt4_y := r.y;
	  END IF;
	END LOOP;	  

	--Creating the Geometries for Quarter3 Recatngle for area covering upto 10 acres  
	INSERT INTO WORK_TABLE3
	VALUES ('a', sdo_geometry(2003, 26912, null, sdo_elem_info_array(1,1003,3), 
							  sdo_ordinate_array((v_qtr2_pnt1_x + (v_qtr2_pnt3_x-v_qtr2_pnt1_x)/2), (v_qtr2_pnt1_y + (v_qtr2_pnt3_y-v_qtr2_pnt1_y)/2), 
												  v_qtr2_pnt3_x, v_qtr2_pnt3_y)));
	INSERT INTO WORK_TABLE3
	VALUES ('b', sdo_geometry(2003, 26912, null, sdo_elem_info_array(1,1003,3), 
							  sdo_ordinate_array(v_qtr2_pnt1_x, (v_qtr2_pnt1_y + (v_qtr2_pnt4_y-v_qtr2_pnt1_y)/2), 
											     (v_qtr2_pnt1_x + (v_qtr2_pnt3_x-v_qtr2_pnt1_x)/2), v_qtr2_pnt3_y)));
	INSERT INTO WORK_TABLE3
	VALUES ('c', sdo_geometry(2003, 26912, null, sdo_elem_info_array(1,1003,3), 
							  sdo_ordinate_array(v_qtr2_pnt1_x, v_qtr2_pnt1_y, 
											     (v_qtr2_pnt1_x + (v_qtr2_pnt3_x-v_qtr2_pnt1_x)/2), (v_qtr2_pnt1_y + (v_qtr2_pnt3_y-v_qtr2_pnt1_y)/2))));
	INSERT INTO WORK_TABLE3
	VALUES ('d', sdo_geometry(2003, 26912, null, sdo_elem_info_array(1,1003,3), 
							  sdo_ordinate_array((v_qtr2_pnt1_x + (v_qtr2_pnt3_x-v_qtr2_pnt1_x)/2), v_qtr2_pnt2_y, 
											     v_qtr2_pnt3_x, (v_qtr2_pnt1_y + (v_qtr2_pnt3_y-v_qtr2_pnt1_y)/2))));  

	--Calculating the quarter3 value
	BEGIN
	  SELECT q3.qtr 
        INTO v_quarter3
        FROM WORK_TABLE3	q3
       WHERE sdo_relate(q3.geometry, sdo_cs.transform(sdo_geometry(2001,4326,sdo_point_type(v_long,v_lat,null),null,null),26912), 'mask=contains querytype=WINDOW') = 'TRUE';
    EXCEPTION
      WHEN no_data_found THEN  
	    v_quarter3 := NULL;
	END; 

	p_section := v_section;
	p_quarter1 := v_quarter1;
	p_quarter2 := v_quarter2;
	p_quarter3 := v_quarter3;
	
	DELETE FROM WORK_TABLE1;
	DELETE FROM WORK_TABLE2;
	DELETE FROM WORK_TABLE3;	
	COMMIT;

    p_err_code := '000';
    p_err_msg  := 'SUCCESS';

  EXCEPTION
    WHEN OTHERS THEN
	  ROLLBACK;      
  END CADASTRAL_CALCULATION;
  /