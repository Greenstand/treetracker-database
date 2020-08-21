INSERT INTO tree_region
(tree_id, zoom_level, region_id)
SELECT DISTINCT ON (trees.id, zoom_level) trees.id, zoom_level, region.id
FROM trees
JOIN region
ON ST_Contains( region.geom, trees.estimated_geometric_location)
JOIN region_zoom
ON region_zoom.region_id = region.id
WHERE trees.active = true
ORDER BY priority DESC;



--- adding new zoom level

DELETE FROM region_zoom
WHERE zoom_level in (12, 13, 14, 15, 16);

INSERT INTO region_zoom
(region_id, zoom_level, priority)
SELECT region.id, zoom_level, 1
FROM unnest(ARRAY[12, 13, 14]) zoom_level
JOIN region
ON TRUE
JOIN region_type
ON region_type.id = region.type_id
WHERE region_type.type = 'grid-5000m';


DELETE FROM tree_region
WHERE zoom_level IN (12, 13, 14);

INSERT INTO tree_region
(tree_id, zoom_level, region_id)
SELECT DISTINCT ON (trees.id, zoom_level) trees.id AS tree_id, zoom_level, region.id
FROM trees
JOIN region
ON ST_Contains( region.geom, trees.estimated_geometric_location)
JOIN region_zoom
ON region_zoom.region_id = region.id
WHERE trees.active = true
AND region_zoom.zoom_level IN (12, 13, 14)
ORDER BY trees.id, zoom_level, region_zoom.priority DESC;

UPDATE region
SET centroid = ST_Centroid(geom)
WHERE centroid IS NULL;
