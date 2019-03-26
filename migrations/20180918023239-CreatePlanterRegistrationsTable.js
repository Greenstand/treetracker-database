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
  return db.createTable('planter_registrations', {
   id: { type: 'int', primaryKey: true, autoIncrement: true },
   user_id: 'int',
   device_id: 'int',
   first_name: 'string',
   last_name: 'string',
   organization: 'string',
   phone: 'string',
   email: 'string'
   });
};

exports.down = function(db) {
  return db.dropTable('planter_registrations');
};

exports._meta = {
  "version": 1
};
