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
  return db.addColumn('planter', 'image_rotation', 'int');
};

exports.down = function(db) {
  return db.removeColumn('planter', 'image_rotation');
};

exports._meta = {
  "version": 1
};
