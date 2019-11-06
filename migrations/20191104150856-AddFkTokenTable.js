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
    'token',
    'trees',
    'token_tree_id_fk',
    { tree_id: 'id' },
    callback
  );
  db.addForeignKey(
    'token',
    'entity',
    'token_entity_id_fk',
    { entity_id: 'id' },
    callback
  );
};

exports.down = function(db, callback) {
  db.removeForeignKey(
    'token',
    'trees',
    'token_tree_id_fk',
    { tree_id: 'id' },
    callback
  );
  db.removeForeignKey(
    'token',
    'entity',
    'token_entity_id_fk',
    { entity_id: 'id' },
    callback
  );
};

exports._meta = {
  "version": 1
};
