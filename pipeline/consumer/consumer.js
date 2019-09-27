const config = require('./config/config')

const { Consumer } = require('sqs-consumer');
var aws = require('aws-sdk');
aws.config.update({
    // s3ForcePathStyle: true,
    // FIXME make this work based on the config
    // endpoint: 'http://localhost:4572'
    //endpoint: 's3.amazonaws.com'
    region: config.region
});
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

      var body = JSON.parse(message.Body);
      console.log(body);
      if(body.Event == 's3:TestEvent'){
        console.log('Test Event');
        return;
      }

      var records = body['Records'];
      //console.log(records);

      for(let record of records) {
        //console.log(record);
        var fullQueueRecord = JSON.stringify(record);
        console.log(fullQueueRecord);
        const eventTime = record['eventTime'];
        const bucketArn = record['s3']['bucket']['arn'];
        const bucketName = record['s3']['bucket']['name'];
        const key = record['s3']['object']['key'];

        const bulkData = await fetchS3Data(key, bucketName);

        // TODO put this into a table with the above pieces                                          

        const insert = {
          text: `INSERT INTO bulk_tree_upload
          (queue_record, event_time, bucket_arn, key, bulk_data)
          values
          ($1, $2, $3, $4, $5)`,
          values: [ fullQueueRecord, eventTime, bucketArn, key, bulkData ]
        };
        console.log(insert);
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

async function fetchS3Data(key, bucket) {
    params = {
        Bucket: bucket,
        Key: key
    };

    const s3GetObjectPromise = new Promise((resolve, reject) => {
        s3.getObject(params, (err, data) => {
            if ( err ) reject(err)
            else resolve(data)
        })
    });


    const data = await s3GetObjectPromise;
    let objectData = JSON.parse(data.Body.toString('utf-8'));
    return objectData;
}


app.start()

