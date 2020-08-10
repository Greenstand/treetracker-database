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
  return db.runSql(`CREATE FUNCTION getEntityRelationshipChildren
(
  int,
  text
)
RETURNS TABLE (entity_id int, parent_id int, depth int, relationship_type text)
AS $$
WITH RECURSIVE children AS (
 SELECT entity.id, entity_relationship.parent_id, 1 as depth, entity_relationship.type
 FROM entity
 LEFT JOIN entity_relationship ON entity_relationship.child_id = entity.id AND entity_relationship.type = $2
 WHERE entity.id = $1
UNION
 SELECT next_child.id, entity_relationship.parent_id, depth + 1, entity_relationship.type
 FROM entity next_child
 JOIN entity_relationship ON entity_relationship.child_id = next_child.id AND entity_relationship.type = $2
 JOIN children c ON entity_relationship.parent_id = c.id
)
SELECT *
FROM children
$$
LANGUAGE SQL;`);
};

exports.down = function(db) {
  return db.dropSql('DROP FUNCTION getEntityRelationshipChildren');
};

exports._meta = {
  "version": 1
};
