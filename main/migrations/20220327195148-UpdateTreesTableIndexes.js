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
      // Remove old index first
      db.removeIndex.bind(db, 'trees', 'trees_time_created_idx'),
      db.addIndex.bind(db, 'trees', 'trees_verify_query_idx', ['planter_id', 'approved', 'time_created']),
    ],
    callback
  );
};

exports.down = function(db, callback) {
  async.series(
    [
      db.removeIndex.bind(db, 'trees', 'trees_verify_query_idx'),
      // Reinstate old index
      db.addIndex.bind(db, 'trees', 'trees_time_created_idx', ['time_created']),
    ],
    callback
  );
};

exports._meta = {
  "version": 1
};
