class Data {

  constructor(pool) {
    this.pool = pool;
  }

  async checkForExistingTree(uuid) {
    
    const getQuery = {
      text: `SELECT *
      FROM trees
      WHERE uuid = $1`,
      values: [uuid]
    }
    const rval = await this.pool.query(getQuery)
      .catch(err => {
        console.log(`ERROR: FAILED TO GET CHECK UUID ON TREES ${err}`)
        throw(err);
      });
    if(rval.rows.length > 0){
      return rval.rows[0];
    } else {
      return null;
    }
  }

  async createTree(planterId, deviceId, body) {
    let lat = body.lat;
    let lon = body.lon;
    let gpsAccuracy = body.gps_accuracy;
    let timestamp = body.timestamp;
    let imageUrl = body.image_url; // first image
    let planterPhotoUrl = body.planter_photo_url;
    let planterIdentifier = body.planter_identifier;
    let note = body.note ? body.note : "";
    let uuid = body.uuid; // This is required

    const geometry = 'POINT( ' + lon + ' ' + lat + ')';
    const insertQuery = {
      text: `INSERT INTO
      trees(planter_id,
        lat,
        lon,
        gps_accuracy,
        time_created,
        time_updated,
        image_url,
        estimated_geometric_location,
        planter_photo_url,
        planter_identifier,
        device_id,
        note,
        uuid
      )
      VALUES($1, $2, $3, $4, to_timestamp($5), to_timestamp($5), $6, ST_PointFromText($7, 4326), $8, $9, $10, $11, $12 ) RETURNING *`,
      values: [planterId, lat, lon, gpsAccuracy, timestamp, imageUrl, geometry, planterPhotoUrl, planterIdentifier, deviceId, note, uuid],
    }

    const rval = await this.pool.query(insertQuery)
      .catch(err => {
        console.log(`ERROR: FAILED TO CREATE TREE ${err}`)
        throw(err);
      });
    const tree = rval.rows[0];

    tree.attributes = await this.insertTreeAttributes(tree.id, body.attributes);

    return tree;

  }

  async insertTreeAttributes(id, attributes){
    var results = [];
    if(attributes) {
      for(let attribute of attributes){
        const insert = {
          text: `INSERT INTO tree_attributes
          (tree_id, key, value)
          values
          ($1, $2, $3)
          RETURNING *`,
          values: [id, attribute.key, attribute.value]
        }
        const stored = await this.pool.query(insert);
        results.push(stored.rows[0]);
      }
    }
    return results;
  }

  async trees() {
    let query = {
      text: `SELECT *
      FROM trees
      WHERE active = true`
    }
    const rval = await this.pool.query(query);
    return rval.rows;
  }

  async treesForUser(planterId){

    let query = {
      text: `SELECT *
      FROM trees
      WHERE planter_id = $1
      AND active = true`,
      values: [planterId]
    }
    const rval = await this.pool.query(query);
    return rval.rows;

  }

  async createPlanterRegistration(planterId, deviceIdentifier, body){
    var query = {
      text: 'INSERT INTO planter_registrations ( planter_id, device_identifier, first_name, last_name, organization, location_string ) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *',
      values: [planterId, deviceIdentifier, body.first_name, body.last_name, body.organization, body.location_string]
     }
    const rval = await this.pool.query(query);
    return rval.rows[0];
  }

  async findUser(identifier){
    return await this.findOrCreateUser(identifier, "Anonymous", "Planter", "");
  }

  async findOrCreateUser(identifier, first_name, last_name, organization){
      let query = {
      text: 'SELECT * FROM planter WHERE phone = $1 OR email = $1',
      values: [identifier]
      }
      const data = await this.pool.query(query);
      if(data.rows.length == 0){
          var reg = new RegExp('^\\d+$');
          var query2 = null;
          if(reg.test(identifier)){
              query2 = {
              text: 'INSERT INTO planter (first_name, last_name, organization, phone) VALUES ($1, $2, $3, $4 ) RETURNING *',
              values: [first_name, last_name, organization, identifier]
              }
          } else {
              query2 = {
              text: 'INSERT INTO planter (first_name, last_name, organization, email) VALUES ($1, $2, $3, $4 ) RETURNING *',
              values: [first_name, last_name, organization, identifier]
              }
          }
          const rval = await this.pool.query(query2);
          return rval.rows[0];

      } else {
        return data.rows[0]
      }
  }


  async upsertDevice(body, callback){
    let android_id = body['device_identifier']
    let app_version = body['app_version']
    let app_build = body['app_build']
    let manufacturer = body['manufacturer']
    let brand = body['brand']
    let model = body['model']
    let hardware = body['hardware']
    let device = body['device']
    let serial = body['serial']
    let android_release = body['androidRelease']
    let android_sdk = body['androidSdkVersion']

    // insert only if one does not exist
    const insert = {
      text: `INSERT INTO devices (android_id) values ($1) ON CONFLICT (android_id) DO NOTHING`,
      values: [android_id]
    };
    await this.pool.query(insert);

    const query = {
      text: `UPDATE devices
      SET app_version = ($1),
      app_build = ($2),
      manufacturer = ($3),
      brand = ($4),
      model = ($5),
      hardware = ($6),
      device = ($7),
      serial = ($8),
      android_release = ($9),
      android_sdk = ($10)
      WHERE android_id = ($11)
      RETURNING *`,
      values: [app_version, app_build, manufacturer, brand, model, hardware, device, serial, android_release, android_sdk, android_id]
    };
    const returningDevice = await this.pool.query(query);
    return returningDevice.rows[0];
  }

}



module.exports = Data;
