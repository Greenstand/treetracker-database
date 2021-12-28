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

const policies = 
{
  "list_earnings": {
    "name": "list_earnings",
    "description": "Can view earnings"
  },
  "manage_earnings": {
    "name": "manage_earnings",
    "description": "Can modify/export earnings"
  },
  "list_payments": {
    "name": "list_payments",
    "description": "Can view payments"
  },
  "manage_payments": {
    "name": "manage_payments",
    "description": "Can import/modify payments"
  },
  "send_messages": {
    "name": "send_messages",
    "description": "Can send and view messages"
  },
  "match_captures": {
    "name": "match_captures",
    "description": "Can perform capture matching"
  },
  "list_species": {
    "name": "list_species",
    "description": "Can view species information"
  },
  "manage_species": {
    "name": "manage_species",
    "description": "Can modify species information"
  },
  "list_stakeholders": {
    "name": "list_stakeholders",
    "description": "Can view stakeholders"
  },
  "manage_stakeholders": {
    "name": "manage_stakeholders",
    "description": "Can modify stakeholder information"
  },
  // The use of the singular 'user' here is to maintain compatibility with existing roles
  "list_user": {
    "name":"list_user",
    "description":"Can view admin users"
  },
  "manage_user": {
    "name":"manager_user",
    "description":"Can create/modify admin user"
  },
};

const roles = [
  {
    name: "Earnings Manager",
    identifier: "earnings_manager",
    description: "View, manage and export earnings",
    policy: {
      policies: [policies.list_earnings, policies.manage_earnings],
    },
  }, {
    name: "Payments Manager",
    identifier: "payments_manager",
    description: "Import, view and manage payments",
    policy: {
      policies: [policies.list_payments, policies.manage_payments],
    },
  }, {
    name: "Comms Manager",
    identifier: "comms_manager",
    description: "Send and view messages",
    policy: {
      policies: [policies.send_messages],
    },
  }, {
    name: "Capture Matcher",
    identifier: "capture_matcher",
    description: "Perform capture matching",
    policy: {
      policies: [policies.match_captures],
    },
  }, {
    name: "Species Manager",
    identifier: "species_manager",
    description: "View and manage species",
    policy: {
      policies: [policies.list_species, policies.manage_species],
    },
  }, {
    name: "Stakeholder Manager",
    identifier: "stakeholder_manager",
    description: "View and manage stakeholders",
    policy: {
      policies: [policies.list_stakeholders, policies.manage_stakeholders],
    },
  }, {
    name: "User Manager",
    identifier: "user_manager",
    description: "View and manage admin users",
    policy: {
      policies: [policies.list_user, policies.manage_user],
    },
  },
];

exports.up = function(db) {
  roles.map(role => {
    console.log(role.name);
    role.policy.policies.map(policy => {
      console.log(`- ${policy.name}`);
    });
  });
  const insertSql = 
    `insert into admin_role (role_name, identifier, description, policy) ` +
      `values` + 
      roles.map(role => {
        return `('${role.name}','${role.identifier}', '${role.description}','${JSON.stringify(role.policy)}')`
      }).join(',');

  return db.runSql(insertSql);
};

exports.down = function(db) {
  const roleIdentifiers = roles.map(role => `'${role.identifier}'`); 
  return db.runSql(`delete from admin_role where identifier in (${roleIdentifiers.join(',')})`);
};

exports._meta = {
  "version": 1,
};
