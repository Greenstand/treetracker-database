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
      db.addForeignKey.bind(
        db,
        'pending_update',
        'planter',
        'pending_update_planter_id_fk',
        { planter_id: 'id' }
      ),
      db.addForeignKey.bind(db, 'locations', 'planter', 'locations_planter_id_fk', {
        planter_id: 'id'
      }),
      db.addForeignKey.bind(db, 'notes', 'planter', 'notes_planter_id_fk', {
        planter_id: 'id'
      })
    ],
    callback
  );
};

exports.down = function(db, callback) {
  async.series(
    [
      db.addForeignKey.bind(
        db,
        'pending_update',
        'planter',
        'pending_update_planter_id_fk',
        { planter_id: 'id' }
      ),
      db.addForeignKey.bind(db, 'locations', 'planter', 'locations_planter_id_fk', {
        planter_id: 'id'
      }),
      db.addForeignKey.bind(db, 'notes', 'planter', 'notes_planter_id_fk', {
        planter_id: 'id'
      })
    ],
    callback
  );
};

exports._meta = {
  "version": 1
};
