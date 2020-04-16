const Config = require('./config/config');
const http = require('http');
const rp = require('request-promise-native');
const { Pool, Client } = require('pg');

const pool = new Pool({
  connectionString: Config.connectionString
});

//const Sentry = require('@sentry/node');
//Sentry.init({ dsn: Config.sentryDSN });


(async () => {

  const query = {
    text: `SELECT *
    FROM bulk_tree_upload
    WHERE processed = FALSE`
  };
  const rval = await pool.query(query);
  console.log(rval.rows);

  for(let row of rval.rows){
    console.log(row);
    const bulkData = row.bulk_data;
    const requests = [];
    if(bulkData.trees != null){
      for(let tree of bulkData.trees){
        console.log(tree);

        var options = {
          method: 'POST',
          uri: Config.dataInputMicroserviceURI + "tree",
          body: tree,
          json: true // Automatically stringifies the body to JSON
        };

        const promise = rp(options);
        requests.push(promise);
      
      }

    }

    if(bulkData.registrations != null){

      for(let planter of bulkData.registrations){
        console.log(planter);

        var options = {
          method: 'POST',
          uri: Config.dataInputMicroserviceURI + "planter",
          body: tree,
          json: true // Automatically stringifies the body to JSON
        };

        const promise = rp(options);
        requests.push(promise);
      
      }
    }

    if(bulkData.devices != null){

      for(let device of bulkData.devices){
        console.log(device);

        var options = {
          method: 'POST',
          uri: Config.dataInputMicroserviceURI + "device",
          body: device,
          json: true // Automatically stringifies the body to JSON
        };

        const promise = rp(options);
        requests.push(promise);
      
      }

    }


    const result = await Promise.all(requests);
    console.log(result);

    const update = {
      text: `UPDATE bulk_tree_upload
      SET processed = TRUE,
      processed_at = now()
      WHERE id = $1`,
      values: [row.id]
    };
    const rvalUpdate = await pool.query(update);
    console.log(`Processed bulk tree upload ${row.id}`);

  }

  pool.end();

})().catch(e => {

  console.log(e);
  //Sentry.captureException(e);
  pool.end();

  console.log('notify-slack-reports done with catch');
})
