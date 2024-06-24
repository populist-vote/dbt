{% macro generate_office_slug(office_name, election_scope, district_type, district, school_district, hospital_district, seat, county, municipality) %}
    
CASE -- test election_scope
  -- state
  WHEN {{ election_scope }} = 'state'
  	THEN	
		slugify(concat('mn', ' ', {{ office_name }}, ' ', {{ district }}, ' ', {{ seat }}))
  -- county
  WHEN {{ election_scope }} = 'county'
  	THEN	
		slugify(concat('mn', ' ', REPLACE({{ office_name }},'&','and'), ' ', {{ county }}, ' county ', {{ district }}, ' ', {{ seat }} ))
  -- city
  WHEN {{ election_scope }} = 'city'
  	THEN
		slugify(concat('mn', ' ', REPLACE({{ office_name }},'&','and'), ' ', REPLACE({{ municipality }},'Township','Twp'), ' ', {{ county }}, ' county ', {{ school_district }}, ' ', {{ district }}, ' ', {{ seat }} ))
  -- district
  WHEN {{ election_scope }} = 'district'
  	THEN
  		CASE -- test district_types
	  		WHEN {{ district_type }} = 'county'
	  			THEN
					  slugify(concat('mn', ' ', {{ office_name }}, ' ', {{ county }}, ' county ', {{ district }}, ' ', {{ seat }} ))
			WHEN {{ district_type }} = 'city'
	  			THEN
	  			  slugify(concat('mn', ' ', REPLACE({{ office_name }},'&','and'), ' ', REPLACE({{ municipality }},'Township','Twp'), ' ', {{ county }}, ' county ', {{ district }}, ' ', {{ seat }} ))
			WHEN {{ district_type }} = 'school'
	  			THEN
					  slugify(concat('mn', ' ', {{ office_name }}, ' ', {{ school_district }}, ' ', {{ district }}, ' ', {{ seat }} ))
			WHEN {{ district_type }} = 'judicial'
				-- matches District Court Judges - don't need district in slug because it's in the name (e.g. Judge - 6th District)
				THEN
					  slugify(concat('mn', ' ', {{ office_name }}, ' ', {{ seat }} ))
			WHEN {{ district_type }} = 'hospital'
	  			THEN
	  				slugify(concat('mn', ' ', {{ office_name }}, ' ', hospital_district, ' ',{{ district }}, ' ', {{ seat }} ))
	  	WHEN {{ district_type }} = 'soil_and_water'
	  			THEN
	  				slugify(concat('mn', ' ', {{ office_name }}, ' ', {{ county }}, ' county ', {{ district }}, ' ', {{ seat }} ))
			ELSE -- us_congressional, state_house, state_senate
 				slugify(concat('mn', ' ', {{ office_name }}, ' ', {{ district }}, ' ', {{ seat }} ))
 		END
  ELSE
  	''
 END


{% endmacro %}
