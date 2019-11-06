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

exports.up = function(db, callback) {
  db.addForeignKey(
    'trees',
    'planter',
    'trees_planter_id_fk',
    { planter_id: 'id' },
    callback
  );
  db.addForeignKey(
    'trees',
    'entity',
    'trees_planting_organization_id_fk',
    { planting_organization_id: 'id' },
    callback
  );
  db.addForeignKey(
    'trees',
    'payment',
    'trees_payment_id_fk',
    { payment_id: 'id' },
    callback
  );
};

exports.down = function(db, callback) {
  db.removeForeignKey(
    'trees',
    'planter',
    'trees_planter_id_fk',
    { planter_id: 'id' },
    callback
  );
  db.removeForeignKey(
    'trees',
    'entity',
    'trees_planting_organization_id_fk',
    { planting_organization_id: 'id' },
    callback
  );
  db.removeForeignKey(
    'trees',
    'payment',
    'trees_payment_id_fk',
    { payment_id: 'id' },
    callback
  );
};

exports._meta = {
  "version": 1
};
