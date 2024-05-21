const admin = require('firebase-admin');
const serviceAccount = require('./firebaseServiceAccountKey.json'); //service account key JSON file

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: 'https://midtermflutter-9c698.firebaseio.com' // database URL
});

const db = admin.firestore();

module.exports = db;
