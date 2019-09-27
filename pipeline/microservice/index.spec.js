const supertest = require('supertest');
const chai = require('chai');
const expect = chai.expect;
const uuid = require('uuid');

const app = require('./index.js');
const request = supertest(app);


var authToken = 'hello';

describe('API', () => {

  describe('Planters Endpoints', () => {

    describe('POST /planter/registration', () => {
      it('should register a planter', (done) => {
        console.log('planters/registration - sending token:');
        console.log(authToken);
        request.post('/planters/registration')
          .send({
            planter_identifier: 'asdf-asdf-asdf',
            first_name: 'George Washington',
            last_name: 'Carver',
            organization: 'NAACP'
          })
          .set('Authorization', `Bearer ${authToken}`)
          .expect(200)
          .end((err, res) => {
            if (err) throw err;
            expect(res.data).to.not.equal(0);
            done();
          });
      });
    });
  });

  describe('Devices Endpoints', () => {

    describe('PUT /devices/', () => {
      it('should add device to the list of devices', (done) => {
        request.put('/devices/')
          .send({
            deviceId: 'SDNE78DKJLS76F'
          })
          .set('Authorization', `Bearer ${authToken}`)
          .expect(200)
          .end((err, res) => {
            if (err) throw err;
            expect(res.data).to.not.equal(0);
            done();
          });
      });
    });
  });

  describe('Trees Endpoints', () => {

    describe('POST /trees/create', () => {
      it('should record a new tree', (done) => {
        request.post('/trees/create')
          .send({
            planter_identifier: 'asdf-asdf-asdf',
            lat: 80,
            lon: 120,
            gps_accuracy: 1,
            note: 'my note',
            timestamp: 1536367800,
            image_url: 'http://www.myimage.org/',
            sequence_id: 1,
            uuid: uuid()
          })
          .set('Authorization', `Bearer ${authToken}`)
          .set('Accept', 'application/json')
          .expect(201)
          .end((err, res) => {
            if (err) throw done(err);
            expect(res.rows).to.not.equal(0);
            done();
          });
      });

      it('should not record a duplicate new tree', (done) => {
        const treeUuid = uuid();
        const treeData = {
          planter_identifier: 'asdf-asdf-asdf',
          lat: 80,
          lon: 120,
          gps_accuracy: 1,
          note: 'my note',
          timestamp: 1536367800,
          image_url: 'http://www.myimage.org/',
          uuid: treeUuid
        };
        request.post('/trees/create')
          .send(treeData)
          .set('Authorization', `Bearer ${authToken}`)
          .set('Accept', 'application/json')
          .end((err, res) => {

          request.post('/trees/create')
            .send(treeData)
            .set('Authorization', `Bearer ${authToken}`)
            .set('Accept', 'application/json')
            .expect(200)
            .end((err, res) => {

              if (err) throw done(err);
              expect(res.rows).to.not.equal(0);
              done();

            });
          });
      });

      it('should allow a missing UUID for backwards compatibility', (done) => {
        request.post('/trees/create')
          .send({
            planter_identifier: 'asdf-asdf-asdf',
            lat: 80,
            lon: 120,
            gps_accuracy: 1,
            note: 'my note',
            timestamp: 1536367800,
            image_url: 'http://www.myimage.org/',
            sequence_id: 1
          })
          .set('Authorization', `Bearer ${authToken}`)
          .set('Accept', 'application/json')
          .expect(201)
          .end((err, res) => {
            if (err) throw done(err);
            expect(res.rows).to.not.equal(0);
            done();
          });
      });

      it('should allow a null UUID for backwards compatibility', (done) => {
        request.post('/trees/create')
          .send({
            planter_identifier: 'asdf-asdf-asdf',
            lat: 80,
            lon: 120,
            gps_accuracy: 1,
            note: 'my note',
            timestamp: 1536367800,
            image_url: 'http://www.myimage.org/',
            sequence_id: 1,
            uuid: null
          })
          .set('Authorization', `Bearer ${authToken}`)
          .set('Accept', 'application/json')
          .expect(201)
          .end((err, res) => {
            if (err) throw done(err);
            expect(res.rows).to.not.equal(0);
            done();
          });
      });

      it('should allow an empty UUID for backwards compatibility', (done) => {
        request.post('/trees/create')
          .send({
            planter_identifier: 'asdf-asdf-asdf',
            lat: 80,
            lon: 120,
            gps_accuracy: 1,
            note: 'my note',
            timestamp: 1536367800,
            image_url: 'http://www.myimage.org/',
            sequence_id: 1,
            uuid: ""
          })
          .set('Authorization', `Bearer ${authToken}`)
          .set('Accept', 'application/json')
          .expect(201)
          .end((err, res) => {
            if (err) throw done(err);
            expect(res.rows).to.not.equal(0);
            done();
          });
      });
    });


  });

});
