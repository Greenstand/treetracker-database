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
  return db.renameColumn('trees', 'user_id', 'planter_id');
};

exports.down = function(db) {
  return db.renameColumn('trees', 'planter_id', 'user_id');
};

exports._meta = {
  "version": 1
};
