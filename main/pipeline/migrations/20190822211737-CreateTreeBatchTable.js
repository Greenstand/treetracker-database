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
  return db.createTable('bulk_tree_upload', {
    id: { type: 'int', primaryKey: true, autoIncrement: true},
    created_at: {
      type: 'timestamp',
      notNull: true,
      defaultValue: new String('now()')
    },
    json: 'jsonb',
    event_time: 'timestamp',
    bucket_arn: 'string',
    key: 'string',
    processed: { type: 'boolean', notNull: true, defaultValue: false},
    processed_at: 'timestamp',
    deleted_from_queue: { type: 'boolean', notNull: true, defaultValue: false},
    deleted_from_queue_at: 'timestamp'
   });
};

exports.down = function(db) {
  return db.dropTable('bulk_tree_upload');
};

exports._meta = {
  "version": 1
};
