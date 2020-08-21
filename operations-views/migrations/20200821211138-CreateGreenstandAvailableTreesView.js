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
  return db.runSql(`CREATE VIEW operations.greenstand_available_trees
AS SELECT trees.*,
planter.first_name, planter.last_name, planter.image_url as planter_image_url
FROM trees
JOIN planter
ON trees.planter_id = planter.id
JOIN entity
ON planter.organization_id = entity.id
WHERE approved = true
AND active = true
AND entity.id = 1
AND trees.id NOT IN (
  SELECT tree_id
  FROM token
)`);
};

exports.down = function(db) {
  return db.runSql('DROP VIEW operations.greenstand_available_trees');
};

exports._meta = {
  "version": 1
};
