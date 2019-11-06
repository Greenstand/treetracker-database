'use strict';

var dbm;
var type;
var seed;

/**
 * We receive the dbmigrate dependency from dbmigrate initially.
 * This enables us to not have to rely on NODE_PATH.
 */
exports.setup = function (options, seedLink) {
  dbm = options.dbmigrate;
  type = dbm.dataType;
  seed = seedLink;
};

exports.up = function (db) {
  return db.createTable('entity', {
    id: { type: 'int', primaryKey: true, autoIncrement: true },
    name: 'string',
    first_name: 'string',
    last_name: 'string',
    email: 'string',
    phone: 'string',
    pwd_reset_required: { type: 'boolean', defaultValue: false },
    website: 'string'
  });
};

exports.down = function (db) {
  return db.dropTable('entity');
};

exports._meta = {
  "version": 1
};
