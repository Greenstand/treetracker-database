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
  db.runSql('create index trees_estimated_geometric_location_index_gist on trees using gist(estimated_geometric_location)', callback);
};

exports.down = function(db, callback) {
  db.runSql('drop index trees_estimated_geometric_location_index_gist', callback);
};

exports._meta = {
  "version": 1
};
