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
  return db.createTable('admin_user_role', {
    id: { type: 'int', primaryKey: true, autoIncrement: true},
    role_id: {
      type: 'int',
      notNull: true
    },
    admin_user_id: {
      type: 'int',
      notNull: true
    },
    active: {
      type: 'boolean',
      defaultValue: false,
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
  return db.dropTable('admin_user_role');
};

exports._meta = {
  "version": 1
};
