#!/bin/bash

rm *.pgsql
rm *.tar.gz

echo "URL for archived pgsql shapefile export: "
read CLUSTER_REGIONS_SQL_ARCHIVE_URL

wget $CLUSTER_REGIONS_SQL_ARCHIVE_URL
#[[ $CLUSTER_REGIONS_SQL_ARCHIVE_URL =~ .*/([A-z_-]+\.tar\.gz) ]]
[[ $CLUSTER_REGIONS_SQL_ARCHIVE_URL =~ .*/(.*) ]]
echo ${BASH_REMATCH[1]}

FILENAME=${BASH_REMATCH[1]}

tar -xvzf $FILENAME

[[ $FILENAME =~ (.*).tar.gz ]]
SQLFILE=${BASH_REMATCH[1]}

echo $SQLFILE

[[ $SQLFILE =~ (.*).pgsql ]]
TABLENAME=${BASH_REMATCH[1]}

echo "Database connection string: "
read DATABASE_CONNECTION

echo 'DROP TABLE import'.$TABLENAME';' | psql $DATABASE_CONNECTION

echo 'SET search_path TO import, postgis, public; show search_path;' | cat - $SQLFILE > prepared_import.pgsql
cat prepared_import.pgsql | psql $DATABASE_CONNECTION

cp components/load_regions.pgsql prepared_load_regions.pgsql

sed -i "s/{table_name}/$TABLENAME/g" prepared_load_regions.pgsql

echo "Region type to replace: "
read REGION_TYPE
sed -i "s/{region_type}/$REGION_TYPE/g" prepared_load_regions.pgsql

echo "Zoom levels to match: "
read ZOOM_LEVELS
sed -i "s/{zoom_levels}/$ZOOM_LEVELS/g" prepared_load_regions.pgsql


cat prepared_load_regions.pgsql | psql $DATABASE_CONNECTION
