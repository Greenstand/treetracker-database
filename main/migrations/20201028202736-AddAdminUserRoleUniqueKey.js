'use strict';

/* In order to apply the unique constraint, duplicate entries must be removed before the migration:

DELETE FROM admin_user_role 
WHERE id IN
    (SELECT id
    FROM 
        (SELECT id,
         ROW_NUMBER() OVER( PARTITION BY admin_user_id,role_id ORDER BY id ) AS row_num
        FROM admin_user_role ) t
        WHERE t.row_num > 1 );

*/

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
  return db.runSql('ALTER TABLE admin_user_role ADD CONSTRAINT admin_user_role_un UNIQUE (role_id,admin_user_id)');
};

exports.down = function(db) {
  return db.runSql('ALTER TABLE admin_user_role DROP CONSTRAINT admin_user_role_un');
};

exports._meta = {
  "version": 1
};
