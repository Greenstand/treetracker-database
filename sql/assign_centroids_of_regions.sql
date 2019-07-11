UPDATE region
SET centroid = ST_Centroid(geom)
WHERE centroid IS NULL;
