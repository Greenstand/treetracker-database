INSERT INTO region_zoom
(region_id, zoom_level, priority)
SELECT region.id, zoom_level, 1
FROM unnest(ARRAY[1,2,3,4,5]) zoom_level
JOIN region
ON TRUE
JOIN region_type
ON region_type.id = region.type_id
WHERE region_type.type = 'grid-1000000m';


INSERT INTO region_zoom
(region_id, zoom_level, priority)
SELECT region.id, zoom_level, 1
FROM unnest(ARRAY[6,7,8]) zoom_level
JOIN region
ON TRUE
JOIN region_type
ON region_type.id = region.type_id
WHERE region_type.type = 'grid-100000m';


INSERT INTO region_zoom
(region_id, zoom_level, priority)
SELECT region.id, zoom_level, 1
FROM unnest(ARRAY[9,10,11,12,13,14]) zoom_level
JOIN region
ON TRUE
JOIN region_type
ON region_type.id = region.type_id
WHERE region_type.type = 'grid-10000m';



INSERT INTO region_zoom
(region_id, zoom_level, priority)
SELECT region.id, zoom_level, 1
FROM unnest(ARRAY[15]) zoom_level
JOIN region
ON TRUE
JOIN region_type
ON region_type.id = region.type_id
WHERE region_type.type = 'grid-5000m';
