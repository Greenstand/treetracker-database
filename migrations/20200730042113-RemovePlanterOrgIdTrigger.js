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

exports.down = function(db, callback) {
  db.runSql(`CREATE OR REPLACE FUNCTION planter_org_id_insert() RETURNS trigger AS $$
                BEGIN	 
                  UPDATE trees SET (planter_org) =
                    (SELECT planter_org_id FROM planter
                    WHERE planter.id = trees.planter_id);
                    RETURN new.planter_org;
                END;
            $$ LANGUAGE 'plpgsql';

              CREATE TRIGGER planter_org_trigger
              AFTER INSERT
              ON trees
              FOR EACH ROW
              EXECUTE PROCEDURE planter_org_id_insert();`, callback());
};

exports.up = function(db, callback) {
  db.runSql(`DROP TRIGGER planter_org_trigger ON trees;  DROP FUNCTION planter_org_id_insert`, callback());
};

exports._meta = {
  "version": 1
};
