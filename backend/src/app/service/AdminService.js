const { initializeApp } = require('firebase/app');
const { getAuth, signInWithEmailAndPassword } = require('firebase/auth');
const dotenv = require('dotenv');
const admin = require('firebase-admin');
const jwt = require('jsonwebtoken');

dotenv.config();

const firebaseConfig = {
    apiKey: process.env.FIREBASE_API_KEY,
    authDomain: process.env.FIREBASE_AUTH_DOMAIN,
    projectId: process.env.FIREBASE_PROJECT_ID,
    storageBucket: process.env.FIREBASE_STORAGE_BUCKET,
    messagingSenderId: process.env.FIREBASE_MESSAGING_SENDER_ID,
    appId: process.env.FIREBASE_APP_ID
};

const firebaseApp = initializeApp(firebaseConfig);
const auth = getAuth(firebaseApp);

const loginUser = async (email, password) => {
    try {
        console.log('Attempting to sign in with email:', email);
        const userCredential = await signInWithEmailAndPassword(auth, email, password);
        const user = userCredential.user;

        console.log('User signed in, fetching ID token...');
        const idToken = await user.getIdToken();

        console.log('ID token obtained, verifying token...');
        const decodedToken = await admin.auth().verifyIdToken(idToken);

        const uid = decodedToken.uid;
        console.log('Token verified, generating JWT...');
        const token = generateToken(uid);
        return { uid, token };
    } catch (error) {
        console.error('Error logging in:', error);
        throw new Error('Error logging in: ' + error.message);
    }
};

const generateToken = (uid) => {
    return jwt.sign({ uid }, process.env.JWT_SECRET, { expiresIn: '1h' });
};


const logout = async () => {
    await auth.signOut();
    console.log('User logged out successfully.');
}

module.exports = { loginUser, logout };
