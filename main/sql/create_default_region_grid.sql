-------------
-------------  Create the grid regions
-------------
INSERT INTO region_type
(type)
values
('grid-1000000m');

INSERT INTO region
(geom, type_id)
SELECT geom, region_type.id
FROM
ST_DUMP(
  makegrid_2d(
    ST_GeomFromText(
      'Polygon((-180 -60,180 -60,180 70,-180 70,-180 -60))',
      4326
    ),
     1000000, -- width step in meters
     1000000  -- height step in meters
  )
)
JOIN region_type
ON region_type.type = 'grid-1000000m';


INSERT INTO region_type
(type)
values
('grid-100000m');

INSERT INTO region
(geom, type_id)
SELECT geom, region_type.id
FROM
ST_DUMP(
  makegrid_2d(
    ST_GeomFromText(
      'Polygon((-180 -60,180 -60,180 70,-180 70,-180 -60))',
      4326
    ),
     100000, -- width step in meters
     100000  -- height step in meters
  )
)
JOIN region_type
ON region_type.type = 'grid-100000m';


INSERT INTO region_type
(type)
values
('grid-10000m');


INSERT INTO region
(geom, type_id)
SELECT geom, region_type.id
FROM
ST_DUMP(
  makegrid_2d(
    ST_GeomFromText(
      'Polygon((-180 -60,180 -60,180 70,-180 70,-180 -60))',
      4326
    ),
     10000, -- width step in meters
     10000  -- height step in meters
  )
)
JOIN region_type
ON region_type.type = 'grid-10000m';





INSERT INTO region_type
(type)
values
('grid-5000m');

-- try just africa and europe
INSERT INTO region
(geom, type_id)
SELECT ST_Multi(geom), region_type.id
FROM
ST_DUMP(
  makegrid_2d(
    ST_GeomFromText(
      'Polygon((16 -38,16 -38,61 70,61 70,16 -38))',
      4326
    ),
     5000, -- width step in meters
     5000  -- height step in meters
  )
)
JOIN region_type
ON region_type.type = 'grid-5000m';
