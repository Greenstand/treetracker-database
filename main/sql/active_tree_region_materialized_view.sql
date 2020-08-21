CREATE MATERIALIZED VIEW active_tree_region
AS SELECT tree_region.id, region.id region_id, region.centroid, region.type_id, zoom_level
FROM tree_region
JOIN trees
ON trees.id = tree_region.tree_id
JOIN region
ON region.id = region_id
WHERE
trees.active = true;

CREATE INDEX active_tree_region_zoom_level_idx on active_tree_region(zoom_level);
CREATE INDEX active_tree_region_region_id_idx on active_tree_region(region_id);
