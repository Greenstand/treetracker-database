SELECT
  ST_ASGeoJson(centroid)
FROM
  active_tree_region
WHERE 
  zoom_level = 8
ORDER BY
  active_tree_region.centroid <->
  ST_SetSRID(ST_MakePoint(-71.1043443253471, 42.3150676015829),4326)
LIMIT 1;


SELECT
  ST_ASGeoJson(centroid)
FROM
  active_tree_region
WHERE 
  zoom_level = $zoom_level
ORDER BY
  active_tree_region.centroid <->
  ST_SetSRID(ST_MakePoint($longitude, $latitude),4326)
LIMIT 1;



SELECT
  ST_ASGeoJson(location)
FROM
  clusters
ORDER BY
  location <->
  ST_SetSRID(ST_MakePoint(-71.1043443253471, 42.3150676015829),4326)
LIMIT 1;
