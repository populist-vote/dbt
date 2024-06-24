{% macro generate_office_subtitle(state, office_name, election_scope, district_type, district, school_district, hospital_district, seat, county, municipality) %}

DECLARE @subtitle AS TEXT = ''

CASE -- test election_scope
  -- state
  WHEN {{ election_scope }} = 'state'
  	THEN
		CASE
			WHEN {{ district }} is null AND {{ seat }} is null -- ignore for U.S. Senate, seat is used for Class
				THEN
					concat(@subtitle, 'Minnesota') -- use full state name
			ELSE
				CASE
					WHEN {{ district }} = number
						THEN
							concat(@subtitle, )
		-- if (district and seat = null then use full state name
		-- else use two letter abbreviation of state
		-- if district is just a number add 'District' before
		-- if name is State House add 'House District' before
		-- if name is State Senate add 'Senate District' before
		-- districts and seats 
		-- hospital district, judges, justices, school board
		-- maybe city council
		concat({{ state }}, ' - ', {{ district }}, ' ', {{ seat }}))
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
				THEN
					slugify(concat('mn', ' ', {{ office_name }}, ' ', {{ district }}, ' ', {{ seat }} ))
			WHEN {{ district_type }} = 'hospital'
	  			THEN
	  				slugify(concat('mn', ' ', {{ office_name }}, ' ', hospital_district, ' ',{{ district }}, ' ', {{ seat }} ))
	  		WHEN {{ district_type }} = 'soil_and_water'
	  			THEN
	  				slugify(concat('mn', ' ', {{ office_name }}, ' ', {{ county }}, ' county ', {{ district }}, ' ', {{ seat }} ))
			ELSE -- us_congressional, state_house, state_senate
 				slugify(concat('mn', ' ', {{ office_name }}, ' ', {{ district }}, ' ', {{ seat }} ))
 		END
  ELSE -- national
  	''
 END


{% endmacro %}
