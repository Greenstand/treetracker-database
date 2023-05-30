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
      db.addIndex.bind(db, 'trees', 'trees_token_id_idx', ['token_id']),
    ],
    callback
  );
};

exports.down = function(db, callback) {
  async.series(
    [
      db.removeIndex.bind(db, 'trees', 'trees_token_id_idx'),
    ],
    callback
  );
};

exports._meta = {
  "version": 1
};
