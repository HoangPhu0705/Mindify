const { initializeApp } = require('firebase/app');
// const { getAuth } = require('firebase-admin/auth');
const { getAuth, signInWithEmailAndPassword } = require('firebase/auth');
const dotenv = require('dotenv');

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
const signInUser = async (email, password) => {
  try {
    const userCredential = await signInWithEmailAndPassword(auth, email, password);
    const token = await userCredential.user.getIdToken();
    return token;
  } catch (error) {
    console.error('Error signing in:', error);
  }
};
let token;
describe('Firebase Authentication', () => {
  it('should log in and retrieve ID token', async () => {
    const email = 'hieuga678902003@gmail.com';
    const password = '123456';

    token = await signInUser(email, password);
    // token = idToken.token
    expect(token).toBeDefined();
    console.log('Retrieved ID token Hieu Pham:', JSON.stringify(token));
    console.log('Token:', token);

  });
});

module.exports = { signInUser };
