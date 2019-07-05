CREATE TEMPORARY TABLE IF NOT EXISTS new_region_data AS (SELECT * FROM countries);
ALTER TABLE new_region_data DROP COLUMN geom;

INSERT INTO region_type
(type)
VALUES
('country');


ALTER TABLE region ALTER COLUMN geom type geometry(MultiPolygon, 4326) using ST_Multi(geom);


INSERT INTO region
(type_id, name, metadata, geom)
SELECT region_type.id, countries.name_long, metadata, countries.geom
FROM countries
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


-----------

DELETE FROM tree_region
WHERE zoom_level IN (1,2,3,4,5);

INSERT INTO tree_region
(tree_id, zoom_level, region_id)
SELECT DISTINCT ON (trees.id, zoom_level) trees.id AS tree_id, zoom_level, region.id
FROM trees
JOIN region
ON ST_Contains( region.geom, trees.estimated_geometric_location)
JOIN region_zoom
ON region_zoom.region_id = region.id
WHERE trees.active = true
AND region_zoom.zoom_level IN (1,2,3,4,5)
ORDER BY trees.id, zoom_level, region_zoom.priority DESC;
