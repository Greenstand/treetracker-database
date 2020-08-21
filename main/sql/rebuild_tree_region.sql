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
