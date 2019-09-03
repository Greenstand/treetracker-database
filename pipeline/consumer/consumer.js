const fs = require("fs");

const { Consumer } = require('sqs-consumer');
var aws = require('aws-sdk');
aws.config.update({
    s3ForcePathStyle: true,
    // FIXME make this work based on the config
    endpoint: 'http://localhost:4572'
});
var config = require('./config/config')
const s3 = new aws.S3();

const Region = config.region;
const QueueUrl = config.queueUrl;

const { Pool, Client } = require('pg');
const pool = new Pool({ connectionString: config.connectionString });

//const Sentry = require('@sentry/node');
//Sentry.init({ dsn: config.sentryDSN });

console.log(Region)
console.log(QueueUrl)
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
    console.log(body);
    var records = body['Records'];
    //console.log(records);

    for(let record of records) {
      //console.log(record);
      var fullRecord = JSON.stringify(record);
      console.log(fullRecord);
      var eventTime = record['eventTime'];
      var bucketArn = record['s3']['bucket']['arn'];
      var bucketName = record['s3']['bucket']['name'];
      var key = record['s3']['object']['key'];

      fetchAndSaveS3Data(key, bucketName);

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

function fetchAndSaveS3Data(key, bucket) {
    params = {
        Bucket: bucket,
        Key: key
    };
    s3.getObject(params, function(err, data){
        if(err){
            console.log("error");
            console.log(err);
        } else {
            let objectData = JSON.parse(data.Body.toString('utf-8'));
            console.log(objectData);
        }
    });
}


app.start()

