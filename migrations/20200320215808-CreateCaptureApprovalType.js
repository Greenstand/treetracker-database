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
  return db.runSql("CREATE TYPE capture_approval_type AS ENUM ('simple_lead', 'complex_leaf', 'acacia_like', 'conifer', 'fruit', 'mangrove', 'palm', 'timber')");
};

exports.down = function(db) {
  return db.runSql("DROP TYPE capture_approval_type");
};

exports._meta = {
  "version": 1
};
