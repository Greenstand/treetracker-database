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
  return db.runSql("DROP TYPE reject_reason");
};

exports.down = function(db) {
  return db.runSql("CREATE TYPE reject_reason AS ENUM ('not_tree', 'duplicate', 'blurry_image')");
};

exports._meta = {
  "version": 1
};
