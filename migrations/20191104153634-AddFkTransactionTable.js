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
        'transaction',
        'entity',
        'transaction_entity_sender_id_fk',
        { sender_entity_id: 'id' }
      ),
      db.addForeignKey.bind(
        db,
        'transaction',
        'entity',
        'transaction_entity_receiver_id_fk',
        { receiver_entity_id: 'id' }
      ),
      db.addForeignKey.bind(
        db,
        'transaction',
        'token',
        'transaction_token_id_fk',
        { token_id: 'id' }
      )
    ],
    callback
  );
};

exports.down = function(db, callback) {
  async.series(
    [
      db.removeForeignKey.bind(
        db,
        'transaction',
        'entity',
        'transaction_entity_sender_id_fk',
        { sender_entity_id: 'id' }
      ),
      db.removeForeignKey.bind(
        db,
        'transaction',
        'entity',
        'transaction_entity_receiver_id_fk',
        { receiver_entity_id: 'id' }
      ),
      db.removeForeignKey.bind(
        db,
        'transaction',
        'token',
        'transaction_token_id_fk',
        { token_id: 'id' }
      )
    ],
    callback
  );
};

exports._meta = {
  "version": 1
};
