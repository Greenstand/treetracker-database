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
  return db.runSql("CREATE TYPE age_type AS ENUM ('new_tree', 'over_two_years')");
};

exports.down = function(db) {
  return db.runSql("DROP TYPE age_type");
};

exports._meta = {
  "version": 1
};
