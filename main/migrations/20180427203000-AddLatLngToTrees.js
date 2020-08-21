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

exports.up = function (db, callback) {
  db.addColumn('trees',
               'lat',
               { type: 'decimal' });
  db.addColumn('trees',
               'lon',
               { type: 'decimal' });
  db.addColumn('trees',
               'gps_accuracy',
               { type: 'int' });
  callback(); 
};

exports.down = function (db, callback) {
  db.removeColumn('trees', 
                  'lat');
  db.removeColumn('trees',
                  'lon');
  db.removeColumn('trees',
                  'gps_accuracy');
  callback();
};

exports._meta = {
  "version": 1
};
