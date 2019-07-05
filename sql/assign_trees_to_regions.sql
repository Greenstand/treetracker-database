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
