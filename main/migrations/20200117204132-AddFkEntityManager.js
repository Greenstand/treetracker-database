'use strict';

var async = require('async');

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
  async.series(
    [
      db.addForeignKey.bind(db, 'entity_manager', 'entity', 'entity_manager_parent_entity_id_fk', {
        parent_entity_id: 'id'
      }),
      db.addForeignKey.bind(db, 'entity_manager', 'entity', 'entity_manager_child_entity_id_fk', {
        child_entity_id: 'id'
      })
    ],
    callback
  );
};

exports.down = function(db, callback) {
  async.series(
    [
      db.removeForeignKey.bind(db, 'entity_manager', 'entity', 'entity_manager_parent_entity_id_fk'),
      db.removeForeignKey.bind(db, 'entity_manager', 'entity', 'entity_manager_child_entity_id_fk')
    ],
    callback
  );
};

exports._meta = {
  "version": 1
};
