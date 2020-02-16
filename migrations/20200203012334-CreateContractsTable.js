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
  return db.createTable('contract', {
    id: { type: 'int', primaryKey: true, autoIncrement: true},
    author_id: {
      type: 'int',
      notNull: true
    },
    name: {
      type: 'string',
      notNull: true
    },
    enabled: {
      type: 'boolean',
      notNull: true,
      defaultValue: false
    },
    contract: {
      type: 'json',
      notNull: true
    },
    created_at: {
      type: 'timestamp',
      notNull: true,
      defaultValue: new String('now()')
    }
  });
};

exports.down = function(db) {
  return db.dropTable('contract');
};

exports._meta = {
  "version": 1
};
