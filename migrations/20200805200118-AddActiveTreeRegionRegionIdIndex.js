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

exports.up = function(db) {
  return db.runSql('CREATE INDEX active_tree_region_region_id_idx ON active_tree_region(region_id)');
};

exports.down = function(db) {
  return db.runSql('DROP INDEX active_tree_region_region_id_idx');
};

exports._meta = {
  "version": 1
};
