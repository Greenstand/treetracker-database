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
  console.log('hello');

  const query = {
    text: `SELECT *
    FROM bulk_tree_upload
    WHERE processed = FALSE`
  };
  rval = await pool.query(query);
  console.log(rval.rows);

  for(let row of rval.rows){
    console.log(row.id);
    const bulkData = row.bulk_data;
    if(bulkData.trees != null){
      for(let tree of bulkData.trees){
        console.log(tree);
      }
    }
  }

/*
  var output = "```    date_created | region_name  | trees";
  for(let row of rval.rows){
   console.log(row);
   const string = row.id.toString().padStart(6) + ' | ' + row.date_created_at + ' | ' + row.region_name + ' | ' + row.trees.toString().padStart(3);
   output = output + "\n" +  string;
  }
  output = output + '```';
  console.log(output);

  if(output != null) {

    var options = {
      method: 'POST',
      uri: Config.slackDailyPlantingsWebhook,

      body: {
        attachments: [
          {
            "title": "Trees Planted Yesterday in Tanzania, Kenya and globally ",
            "text": output,
          }
        ]
      },

      json: true // Automatically stringifies the body to JSON
    };

    await rp(options);

	}
  */
})().catch(e => {
  console.log(e);
  Sentry.captureException(e);
  pool.end();

  console.log('notify-slack-reports done with catch');
})
