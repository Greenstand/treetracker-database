'use strict';

var dbm;
var type;
var seed;

/**
 * We receive the dbmigrate dependency from dbmigrate initially.
 * This enables us to not have to rely on NODE_PATH.
 */
exports.setup = function (options, seedLink) {
  dbm = options.dbmigrate;
  type = dbm.dataType;
  seed = seedLink;
};

exports.up = function (db) {
  return db
    .createTable('organization_species', {
      id: { type: 'int', primaryKey: true, autoIncrement: true },
      organization_id: { type: 'int', notNull: true },
      species_id: { type: 'int', notNull: true },
      is_active: { type: 'boolean', notNull: true },
      time_created: { type: 'timestamp', notNull: true },
      time_updated: { type: 'timestamp', notNull: true },
    })
    .then(function () {
      return db.runSql(
        'ALTER TABLE organization_species ADD CONSTRAINT organization_species_un UNIQUE (organization_id, species_id)'
      );
    });
};

exports.down = function (db) {
  return db.dropTable('organization_species');
};

exports._meta = {
  version: 1,
};