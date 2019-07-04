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
  return db.runSql('create unique index on tree_region(tree_id, zoom_level)');
};

exports.down = function(db) {
  return db.runSql('drop index tree_region_tree_id_zoom_level_idx');
};

exports._meta = {
  "version": 1
};
