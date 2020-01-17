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
      db.addForeignKey.bind(db, 'planter', 'entity', 'planter_person_id_fk', {
        person_id: 'id'
      }),
      db.addForeignKey.bind(
        db,
        'planter',
        'entity',
        'planter_organization_id_fk',
        { organization_id: 'id' }
      )
    ],
    callback
  );
};

exports.down = function(db, callback) {
  async.series(
    [
      db.removeForeignKey.bind(db, 'planter', 'entity', 'planter_person_id_fk', {
        person_id: 'id'
      }),
      db.removeForeignKey.bind(
        db,
        'planter',
        'entity',
        'planter_organization_id_fk',
        { organization_id: 'id' }
      )
    ],
    callback
  );
};

exports._meta = {
  "version": 1
};
