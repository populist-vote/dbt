{% macro generate_office_subtitle(state, office_name, election_scope, district_type, district, school_district, hospital_district, seat, county, municipality) %}

CASE -- test election_scope
	WHEN {{ election_scope }} = 'state' THEN
		CASE	
			WHEN {{ office_name }} = 'U.S. Senate' OR ({{ district }} IS null AND {{ seat }} IS null) THEN 
			-- use full state name when there is no district or seat, or if U.S. Senate
				SELECT name FROM us_states WHERE code ILIKE {{ state }}
				-- 'Minnesota'
			WHEN {{ seat }} ILIKE '%At Large%' THEN
				concat({{ state }}, ' - ', {{ seat }})
			ELSE
				concat({{ state }}, ' - Seat ', {{ seat }})
		END
	WHEN {{ election_scope }} = 'county' THEN
		CASE
			WHEN {{ district }} IS null THEN
				concat({{ county }}, ' County, ', {{ state }})
			ELSE
				concat({{ county }}, ' County, ', {{ state }}, ' - District ', {{ district }})
		END
	WHEN {{ election_scope }} = 'city' THEN
		CASE -- this list of municipalities have dupes so must add the county
			WHEN {{ municipality }} IN ('Beaver Township', 'Becker Township', 'Clover Township', 
										'Cornish Township', 'Fairview Township', 'Hillman Township', 
										'Lawrence Township', 'Long Lake Township', 'Louisville Township', 
										'Moose Lake Township', 'Stokes Township', 'Twin Lakes Township') THEN
				concat(
					{{ municipality }}, 
					' - ', 
					{{ county }}, 
					' County, ', 
					{{ state }},
					CASE
						WHEN {{ seat }} IS null THEN ''
						WHEN {{ seat }} ILIKE '%At Large%' THEN ' - ' || {{ seat }}
						ELSE ' - Seat ' || {{ seat }}
					END
				)
			ELSE
				concat(
					{{ municipality }}, 
					', ', 
					{{ state }},
					CASE
						WHEN {{ seat }} IS null THEN ''
						WHEN {{ seat }} ILIKE '%At Large%' THEN ' - ' || {{ seat }}
						ELSE ' - Seat ' || {{ seat }}
					END
				)
		END
	WHEN {{ election_scope }} = 'district' THEN
		CASE -- test district_types
	  		WHEN {{ district_type }} = 'us_congressional' THEN concat({{ state }}, ' - District ', {{ district }})
			WHEN {{ district_type }} = 'state_house' THEN concat({{ state }}, ' - House District ', {{ district }})
			WHEN {{ district_type }} = 'state_senate' THEN concat({{ state }}, ' - Senate District ', {{ district }})
			WHEN {{ district_type }} = 'county' THEN concat({{ county }}, ' County, ', {{ state }}, ' - District ', {{ district }})
			
			WHEN {{ district_type }} = 'city' THEN
				CASE -- any numbers mean add 'District' before it, otherwise add whatever is in District (no offices with seats here)
					WHEN {{ district }} ~ '^\d+$' THEN concat({{ municipality }}, ', ', {{ state }}, ' - District ', {{ district }})
					ELSE concat({{ municipality }}, ', ', {{ state }}, ' - ', {{ district }})
				END

			WHEN {{ district_type }} = 'school' THEN
				CASE -- tests if District exists, and then tests if Seat exists for each case
					WHEN {{ district }} IS null THEN
					-- e.g. "MN - ISD #508 - At Large"
						concat(
							{{ state }}, 
							' - ', 
							{{ school_district }},
							CASE
								WHEN {{ seat }} IS null THEN ''
								WHEN {{ seat }} ILIKE '%At Large%' THEN ' - ' || {{ seat }}
								ELSE ' - Seat ' || {{ seat }}
							END
						)
					WHEN {{ district }} ~ '^\d+$' THEN
					-- e.g. "MN - ISD #709 - District 3"
						concat(
							{{ state }}, 
							' - ', 
							{{ school_district }},
							' - District ', 
							{{ district }},
							CASE
								WHEN {{ seat }} IS null THEN ''
								WHEN {{ seat }} ILIKE '%At Large%' THEN ' - ' || {{ seat }}
								ELSE ' - Seat ' || {{ seat }}
							END
						)
					ELSE
					-- e.g. "MN - ISD #2365 - Gibbon District"
						concat(
							{{ state }}, 
							' - ', 
							{{ school_district }},
							' - ', 
							{{ district }},
							CASE
								WHEN {{ seat }} IS null THEN ''
								WHEN {{ seat }} ILIKE '%At Large%' THEN ' - ' || {{ seat }}
								ELSE ' - Seat ' || {{ seat }}
							END
						)
				END

			WHEN {{ district_type }} = 'judicial' THEN concat({{ state }}, ' - Seat ', {{ seat }})

			WHEN {{ district_type }} = 'hospital' THEN
				CASE 
					WHEN {{ district }} IS null THEN
					-- e.g. "Canby Community - At Large"
						concat(
							{{ hospital_district }},
							CASE
								WHEN {{ seat }} IS null THEN ''
								WHEN {{ seat }} ILIKE '%At Large%' THEN ' - ' || {{ seat }}
								ELSE ' - Seat ' || {{ seat }}
							END
						)
					WHEN {{ district }} ~ '^\d+$' THEN
					-- e.g. "Cook County - District 1"
						concat(
							{{ hospital_district }},
							' - District ',
							{{ district }},
							CASE
								WHEN {{ seat }} IS null THEN ''
								WHEN {{ seat }} ILIKE '%At Large%' THEN ' - ' || {{ seat }}
								ELSE ' - Seat ' || {{ seat }}
							END
						)
				END

	  		WHEN {{ district_type }} = 'soil_and_water' THEN concat({{ county }}, ' County, ', {{ state }}, ' - District ', {{ district }})
	  				
			ELSE
 				null
 		END

 	ELSE -- national
  		null
 END

{% endmacro %}
