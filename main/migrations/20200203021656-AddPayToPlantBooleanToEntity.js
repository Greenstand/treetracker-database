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
  return db.addColumn('entity', 'offering_pay_to_plant', 
    { 
      type: 'boolean',
      notNull: true,
      defaultValue: false
    }
  );
};

exports.down = function(db) {
  return db.removeColumn('entity', 'offering_pay_to_plant');
};

exports._meta = {
  "version": 1
};
