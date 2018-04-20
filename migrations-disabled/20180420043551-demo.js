'use strict';

var dbm;
var type;
var seed;

/**
  * We receive the dbmigrate dependency from dbmigrate initially.
  * This enables us to not have to rely on NODE_PATH.
  */

// with no table options
exports.up = function (db, callback) {
  db.createTable('pets', {
    id: { type: 'int', primaryKey: true, autoIncrement: true },
    name: 'string'  // shorthand notation
  }, callback);
}

// with table options
exports.up = function (db, callback) {
  db.createTable('pets', {
    columns: {
      id: { type: 'int', primaryKey: true, autoIncrement: true },
      name: 'string'  // shorthand notation
    },
    ifNotExists: true
  }, callback);
}
