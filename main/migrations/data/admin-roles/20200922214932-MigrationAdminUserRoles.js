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
      db.runSql.bind(db, `INSERT INTO admin_user_role (admin_user_id, role_id) 
        SELECT admin_user_role.admin_user_id, migrate_to_role.id 
        FROM admin_role migrate_to_role, admin_user_role 
        JOIN admin_role ON admin_role.id = admin_user_role.role_id AND role_name = 'Admin Legacy' 
        WHERE migrate_to_role.identifier = 'admin'`),
      db.runSql.bind(db, `INSERT INTO admin_user_role (admin_user_id, role_id) 
        SELECT admin_user_role.admin_user_id, migrate_to_role.id 
        FROM admin_role migrate_to_role, admin_user_role 
        JOIN admin_role ON admin_role.id = admin_user_role.role_id AND role_name = 'Tree Manager Legacy' 
        WHERE migrate_to_role.identifier = 'tree_manager'`),
      db.runSql.bind(db, `INSERT INTO admin_user_role (admin_user_id, role_id) 
        SELECT admin_user_role.admin_user_id, migrate_to_role.id 
        FROM admin_role migrate_to_role, admin_user_role 
        JOIN admin_role ON admin_role.id = admin_user_role.role_id AND role_name = 'Planter Manager Legacy' 
        WHERE migrate_to_role.identifier = 'planter_manager'`)
    ], callback
  )
};

exports.down = function(db, callback) {
  async.series(
    [
      db.runSql.bind(db, `UPDATE admin_user_role 
        SET active = FALSE
        FROM admin_role
        WHERE admin_role.id = admin_user_role.role_id
        AND admin_role.identifier = 'admin'`),
      db.runSql.bind(db, `UPDATE admin_user_role 
        SET active = FALSE
        FROM admin_role
        WHERE admin_role.id = admin_user_role.role_id
        AND admin_role.identifier = 'tree_manager'`),
      db.runSql.bind(db, `UPDATE admin_user_role 
        SET active = FALSE
        FROM admin_role
        WHERE admin_role.id = admin_user_role.role_id
        AND admin_role.identifier = 'planter_manager'`)
    ], callback
  )
};

exports._meta = {
  "version": 1
};
