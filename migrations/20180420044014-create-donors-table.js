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
  db.createTable('donors', {
    id: { type: 'int', primaryKey: true, autoIncrement: true },
    organization_id: 'integer',
    first_name: 'string',  // shorthand notation
    last_name: 'string',  // shorthand notation
    email: 'string',  // shorthand notation
  }, callback);
};

exports.down = function(db, callback) {
  db.dropTable('donors', 
   callback);
};

exports._meta = {
  "version": 1
};
