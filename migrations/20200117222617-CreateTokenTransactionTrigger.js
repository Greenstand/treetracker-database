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

exports.up = function(db, callback) {
  db.runSql(`CREATE OR REPLACE FUNCTION token_transaction_insert() RETURNS TRIGGER AS $$
                 BEGIN
                    INSERT INTO transaction
                    (token_id, sender_entity_id, receiver_entity_id)
                    VALUES
                    (OLD.id, OLD.entity_id, NEW.entity_id);
                    RETURN NEW;
                 END;
             $$ LANGUAGE plpgsql;

              CREATE TRIGGER token_transaction_trigger
              AFTER UPDATE
              ON token
              FOR EACH ROW
              EXECUTE PROCEDURE token_transaction_insert();`, callback());
};

exports.down = function(db, callback) {
  db.runSql(`DROP TRIGGER token_transction_trigger ON payments;  DROP FUNCTION token_transaction_insert`, callback());
};

exports._meta = {
  "version": 1
};
