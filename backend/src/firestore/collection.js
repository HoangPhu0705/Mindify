const { getFirestore, collection } = require("firebase/firestore")
const { getAuth } = require("firebase/auth")
const { app } = require("../config")

const database = getFirestore(app)