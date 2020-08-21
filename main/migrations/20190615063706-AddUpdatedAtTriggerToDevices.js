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

exports.up = function(db, callback) {
  return db.runSql(`CREATE TRIGGER set_updated_at_timestamp
    BEFORE UPDATE ON devices
    FOR EACH ROW
    EXECUTE PROCEDURE trigger_set_updated_at()`, callback());
};

exports.down = function(db, callback) {
  return db.runSql('DROP TRIGGER set_updated_at_timestamp ON DEVICES', callback());
};

exports._meta = {
  "version": 1
};
