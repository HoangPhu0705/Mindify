require('dotenv').config();
const admin = require('firebase-admin');
const {getFirestore} = require('firebase-admin/firestore')
const serviceAccount = require("./" + process.env.GOOGLE_APPLICATION_CREDENTIALS); //service account key JSON file
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: 'mindify-d1d55.firebaseapp.com' // database URL
});

const db = getFirestore();
module.exports = {db};

