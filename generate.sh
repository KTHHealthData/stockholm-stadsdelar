#!/bin/sh

SHAPEFILES_DIR="./shapefiles/"
GEOJSON_DIR="./geojson"

# see https://postgis.net/docs/ST_Simplify.html
SIMPLIFY_TOLERANCE=3

mkdir -p "$SHAPEFILES_DIR/fullsize"
mkdir -p "$SHAPEFILES_DIR/simplified"
mkdir -p "$GEOJSON_DIR/fullsize"
mkdir -p "$GEOJSON_DIR/simplified"

##############################################################################
# Full size shapefiles
##############################################################################

echo "Generating full size shapefiles, this might take several minutes"

# stadsdelar including water
ogr2ogr "$SHAPEFILES_DIR/fullsize/stadsdelar.shp" data.vrt.xml stadsdelar

# water
ogr2ogr "$SHAPEFILES_DIR/fullsize/vatten.shp" data.vrt.xml vatten

# stadsdelar excluding water
ogr2ogr "$SHAPEFILES_DIR/fullsize/stadsdelar_utan_vatten.shp" data.vrt.xml -dialect "sqlite" -sql \
 "SELECT name, ST_DIFFERENCE(stadsdelar.geometry, vatten.geometry)
  FROM stadsdelar, vatten";

##############################################################################
# Simplified shapefiles
##############################################################################

echo "Generating simplified shapefiles"

# stadsdelar including water
ogr2ogr "$SHAPEFILES_DIR/simplified/stadsdelar.shp" "$SHAPEFILES_DIR/fullsize/stadsdelar.shp" -dialect "sqlite" -sql \
 "SELECT name, ST_SIMPLIFY(geometry, $SIMPLIFY_TOLERANCE)
  FROM stadsdelar"

# water
ogr2ogr "$SHAPEFILES_DIR/simplified/vatten.shp" "$SHAPEFILES_DIR/fullsize/vatten.shp" -dialect "sqlite" -sql \
 "SELECT ST_SIMPLIFY(geometry, $SIMPLIFY_TOLERANCE)
  FROM vatten"

# stadsdelar excluding water
ogr2ogr "$SHAPEFILES_DIR/simplified/stadsdelar_utan_vatten.shp" "$SHAPEFILES_DIR/fullsize/stadsdelar_utan_vatten.shp" -dialect "sqlite" -sql \
 "SELECT name, ST_SIMPLIFY(geometry, $SIMPLIFY_TOLERANCE)
  FROM stadsdelar_utan_vatten"

##############################################################################
# Geojson
##############################################################################

echo "Converting to geojson"

# full size
ogr2ogr "$GEOJSON_DIR/fullsize/stadsdelar.geo.json" -f GeoJSON -t_srs EPSG:4326 "$SHAPEFILES_DIR/fullsize/stadsdelar.shp"
ogr2ogr "$GEOJSON_DIR/fullsize/vatten.geo.json" -f GeoJSON -t_srs EPSG:4326 "$SHAPEFILES_DIR/fullsize/vatten.shp"
ogr2ogr "$GEOJSON_DIR/fullsize/stadsdelar_utan_vatten.geo.json" -f GeoJSON -t_srs EPSG:4326 "$SHAPEFILES_DIR/fullsize/stadsdelar_utan_vatten.shp"

# simplified
ogr2ogr "$GEOJSON_DIR/simplified/stadsdelar.geo.json" -f GeoJSON -t_srs EPSG:4326 "$SHAPEFILES_DIR/simplified/stadsdelar.shp"
ogr2ogr "$GEOJSON_DIR/simplified/vatten.geo.json" -f GeoJSON -t_srs EPSG:4326 "$SHAPEFILES_DIR/simplified/vatten.shp"
ogr2ogr "$GEOJSON_DIR/simplified/stadsdelar_utan_vatten.geo.json" -f GeoJSON -t_srs EPSG:4326 "$SHAPEFILES_DIR/simplified/stadsdelar_utan_vatten.shp"