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
  return db.createTable('clusters', {
    id: { type: 'int', primaryKey: true, autoIncrement: true },
    count: 'int',
    zoom_level: 'int'
  });
};

exports.down = function(db) {
  return db.dropTable('clusters');
};

exports._meta = {
  "version": 1
};
