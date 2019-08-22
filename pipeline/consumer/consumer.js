const fs = require("fs");

const { Consumer } = require('sqs-consumer');
const Region = 'eu-central-1';
const QueueUrl = 'https://sqs.eu-central-1.amazonaws.com/053061259712/treetracker-test-queue';

const config = require('./config/config');
const { Pool, Client } = require('pg');
const pool = new Pool({ connectionString: config.connectionString });

//const Sentry = require('@sentry/node');
//Sentry.init({ dsn: config.sentryDSN });

const app = Consumer.create({
    queueUrl: QueueUrl,
    region: Region,
    batchSize: 10, 
    handleMessage: async function(message) {

    /*
    fs.writeFile("/root/data/" + message.MessageId, JSON.stringify(message), (err) => {
        if (err) console.log(err);
        console.log("Successfully wrote " + message.MessageId);
        });
        */

    var body = JSON.parse(message.Body);
    //console.log(body);
    var records = body['Records'];
    console.log(records);

    for(let record of records) {
      //console.log(record);
      var fullRecord = JSON.stringify(record);
      var eventTime = record['eventTime'];
      var bucketArn = record['s3']['bucket']['arn'];
      var key = record['s3']['object']['key'];

      // TODO put this into a table with the above pieces                                          

      const insert = {
        text: `INSERT INTO bulk_tree_upload
        (json, event_time, bucket_arn, key)
        values
        ($1, $2, $3, $4)`,
        values: [ fullRecord, eventTime, bucketArn, key ]
      };
      await pool.query(insert);

    }

    }   
});

app.on('error', function (err) {
    console.log('error', err);
});

app.on('processing_error', function (err) {
    console.log('processing_error', err);
});


app.start()

