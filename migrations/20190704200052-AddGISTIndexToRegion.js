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
  db.runSql('create index region_geom_index_gist on region using gist(geom)', callback);
};

exports.down = function(db, callback) {
  db.runSql('drop index region_geom_index_gist', callback);
};

exports._meta = {
  "version": 1
};
