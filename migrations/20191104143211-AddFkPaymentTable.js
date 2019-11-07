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
    'payment',
    'entity',
    'payment_entity_sender_id_fk',
    { entity_sender_id: 'id' },
    callback
  );
  db.addForeignKey(
    'payment',
    'entity',
    'payment_entity_receiver_id_fk',
    { entity_receiver_id: 'id' },
    callback
  );
};

exports.down = function(db, callback) {
  db.removeForeignKey(
    'payment',
    'entity',
    'payment_entity_sender_id_fk',
    { entity_sender_id: 'id' },
    callback
  );
  db.removeForeignKey(
    'payment',
    'entity',
    'payment_entity_receiver_id_fk',
    { entity_receiver_id: 'id' },
    callback
  );
};

exports._meta = {
  "version": 1
};
