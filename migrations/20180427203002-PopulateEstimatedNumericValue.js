'use strict';

var dbm;
var type;
var seed;

/**
  * We receive the dbmigrate dependency from dbmigrate initially.
  * This enables us to not have to rely on NODE_PATH.
  */
exports.setup = function(options, seedLink) {
  dbm = options.dbmigrate;
  type = dbm.dataType;
  seed = seedLink;
};

exports.up = function(db, callback) {

  db.runSql("UPDATE trees set lat = to_number(locations.lat,'999D999999'), lon = to_number(locations.lon,'999D999999') from locations where locations.id = trees.primary_location_id");
  db.runSql("UPDATE trees SET estimated_geometric_location = ST_GeomFromText('POINT(' || lat || ' ' || lon || ')', 4326)");
  callback();

};

exports.down = function(db, callback) {

};

exports._meta = {
  "version": 1
};
