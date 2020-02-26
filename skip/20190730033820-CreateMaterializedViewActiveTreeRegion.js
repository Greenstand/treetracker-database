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
  return db.runSql(`
    CREATE MATERIALIZED VIEW active_tree_region AS
    SELECT tree_region.id,
    region.id AS region_id,
    region.centroid,
    region.type_id,
    tree_region.zoom_level
   FROM tree_region
     JOIN trees ON trees.id = tree_region.tree_id
     JOIN region ON region.id = tree_region.region_id
  WHERE trees.active = true`);
};

exports.down = function(db) {
  return db.runSql('DROP MATERIALIZED VIEW active_tree_region');
};

exports._meta = {
  "version": 1
};
