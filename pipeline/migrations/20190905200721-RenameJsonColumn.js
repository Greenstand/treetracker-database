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
  return db.renameColumn('bulk_tree_upload', 'json', 'queue_record');
};

exports.down = function(db) {
  return db.renameColumn('bulk_tree_upload', 'queue_record', 'json');
};

exports._meta = {
  "version": 1
};
