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
  let entityId;
  //insert organization entity
  return db.runSql(
    `insert into entity ` +
    `(type, name, first_name, last_name) ` +
    `values ` +
    `('o', 'freetown', 'freetown', 'freetown')`
  )
    .then(function(){
      return db.runSql(
        `select * from entity where name = 'freetown'`
      );
    })
    .then(function(result){
      //update policy
      entityId = result.rows[0].id;
      return db.runSql(
        `update admin_role set "policy" = jsonb_set("policy"::jsonb, '{organization, id}',jsonb '${entityId}') where role_name = 'Freetown Manager'`
      );
    })
    .then(function(){
      //insert planter
      return db.runSql(
        `insert into planter ` +  
        `(first_name, last_name, organization_id) ` + 
        `values ` + 
        `('planterA', 'planterA', ${entityId}),` + 
        `('planterB', 'planterB', ${entityId})` 
      );
    });
};

exports.down = function(db) {
  let entityId;

  return db.runSql(
        `select * from entity where name = 'freetown'`
  )
    .then(function(result){
      //update policy
      entityId = result.rows[0].id;
      return db.runSql(
        `delete from planter where organization_id = ${entityId}`
      );
    })
    .then(function(){
      return db.runSql(
        `delete from entity where id = ${entityId}`
      );
    });
};

exports._meta = {
  "version": 1
};
