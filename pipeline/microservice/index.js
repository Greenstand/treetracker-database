const express = require('express');
const Sentry = require('@sentry/node');
const bearerToken = require('express-bearer-token');
const bodyParser = require('body-parser');
const http = require('http');
const pg = require('pg');
const { Pool, Client } = require('pg');
const path = require('path');
const jwt = require('jsonwebtoken');
const Data = require('./src/data');

const config = require('./config/config');
const pool = new Pool({
  connectionString: config.connectionString
});

pool.on('connect', (client) => {
  //console.log("connected", client);
})

process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0";

const data = new Data(pool);

const app = express();
const port = process.env.NODE_PORT || 3005;

Sentry.init({ dsn: config.sentry_dsn });

app.use(Sentry.Handlers.requestHandler());
app.use(bodyParser.urlencoded({ extended: false })); // parse application/x-www-form-urlencoded
app.use(bodyParser.json()); // parse application/json
app.use(Sentry.Handlers.errorHandler());

// Optional fallthrough error handler
app.use(function onError(err, req, res, next) {
  // The error id is attached to `res.sentry` to be returned
  // and optionally displayed to the user for support.
  res.statusCode = 500;
  res.end(res.sentry + '\n');
});


app.set('view engine','html');

app.post('/planters/registration', async (req, res) => {
  const user = await data.findOrCreateUser(req.body.planter_identifier, req.body.first_name, req.body.last_name, req.body.organization);
  await data.createPlanterRegistration(user.id, req.deviceId, req.body);
  res.status(200).json({});
});

app.post('/trees/create', async (req, res) => {
    const user = await data.findUser(req.body.planter_identifier);
    var duplicate = null;
    if(req.body.uuid !== null 
      && req.body.uuid !== undefined
      && req.body.uuid !== ""){
      duplicate  = await data.checkForExistingTree(req.body.uuid);
    }
    if(duplicate !== null){
      res.status(200).json({ duplicate });
    } else {
      const tree = await data.createTree( user.id, req.deviceId, req.body);
      res.status(201).json({ tree });
    }
});


app.listen(port,()=>{
    console.log('listening on port ' + port);
});

module.exports = app;
