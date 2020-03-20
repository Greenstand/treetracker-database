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
  return db.addColumn('trees', 'capture_approval_tag', 'capture_approval_type');
};

exports.down = function(db) {
  return db.dropColumn('trees', 'capture_approval_tag');
};

exports._meta = {
  "version": 1
};
