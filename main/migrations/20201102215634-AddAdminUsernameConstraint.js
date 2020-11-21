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
  return db.runSql('CREATE UNIQUE INDEX admin_user_un ON admin_user (user_name) where active = true');
};

exports.down = function(db) {
  return db.runSql('DROP INDEX admin_user_un');
};

exports._meta = {
  "version": 1
};
