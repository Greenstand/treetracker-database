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
  return db.createTable('entity_relationship', {
      id: { type: 'int', primaryKey: true, autoIncrement: true},
      parent_entity_id: { type: 'int', notNull: true },
      child_entity_id: { type: 'int', notNull: true },
      relationship_type: { type: 'string', notNull: true},
      created_at : {
        type: 'timestamp',
        notNull: true,
        defaultValue: new String("now()")
      }
  });    
};

exports.down = function(db) {
  return db.dropTable('entity_relationship');
};

exports._meta = {
  "version": 1
};
