UPDATE region
SET centroid = ST_Centroid(gemo)
WHERE centroid IS NULL;
