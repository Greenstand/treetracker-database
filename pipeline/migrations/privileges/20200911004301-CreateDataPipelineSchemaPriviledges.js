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
  return db.runSql('GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO data_pipeline');
};

exports.down = function(db) {
  return db.runSql('REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM data_pipeline');
};

exports._meta = {
  "version": 1
};
