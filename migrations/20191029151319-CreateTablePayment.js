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
  return db.createTable('payment', {
    id: { type: 'int', primaryKey: true, autoIncrement: true },
    sender_entity_id: 'int',
    receiver_entity_id: 'int',
    date_paid: 'date',
    tree_amt: 'int',
    usd_amt: 'int',
    local_amt: 'int',
    paid_by: 'string',
  });
};

exports.down = function(db) {
  return db.dropTable('payment');
};

exports._meta = {
  "version": 1
};
