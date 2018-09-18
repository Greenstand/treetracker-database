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
  return db.createTable('devices', {
    id: { type: 'int', primaryKey: true, autoIncrement: true },
    android_id: 'string',
    app_version: 'string',
    app_build: 'int',
    manufacturer: 'string',
    brand: 'string',
    model: 'string',
    hardware: 'string',
    device: 'string',
    serial: 'string',
  });
};

exports.down = function(db) {
  return db.dropTable('devices');
};

exports._meta = {
  "version": 1
};
