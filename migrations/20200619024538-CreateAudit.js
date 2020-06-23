"use strict";

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
    .runSql("CREATE TYPE platform_type AS ENUM ('admin_panel', 'web_map')")
    .then(function () {
      return db.createTable("audit", {
        id: { type: "int", primaryKey: true, autoIncrement: true },
        admin_user_id: {
          type: "int",
          notNull: true,
        },
        platform: {
          type: "platform_type",
        },
        ip: {
          type: "string",
        },
        browser: {
          type: "string",
        },
        organization: {
          type: "string",
        },
        operation: "json",
        created_at: {
          type: "timestamp",
          notNull: true,
          defaultValue: new String("now()"),
        },
      });
    });
};

exports.down = function (db) {
  return db.runSql("DROP TYPE platform_type").then(function () {
    return db.dropTable("audit");
  });
};

exports._meta = {
  version: 1,
};
