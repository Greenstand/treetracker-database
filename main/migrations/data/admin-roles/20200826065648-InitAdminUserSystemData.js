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
  //data
  const policy = 
    {
      "policies": [
        {
          "name": "super_permission",
          "description": "Can do anything"
        },
        {
          "name": "list_user",
          "description": "Can view admin users"
        },
        {
          "name": "manager_user",
          "description": "Can create/modify admin user"
        },
        {
          "name": "list_tree",
          "description": "Can view trees"
        },
        {
          "name": "approve_tree",
          "description": "Can approve/reject trees"
        },
        {
          "name": "list_planter",
          "description": "Can view planters"
        },
        {
          "name": "manage_planter",
          "description": "Can modify planter information"
        }
      ]
    };

  const roles = {
    admin: {
      name: "Admin",
      identifier: "admin",
      description: "The super administrator role, having all permissions",
      policy: {
        policies: [policy.policies[0], policy.policies[1], policy.policies[2]],
      },
    },
    treeManager: {
      name: "Tree Manager",
      identifier: "tree_manager",
      description: "Check, verify, manage trees",
      policy: {
        policies: [policy.policies[3],policy.policies[4]],
      },
    },
    planterManager: {
      name: "Planter Manager",
      identifier: "planter_manager",
      description: "Check, manage planters",
      policy: {
        policies: [policy.policies[5],policy.policies[6],],
      },
    },
    freetownManager: {
      name: "Freetown Manager", 
      identifier: "freetown_manager",
      description: "Manager for organization of freetown",
      policy: {
        policies: [policy.policies[3],policy.policies[4],policy.policies[5],policy.policies[6],],
        organization: {
          name: "freetown",
          id: 1,
        },
      },
    },
  }
  const insertSql = 
    `insert into admin_role (role_name, identifier, description, policy) ` +
      `values` + 
      Object.values(roles).map( role => {
        return `('${role.name}','${role.identifier}', '${role.description}','${JSON.stringify(role.policy)}')`
      }).join(','); 


  return db.runSql(insertSql)

};

exports.down = function(db) {
  return run.Sql(`DELETE FROM admin_role WHERE identifier IN ('admin', 'tree_manager', 'planter_manager', 'freetown_manager')`)
};

exports._meta = {
  "version": 1
};
