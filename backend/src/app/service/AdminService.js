const { initializeApp } = require('firebase/app');
// const { getAuth } = require('firebase-admin/auth');
const { getAuth, signInWithEmailAndPassword } = require('firebase/auth');
const { generateToken } = require('../../utils/jwt.util');
const { UserCollection, CourseCollection } = require('./Collections')
const { transporter } = require('../../utils/sender.util')
const dotenv = require('dotenv');
const admin = require('firebase-admin');

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

const sendEmail = async (email, subject, content) => {
    const mailOptions = {
        from: process.env.EMAIL_USER,
        to: email,
        subject: subject,
        html: content
    };

    return transporter.sendMail(mailOptions);
};

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

        if (decodedToken.admin) {
            console.log('User is an admin, generating JWT...');
            const token = generateToken(uid);
            return { uid, token };
        } else {
            throw new Error('User does not have admin privileges.');
        }
    } catch (error) {
        console.error('Error logging in:', error);
        throw new Error('Error logging in: ' + error.message);
    }
};

const logout = async () => {
    await auth.signOut();
    console.log('User logged out successfully.');
}

// User management
const getAllUsersPaginated = async (limit, startAfter) => {
    try {
        let query = UserCollection.orderBy('email').limit(limit);
        if (startAfter) {
            const startAfterDoc = await UserCollection.doc(startAfter).get();
            query = query.startAfter(startAfterDoc);
        }
        const snapshot = await query.get();
        const totalCountSnapshot = await UserCollection.get();
        const totalCount = totalCountSnapshot.size;

        const users = await Promise.all(snapshot.docs.map(async (doc) => {
            const userData = doc.data();
            const userRecord = await admin.auth().getUser(doc.id);
            return {
                id: doc.id,
                email: userData.email,
                displayName: userData.displayName,
                role: userData.role,
                disabled: userRecord.disabled,
            };
        }));

        return { users, totalCount };
    } catch (error) {
        console.error('Error getting users: ', error);
        throw new Error('Error getting users: ' + error.message);
    }
};

// Course management
const getAllCoursesPaginated = async (limit, startAfter) => {
    try {
        let query = CourseCollection.orderBy('courseName').limit(limit);
        if (startAfter) {
            const startAfterDoc = await CourseCollection.doc(startAfter).get();
            query = query.startAfter(startAfterDoc);
        }
        const snapshot = await query.get();
        const totalCountSnapshot = await CourseCollection.get();
        const totalCount = totalCountSnapshot.size;

        const courses = snapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data()
        }));
        return { courses, totalCount };
    } catch (error) {
        console.error('Error getting courses: ', error);
        throw new Error('Error getting courses: ' + error.message);
    }
};
// lock user
const lockUser = async (uid) => {
    try {
        const user = await admin.auth().getUser(uid);
        const content = `
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Account Lock Notification</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      margin: 0;
    }
    
    .container {
      max-width: 600px;
      margin: 0 auto;
    }
    
    h1 {
      color: #333;
    }
    
    p {
      color: #555;
      line-height: 1.5;
    }
  </style>
</head>
<body>
  <div class="container">
    <h1>Account Lock Notification</h1>
    <p>Hello ${user.displayName},</p>
    <p>We regret to inform you that your Mindify account has been locked due to a violation of our terms of service. Please contact our customer support team for guidance on how to unlock your account.</p>
    <p>Best regards,<br>
    Mindify Team</p>
  </div>
</body>
</html>
`;
        await admin.auth().updateUser(uid, {
            disabled: true
        });
        await sendEmail(user.email, "You Mindify Account Was Locked", content);
        return `Successfully lock user ${uid}`;
    } catch (error) {
        throw new Error('Error when lock user: ' + error.message);
    }
};

// unlock user
const unlockUser = async (uid) => {
    try {
        const user = await admin.auth().getUser(uid);
        const content = `
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Account Unlock Notification</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      margin: 0;
    }
    
    .container {
      max-width: 600px;
      margin: 0 auto;
    }
    
    h1 {
      color: #333;
    }
    
    p {
      color: #555;
      line-height: 1.5;
    }
  </style>
</head>
<body>
  <div class="container">
    <h1>Account Lock Notification</h1>
    <p>Hello ${user.displayName},</p>
    <p>We are pleased to inform you that your Mindify account has been successfully unlocked.</p>
    <p>You can now access your account and resume using our platform.</p>
    <p>Best regards,<br>
    Mindify Team</p>
  </div>
</body>
</html>
`;
        await admin.auth().updateUser(uid, {
            disabled: false
        });
        await sendEmail(user.email, "You Mindify Account Was Unlocked", content);

        return `Successfully unlocked user ${uid}`;
    } catch (error) {
        throw new Error('Error when unlocking user: ' + error.message);
    }
};

module.exports = {
    loginUser,
    logout,
    getAllUsersPaginated,
    getAllCoursesPaginated,
    lockUser,
    unlockUser
};
