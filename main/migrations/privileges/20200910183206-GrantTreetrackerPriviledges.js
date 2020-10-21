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
      db.runSql.bind(db, 'GRANT SELECT, INSERT, UPDATE ON admin_role TO treetracker'),
      db.runSql.bind(db, 'GRANT SELECT, INSERT, UPDATE ON admin_user TO treetracker'),
      db.runSql.bind(db, 'GRANT SELECT, INSERT, UPDATE ON admin_user_role TO treetracker'),
      db.runSql.bind(db, 'GRANT SELECT ON api_key TO treetracker'),
      db.runSql.bind(db, 'GRANT SELECT, INSERT ON audit TO treetracker'),
      db.runSql.bind(db, 'GRANT SELECT ON certificates TO treetracker'),
      db.runSql.bind(db, 'GRANT SELECT, INSERT, UPDATE, DELETE ON clusters TO treetracker'),
      db.runSql.bind(db, 'GRANT SELECT ON contract TO treetracker'),
      db.runSql.bind(db, 'GRANT SELECT, INSERT, UPDATE ON devices TO treetracker'),
      db.runSql.bind(db, 'GRANT SELECT ON donors TO treetracker'),
      db.runSql.bind(db, 'GRANT SELECT, INSERT ON entity TO treetracker'),
      db.runSql.bind(db, 'GRANT SELECT, INSERT ON entity_manager TO treetracker'),
      db.runSql.bind(db, 'GRANT SELECT ON entity_relationship TO treetracker'),
      db.runSql.bind(db, 'GRANT SELECT ON entity_role TO treetracker'),
      db.runSql.bind(db, 'GRANT SELECT, INSERT ON note_trees TO treetracker'),
      db.runSql.bind(db, 'GRANT SELECT, INSERT ON notes TO treetracker'),
      db.runSql.bind(db, 'GRANT SELECT ON organizations TO treetracker'),
      db.runSql.bind(db, 'GRANT SELECT ON payment TO treetracker'),
      db.runSql.bind(db, 'GRANT SELECT, INSERT, UPDATE ON planter TO treetracker'),
      db.runSql.bind(db, 'GRANT SELECT, INSERT, UPDATE ON planter_registrations TO treetracker'),
      db.runSql.bind(db, 'GRANT SELECT, INSERT, UPDATE ON region TO treetracker'),
      db.runSql.bind(db, 'GRANT SELECT, INSERT, UPDATE ON region_type TO treetracker'),
      db.runSql.bind(db, 'GRANT SELECT, INSERT, UPDATE ON region_zoom TO treetracker'),
      db.runSql.bind(db, 'GRANT SELECT ON spatial_ref_sys TO treetracker'),
      db.runSql.bind(db, 'GRANT SELECT, INSERT, UPDATE ON tag TO treetracker'),
      db.runSql.bind(db, 'GRANT SELECT, INSERT, UPDATE ON token TO treetracker'),
      db.runSql.bind(db, 'GRANT SELECT, INSERT, UPDATE ON transaction TO treetracker'),
      db.runSql.bind(db, 'GRANT SELECT, INSERT, UPDATE ON transfer TO treetracker'),
      db.runSql.bind(db, 'GRANT SELECT, INSERT, UPDATE ON tree_attributes TO treetracker'),
      db.runSql.bind(db, 'GRANT SELECT, INSERT, UPDATE ON tree_region TO treetracker'),
      db.runSql.bind(db, 'GRANT SELECT, INSERT, UPDATE ON tree_species TO treetracker'),
      db.runSql.bind(db, 'GRANT SELECT, INSERT, UPDATE ON tree_tag TO treetracker'),
      db.runSql.bind(db, 'GRANT SELECT, INSERT, UPDATE ON trees TO treetracker')
    ],
    callback
  );
};

exports.down = function(db, callback) {
  async.series(
    [
      db.runSql.bind(db, 'REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM treetracker')
    ],
    callback
  );
};

exports._meta = {
  "version": 1
};
