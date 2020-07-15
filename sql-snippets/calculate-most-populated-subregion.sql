
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


SELECT DISTINCT ON (region.id)
region.id region_id,
contained.region_id most_populated_subregion_id,
count(contained.id)
FROM
 (
  SELECT region_id, zoom_level
  FROM active_tree_region
  GROUP BY region_id, zoom_level
 ) populated_region
JOIN region
ON region.id = populated_region.region_id
JOIN active_tree_region contained
ON contained.zoom_level = populated_region.zoom_level + 2
AND ST_CONTAINS(region.geom, contained.centroid)
GROUP BY region.id, contained.region_id
ORDER BY region.id, count DESC

SELECT 
region.id region_id,
contained.region_id most_populated_subregion_id,
count(contained.id)
FROM
 (
  SELECT region_id, zoom_level
  FROM active_tree_region
  GROUP BY region_id, zoom_level
 ) populated_region
JOIN region
ON region.id = populated_region.region_id
JOIN active_tree_region contained
ON contained.zoom_level = populated_region.zoom_level + 2
AND ST_CONTAINS(region.geom, contained.centroid)
GROUP BY region.id, contained.region_id
ORDER BY region.id, count DESC

SELECT 
region.id region_id,
contained.region_id most_populated_subregion_id,
count(contained.id)
FROM
 (
  SELECT region_id, zoom_level
  FROM active_tree_region
  GROUP BY region_id, zoom_level
 ) populated_region
JOIN region
ON region.id = populated_region.region_id
JOIN active_tree_region contained
ON contained.zoom_level = populated_region.zoom_level + 2
WHERE ST_CONTAINS(region.geom, contained.centroid)
GROUP BY region.id, contained.region_id
ORDER BY region.id, count DESC

# different approach
# create a materialized view that caches all the active tree region totals by region id
# query this against the regions in the current zoom level

CREATE MATERIALIZED VIEW active_tree_region_total AS
SELECT region_id, zoom_level, count(active_tree_region.id) AS total, centroid
FROM active_tree_region
GROUP BY region_id, zoom_level, centroid



SELECT DISTINCT ON (region.id)
region.id region_id,
contained.region_id most_populated_subregion_id,
contained.total
FROM
 (
  SELECT region_id, zoom_level
  FROM active_tree_region
  WHERE zoom_level = 2
  GROUP BY region_id, zoom_level
 ) populated_region
JOIN region
ON region.id = populated_region.region_id
JOIN active_tree_region_total contained
ON contained.zoom_level = populated_region.zoom_level + 2
AND ST_CONTAINS(region.geom, contained.centroid)
ORDER BY region.id, total DESC



SELECT DISTINCT ON (region.id)
region.id region_id,
contained.region_id most_populated_subregion_id,
contained.total
FROM
 (
  SELECT region_id, zoom_level
  FROM active_tree_region
  WHERE zoom_level = 2
  GROUP BY region_id, zoom_level
 ) populated_region
JOIN region
ON region.id = populated_region.region_id
JOIN LATERAL (
  SELECT region_id, zoom_level, count(active_tree_region.id) AS total, centroid
  FROM active_tree_region
  WHERE zoom_level = 4
  GROUP BY region_id, zoom_level, centroid
) contained
ON ST_CONTAINS(region.geom, contained.centroid)
ORDER BY region.id, total DESC













