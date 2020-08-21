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
  return db.runSql(`CREATE VIEW payment_list AS
    SELECT *
    FROM trees
    WHERE trees.approved = true AND trees.active = true AND (trees.device_id = ANY (ARRAY[216, 238, 317, 298, 360, 598]))`);
};

exports.down = function(db) {
  return db.runSql(`DROP VIEW payment_list`);
};

exports._meta = {
  "version": 1
};
