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
  return db.runSql(`ALTER TYPE capture_approval_type RENAME VALUE 'simple_lead' TO 'simple_leaf';`);
};

exports.down = function(db) {
  return db.runSql(`ALTER TYPE capture_approval_type RENAME VALUE 'simple_leaf' TO 'simple_lead';`);
};

exports._meta = {
  "version": 1
};
