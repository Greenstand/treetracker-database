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
      db.addIndex.bind(db, 'transaction', 'transaction_entity_sender_id_idx', [
        'entity_sender_id'
      ]),
      db.addIndex.bind(db, 'transaction', 'transaction_entity_receiver_id_idx', [
        'entity_receiver_id'
      ]),
      db.addIndex.bind(db, 'transaction', 'transaction_entity_receiver_id_idx', [
        'entity_receiver_id'
      ])
    ],
    callback
  );
};

exports.down = function(db, callback) {
  async.series(
    [
      db.addIndex.bind(db, 'transaction', 'transaction_entity_sender_id_idx', [
        'entity_sender_id'
      ]),
      db.addIndex.bind(db, 'transaction', 'transaction_entity_receiver_id_idx', [
        'entity_receiver_id'
      ]),
      db.addIndex.bind(db, 'transaction', 'transaction_entity_receiver_id_idx', [
        'entity_receiver_id'
      ])
    ],
    callback
  );
};

exports._meta = {
  "version": 1
};
