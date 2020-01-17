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
  return db.createTable('entity_role', {
    id: { type: 'int', primaryKey: true, autoIncrement: true},
    entity_id: 'int',
    role_name: 'string',
    enabled: 'boolean'
  });
    
};

exports.down = function(db) {
  return db.dropTable('entity_role');
};

exports._meta = {
  "version": 1
};
