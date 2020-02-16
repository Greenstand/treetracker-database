#!/bin/bash

echo "URL for shapefile archive:"
read SHAPEFILE_URL

#wget $SHAPEFILE_URL
#[[ $SHAPEFILE_URL =~ .*/([A-z_-]+\.tar\.gz) ]]
[[ $SHAPEFILE_URL =~ .*/(.*) ]]
echo ${BASH_REMATCH[1]}

FILENAME=${BASH_REMATCH[1]}

tar -xvzf $FILENAME

