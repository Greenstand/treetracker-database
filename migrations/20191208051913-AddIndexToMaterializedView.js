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
  return db.runSql('create unique index active_tree_region_index ON active_tree_region(id)');
};

exports.down = function(db) {
  return db.runSql('drop index active_tree_region_index');
};

exports._meta = {
  "version": 1
};
