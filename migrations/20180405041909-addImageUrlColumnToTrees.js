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
  db.addColumn("trees", "image_url",{
		type: "string"
  },
  ifNotExists: true,
  null)
};

exports.down = function(db) {
  db.removeColumn("trees", "image_url", null)
};

exports._meta = {
  "version": 1
};
