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
      db.addIndex.bind(db, 'transaction', 'transaction_sender_entity_id_idx', [
        'sender_entity_id'
      ]),
      db.addIndex.bind(db, 'transaction', 'transaction_receiver_entity_id_idx', [
        'receiver_entity_id'
      ])
    ],
    callback
  );
};

exports.down = function(db, callback) {
  async.series(
    [
      db.addIndex.bind(db, 'transaction', 'transaction_sender_entity_id_idx', [
        'sender_entity_id'
      ]),
      db.addIndex.bind(db, 'transaction', 'transaction_receiver_entity_id_idx', [
        'receiver_entity_id'
      ])
    ],
    callback
  );
};

exports._meta = {
  "version": 1
};
