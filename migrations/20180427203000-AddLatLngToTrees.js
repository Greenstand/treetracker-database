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

exports.up = function (db) {
  db.addColumn('trees',
               'lat',
               { type: 'decimal' });
  return db.addColumn('trees',
               'lon',
               { type: 'decimal' });
};

exports.down = function (db) {
  db.removeColumn('trees', 
                  'lat');
  return db.removeColumn('trees',
                  'lon');
};

exports._meta = {
  "version": 1
};
