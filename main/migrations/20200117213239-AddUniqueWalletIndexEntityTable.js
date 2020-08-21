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
  return db.runSql('create unique index on entity(wallet)');
};

exports.down = function(db) {
  return db.runSql('drop index entity_wallet_idx');
};

exports._meta = {
  "version": 1
};
