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
      db.renameColumn.bind(db, 'pending_update', 'user_id', 'planter_id'),
      db.renameColumn.bind(db, 'locations', 'user_id', 'planter_id'),
      db.renameColumn.bind(db, 'notes', 'user_id', 'planter_id')
    ],
    callback
  );
};

exports.down = function(db, callback) {
  async.series(
    [
      db.renameColumn.bind(db, 'pending_update', 'planter_id', 'user_id'),
      db.renameColumn.bind(db, 'locations', 'planter_id', 'user_id'),
      db.renameColumn.bind(db, 'notes', 'planter_id', 'user_id')
    ],
    callback
  );
};

exports._meta = {
  "version": 1
};
