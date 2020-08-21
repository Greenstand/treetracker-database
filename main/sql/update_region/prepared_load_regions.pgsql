CREATE TEMPORARY TABLE new_region_data AS (SELECT * FROM import.greenstand_countries);
ALTER TABLE new_region_data DROP COLUMN geom;

DELETE from region_zoom WHERE region_id IN ( SELECT id FROM region WHERE type_id IN ( SELECT id FROM region_type WHERE type = 'country' ) );
DELETE from region WHERE type_id IN ( SELECT id FROM region_type WHERE type = 'country' );
DELETE FROM region_type WHERE type = 'country';

INSERT INTO region_type
(type)
VALUES
('country');


INSERT INTO region
(type_id, name, metadata, geom)
SELECT region_type.id, import.greenstand_countries.name, metadata, import.greenstand_countries.geom
FROM import.greenstand_countries
JOIN (
  SELECT gid, row_to_json(new_region_data) as metadata
  FROM new_region_data
) metadata
ON metadata.gid = import.greenstand_countries.gid
JOIN region_type
ON region_type.type = 'country';



INSERT INTO region_zoom
(region_id, zoom_level, priority)
SELECT region.id, zoom_level, 2
FROM unnest(ARRAY[4,5]) zoom_level
JOIN region
ON TRUE
JOIN region_type
ON region_type.id = region.type_id
WHERE region_type.type = 'country';

UPDATE region
SET centroid = ST_Centroid(geom)
WHERE centroid IS NULL;


DELETE FROM tree_region where zoom_level IN (4,5);

INSERT INTO tree_region
(tree_id, zoom_level, region_id)
SELECT DISTINCT ON (trees.id, zoom_level) trees.id AS tree_id, zoom_level, region.id
FROM trees
JOIN region
ON ST_Contains( region.geom, trees.estimated_geometric_location)
JOIN region_zoom
ON region_zoom.region_id = region.id
WHERE trees.active = true
AND region_zoom.zoom_level IN (4,5)
ORDER BY trees.id, zoom_level, region_zoom.priority DESC;

REFRESH MATERIALIZED VIEW active_tree_region;
