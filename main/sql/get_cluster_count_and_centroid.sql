SELECT region.id, centroid, count(tree_region.id)
FROM tree_region
JOIN region
ON region.id = region_id
WHERE zoom_level = 4
GROUP BY region.id;


SELECT 'cluster' AS type,
region.id, ST_ASGeoJson(region.centroid),region.type_id as region_type,
count(tree_region.id)
FROM tree_region
JOIN region
ON region.id = region_id
WHERE zoom_level = 6
AND ST_INTERSECTS(geom, ST_MakeEnvelope(48.783969511865735,8.738299267096444,25.501742949365735,-15.302830535623592, 4326))
GROUP BY region.id
