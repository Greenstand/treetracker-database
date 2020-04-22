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
  db.addColumn('planter_registrations',
               'lat',
               { type: 'decimal' });
  db.addColumn('planter_registrations',
               'lon',
               { type: 'decimal' });
  db.addColumn('planter_registrations',
               'gps_accuracy',
               { type: 'int' });
  callback(); 
};

exports.down = function (db, callback) {
  db.removeColumn('planter_registrations', 
                  'lat');
  db.removeColumn('planter_registrations',
                  'lon');
  db.removeColumn('planter_registrations',
                  'gps_accuracy');
  callback();
};

exports._meta = {
  "version": 1
};
