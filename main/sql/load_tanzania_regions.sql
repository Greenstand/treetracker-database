CREATE TEMPORARY TABLE IF NOT EXISTS new_region_data AS (SELECT * FROM import.tanzania_regions);
ALTER TABLE new_region_data DROP COLUMN geom;

INSERT INTO region_type
(type)
VALUES
('tanzania_admin_regions');


-- this has bee moved into db migrations
-- ALTER TABLE region ALTER COLUMN geom type geometry(MultiPolygon, 4326) using ST_Multi(geom);


INSERT INTO region
(type_id, name, metadata, geom)
SELECT region_type.id, new_region."Region_Nam", metadata, new_region.geom
FROM import.tanzania_regions new_region
JOIN (
  SELECT id, row_to_json(new_region_data) as metadata
  FROM new_region_data
) metadata
ON metadata.id = new_region.id
JOIN region_type
ON region_type.type = 'tanzania_admin_regions';



INSERT INTO region_zoom
(region_id, zoom_level, priority)
SELECT region.id, zoom_level, 2
FROM unnest(ARRAY[6, 7]) zoom_level
JOIN region
ON TRUE
JOIN region_type
ON region_type.id = region.type_id
WHERE region_type.type = 'tanzania_admin_regions';

UPDATE region
SET centroid = ST_Centroid(geom)
WHERE centroid IS NULL;


-----------

DELETE FROM tree_region
WHERE zoom_level IN (6,7);

INSERT INTO tree_region
(tree_id, zoom_level, region_id)
SELECT DISTINCT ON (trees.id, zoom_level) trees.id AS tree_id, zoom_level, region.id
FROM trees
JOIN region
ON ST_Contains( region.geom, trees.estimated_geometric_location)
JOIN region_zoom
ON region_zoom.region_id = region.id
WHERE trees.active = true
AND region_zoom.zoom_level IN (6,7)
ORDER BY trees.id, zoom_level, region_zoom.priority DESC;
