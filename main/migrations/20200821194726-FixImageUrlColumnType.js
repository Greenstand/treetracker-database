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
      db.runSql.bind(db, 'DROP MATERIALIZED VIEW trees_active'),
      db.changeColumn.bind(db, 'trees', 'image_url', { type: 'string' } ),
      db.runSql.bind(db, `CREATE MATERIALIZED VIEW trees_active AS 
    SELECT trees.id,
    trees.time_created,
    trees.time_updated,
    trees.missing,
    trees.priority,
    trees.cause_of_death_id,
    trees.planter_id AS user_id,
    trees.primary_location_id,
    trees.settings_id,
    trees.override_settings_id,
    trees.dead,
    trees.photo_id,
    trees.image_url,
    trees.certificate_id,
    trees.estimated_geometric_location,
    trees.lat,
    trees.lon,
    trees.gps_accuracy,
    trees.active,
    trees.planter_photo_url,
    trees.planter_identifier,
    trees.device_id,
    trees.sequence,
    trees.note,
    trees.verified,
    trees.uuid,
    trees.approved,
    trees.status,
    trees.cluster_regions_assigned
   FROM trees
  WHERE trees.active = true`)
    ],
    callback
  );
};

exports.down = function(db, callback) {
  return null;
};

exports._meta = {
  "version": 1
};
