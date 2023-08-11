SELECT DISTINCT ON (o.id)
  f.municipality,
  f.school_district,
  f.district,
  f.district_type,
  f.num_elect,
  f.is_special_election,
  f.election_scope,
  office_title_raw,
  office_title,
  o.id as office_id,
  r.id as race_id
FROM {{ ref('mn_local_filings') }} f
LEFT JOIN
  office AS o
  ON 
    o.title = office_title AND o.state = 'MN'
    AND (o.municipality = SUBSTRING(office_title, '\(([^0-9]*)\)')
    OR o.district
    = REPLACE(
      SUBSTRING(office_title, 'Ward [0-9]{1,3} | District [0-9]{1,3}'),
      'District ',
      ''
    )
    OR o.school_district
    = SUBSTRING(office_title, 'ISD #[0-9]{2,4}|SSD #[0-9]{1,4}'))
  OR o.slug
  = SLUGIFY(CONCAT(office_title, ' ', f.municipality, ' ', 'mn', ' ', f.district, ' ', f.school_district))
 LEFT JOIN 
   race AS r
   ON r.office_id = o.id AND r.election_id = (
     SELECT id
     FROM election
     WHERE slug = 'mn-general-election-2023'
     LIMIT 1
   )
  
WHERE r.id IS NULL