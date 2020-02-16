#!/bin/bash

rm *.pgsql
rm *.tar.gz

echo "URL for shapefile archive: "
read SHAPEFILE_URL

wget $SHAPEFILE_URL
#[[ $SHAPEFILE_URL =~ .*/([A-z_-]+\.tar\.gz) ]]
[[ $SHAPEFILE_URL =~ .*/(.*) ]]
echo ${BASH_REMATCH[1]}

FILENAME=${BASH_REMATCH[1]}

tar -xvzf $FILENAME

[[ $FILENAME =~ (.*).tar.gz ]]
SQLFILE=${BASH_REMATCH[1]}

echo $SQLFILE

echo 'SET search_path TO import, postgis, public; show search_path;' | cat - $SQLFILE > prepared_import.pgsql
cat prepared_import.pgsql | psql postgres://treetracker@localhost/treetracker

cp load_regions.sql prepared_load_regions.sql

[[ $SQLFILE =~ (.*).pgsql ]]
TABLENAME=${BASH_REMATCH[1]}
sed -i "s/{table_name}/$TABLENAME/g" prepared_load_regions.sql

echo "Region type to replace: "
read REGION_TYPE
sed -i "s/{region_type}/$REGION_TYPE/g" prepared_load_regions.sql
