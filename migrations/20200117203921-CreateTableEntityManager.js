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
  return db.createTable('entity_manager', {
    id: { type: 'int', primaryKey: true, autoIncrement: true},
    parent_entity_id: 'int',
    child_entity_id: 'int',
    active: {
      type: 'boolean',
      defaultValue: false,
      notNull: true
    }})
};

exports.down = function(db) {
  return db.dropTable('entity_manager');
};

exports._meta = {
  "version": 1
};
