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
  return db.runSql("CREATE TYPE rejection_reason_type AS ENUM ('not_tree', 'unapproved_tree', 'blurry_image', 'dead', 'duplicate_image', 'flag_user', 'needs_contact_or_review')");
};

exports.down = function(db) {
  return db.runSql("DROP TYPE rejection_reason_type");
};

exports._meta = {
  "version": 1
};
