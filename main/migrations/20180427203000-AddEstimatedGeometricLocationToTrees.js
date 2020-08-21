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
  db.runSql("SELECT AddGeometryColumn ('public','trees','estimated_geometric_location',4326,'POINT',2)", callback);
};

exports.down = function(db, callback) {
  db.runSql("SELECT DropGeometryColumn( 'trees', 'estimated_geometric_location')", callback);
};

exports._meta = {
  "version": 1
};
