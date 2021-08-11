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
  db.runSql(`
    CREATE MATERIALIZED VIEW organization_children AS
    SELECT id,ARRAY(SELECT entity_id FROM getentityrelationshipchildren(id)) AS children, map_name 
    FROM entity 
    WHERE map_name IS NOT NULL;
  `, callback);
};

exports.down = function(db, callback) {
  db.runSql("DROP MATERIALIZED VIEW organization_children;", callback);
};

exports._meta = {
  "version": 1
};
