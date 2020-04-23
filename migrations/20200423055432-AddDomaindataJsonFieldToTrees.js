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
  return db.addColumn('trees', 'domain_specific_data', 'jsonb');
};

exports.down = function(db) {
  return db.addColumn('trees', 'domain_specific_data');
};

exports._meta = {
  "version": 1
};
