
# calculate results for one zoom level at a time
# or possibly bounding region will make this fast enough to do realtime

SELECT DISTINCT ON (region.id) region.id region_id,
contained.region_id most_populated_subregion, count(contained.id)
FROM
 (
  SELECT DISTINCT region_id, zoom_level
  FROM active_tree_region
  WHERE zoom_level = 2
 ) populated_region
JOIN region
ON region.id = populated_region.region_id
JOIN active_tree_region contained
ON contained.zoom_level = 2 + 2
AND ST_CONTAINS(region.geom, contained.centroid)
GROUP BY region.id, contained.region_id
ORDER BY region.id, count DESC
