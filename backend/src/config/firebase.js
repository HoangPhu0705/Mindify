require('dotenv').config();
const admin = require('firebase-admin');
const {getFirestore} = require('firebase-admin/firestore')
// const serviceAccount = require("../etc/secrets/" + process.env.GOOGLE_APPLICATION_CREDENTIALS); //service account key JSON file, use this in local 
const serviceAccount = require("/etc/secrets/mindify-d1d55-firebase-adminsdk-fudzk-1464986a0d.json"); //Use this in production
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: 'mindify-d1d55.firebaseapp.com' // database URL
});

const db = getFirestore();
module.exports = {db};

