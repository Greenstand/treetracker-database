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

exports.up = function(db) {
  return db.addForeignKey(
    'entity_role',
    'entity',
    'entity_role_entity_id_fk',
    { entity_id: 'id' }, {}
  );
};

exports.down = function(db) {
  return db.removeForeignKey(
    'entity_role',
    'entity',
    'entity_role_entity_id_fk'
  );
};

exports._meta = {
  "version": 1
};
