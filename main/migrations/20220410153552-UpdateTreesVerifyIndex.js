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
      db.addIndex.bind(db, 'trees', 'trees_approved_by_time_created_idx', ['approved', 'time_created']),
      db.addIndex.bind(db, 'trees', 'trees_active_by_time_created_idx', ['active', 'time_created']),
      db.addIndex.bind(db, 'trees', 'trees_planter_id_by_time_created_idx', ['planter_id', 'time_created']),
      db.addIndex.bind(db, 'trees', 'trees_planting_organization_id_by_time_created_idx', ['planting_organization_id', 'time_created']),
    ],
    callback
  );
};

exports.down = function(db, callback) {
  async.series(
    [
      db.removeIndex.bind(db, 'trees', 'trees_approved_by_time_created_idx'),
      db.removeIndex.bind(db, 'trees', 'trees_active_by_time_created_idx'),
      db.removeIndex.bind(db, 'trees', 'trees_planter_id_by_time_created_idx'),
      db.removeIndex.bind(db, 'trees', 'trees_planting_organization_id_by_time_created_idx'),
    ],
    callback
  );
};

exports._meta = {
  "version": 1
};
