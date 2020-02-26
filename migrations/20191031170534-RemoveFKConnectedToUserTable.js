'use strict';

var async = require('async');

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

  async.series(
    [
  db.removeForeignKey.bind(
    db, 
    'trees',
    'trees_user_id_fkey'
    ),
  db.removeForeignKey.bind(
    db,
    'pending_update',
    'pending_update_user_id_fkey'
    ),
  db.removeForeignKey.bind(
    db,
    'locations',
    'locations_user_id_fkey'
  ),
  db.removeForeignKey.bind(
    db,
    'notes',
    'notes_user_id_fkey'
  )], callback);
}; 

exports.down = function(db, callback) {

/*
  db.addForeignKey(
    'trees',
    'users',
    'trees_user_id_fkey',
    {
	'user_id' : 'id'
    },
    callback
    );
*/

/*
  async.series(
    [
  db.removeForeignKey.bind(
    db, 
    'trees',
    'trees_user_id_fkey',
    { dropIndex: true }),
  db.removeForeignKey.bind(
    db,
    'pending_update',
    'pending_update_user_id_fkey',
    { dropIndex: true }),
  db.removeForeignKey.bind(
    db,
    'locations',
    'locations_user_id_fkey',
    { dropIndex: true }
  ),
  db.removeForeignKey.bind(
    db,
    'notes',
    'notes_user_id_fkey',
    { dropIndex: true }
  )], callback);
*/
}; 

exports._meta = {
  "version": 1
};
