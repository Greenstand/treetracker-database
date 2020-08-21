CREATE TEMPORARY TABLE IF NOT EXISTS new_region_data AS (SELECT * FROM import.countries);
ALTER TABLE new_region_data DROP COLUMN geom;


DELETE FROM region_type WHERE type = 'country';
INSERT INTO region_type
(type)
VALUES
('country');


INSERT INTO region
(type_id, name, metadata, geom)
SELECT region_type.id, countries.name_long, metadata, countries.geom
FROM import.countries
JOIN (
  SELECT id, row_to_json(new_region_data) as metadata
  FROM new_region_data
) metadata
ON metadata.id = countries.id
JOIN region_type
ON region_type.type = 'country';



INSERT INTO region_zoom
(region_id, zoom_level, priority)
SELECT region.id, zoom_level, 2
FROM unnest(ARRAY[1,2,3,4,5]) zoom_level
JOIN region
ON TRUE
JOIN region_type
ON region_type.id = region.type_id
WHERE region_type.type = 'country';

UPDATE region
SET centroid = ST_Centroid(geom)
WHERE centroid IS NULL;

