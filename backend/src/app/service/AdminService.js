const { initializeApp } = require('firebase/app');
// const { getAuth } = require('firebase-admin/auth');
const { getAuth, signInWithEmailAndPassword } = require('firebase/auth');
const { generateToken } = require('../../utils/jwt.util');
const { UserCollection, CourseCollection, EnrollmentCollection, TransactionCollection, ReportCollection } = require('./Collections')
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

    console.log('Fetching custom claims from database or auth system...');
    const customClaims = await admin.auth().getUser(uid).then(userRecord => userRecord.customClaims || {});

    console.log('Generating JWT with custom claims...');
    const token = generateToken(uid, customClaims);
    return { uid, token };
  } catch (error) {
    console.error('Error logging in:', error);
    throw new Error('Error logging in: ' + error.message);
  }
};

const logout = async () => {
  await auth.signOut();
  console.log('User logged out successfully.');
}

const unpublishCourse = async (courseId, authorId, courseName, unpublishReason, reportId) => {
  try {
    const user = await admin.auth().getUser(authorId);
    const content = `
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Course Unpublish Notification</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      margin: 0;
      padding: 20px;
      background-color: #f4f4f4;
    }
    
    .container {
      max-width: 600px;
      margin: 0 auto;
      background-color: #ffffff;
      padding: 20px;
      border-radius: 8px;
      box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
    }
    
    h1 {
      color: #333;
      font-size: 24px;
    }
    
    p {
      color: #555;
      font-size: 16px;
      line-height: 1.6;
    }
  </style>
</head>
<body>
  <div class="container">
    <h1>Course Unpublish Notification</h1>
    <p>Dear ${user.displayName},</p>
    <p>We regret to inform you that your course, <strong>${courseName}</strong>, has been unpublished from our platform. This decision was made due to the following reason:</p>
    <p><em>${unpublishReason}</em></p>
    <p>Please review our terms of service to ensure that your content aligns with our guidelines. We encourage you to make any necessary adjustments and resubmit your course for approval.</p>
    <p>If you have any questions or need further assistance, please feel free to reach out to our support team.</p>
    <p>Best regards,<br>
    The Mindify Team</p>
  </div>
</body>
</html>
`;

    await CourseCollection.doc(courseId).update(
      {
        isPublic: false,
        request: false
      }
    );
    if (reportId != null) {

      await ReportCollection.doc(reportId).delete();
    }
    await sendEmail(user.email, "You Course has been unpublished", content);

    return { "message": "Unpublish course successfully" };
  } catch (error) {
    console.error('Error update course: ', error);
    throw new Error('Error update course: ' + error.message);
  }

}

// User management
const getAllUsersPaginated = async (limit, startAfter, searchQuery) => {
  try {
    let query = UserCollection.orderBy('email').limit(limit);

    // Apply search query if provided
    if (searchQuery) {
      query = query.where('email', '>=', searchQuery)
        .where('email', '<=', searchQuery + '\uf8ff');
    }

    // Apply pagination if provided
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

// transaction management
const getAllTransactionsPaginated = async (limit, startAfter, searchQuery) => {
  try {
    let query = TransactionCollection.where('status', '==', 'succeeded').orderBy('confirmedAt', 'desc').limit(limit);

    // Apply search query if provided
    // if (searchQuery) {
    //   query = query.where('email', '>=', searchQuery)
    //                .where('email', '<=', searchQuery + '\uf8ff');
    // }

    // Apply pagination if provided
    if (startAfter) {
      const startAfterDoc = await TransactionCollection.doc(startAfter).get();
      query = query.startAfter(startAfterDoc);
    }

    const snapshot = await query.get();
    const totalCountSnapshot = await TransactionCollection
      .where('status', '==', 'succeeded') // Filter by status
      .get();
    const totalCount = totalCountSnapshot.size;

    const transactions = await Promise.all(snapshot.docs.map(async (doc) => {
      const transactionData = doc.data();
      const userInfo = await admin.auth().getUser(transactionData.userId);
      return {
        id: doc.id,
        currency: transactionData.currency,
        amount: transactionData.amount,
        confirmedAt: transactionData.confirmedAt,
        userData: {
          User: userInfo.displayName,
          email: userInfo.email,
        }
      }
    })

    )
    console.log(transactions)

    return { transactions, totalCount };
  } catch (error) {
    console.error('Error getting transactions: ', error);
    throw new Error('Error getting transactions: ' + error.message);
  }
};


// Course management
const getAllCoursesPaginated = async (limit, startAfter, searchQuery) => {
  try {
    let query = CourseCollection
      .where('isPublic', '==', true) // Filter by isPublic
      .orderBy('courseName')
      .limit(limit);

    if (searchQuery) {
      query = query.where('courseName', '>=', searchQuery)
        .where('courseName', '<=', searchQuery + '\uf8ff');
    }

    if (startAfter) {
      const startAfterDoc = await CourseCollection.doc(startAfter).get();
      query = query.startAfter(startAfterDoc);
    }

    const snapshot = await query.get();
    const totalCountSnapshot = await CourseCollection
      .where('isPublic', '==', true) // Filter by isPublic
      .get();
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


// Get total number of students across all courses
const getTotalUsers = async () => {
  try {
    const snapshot = await UserCollection.get();
    const totalUsers = snapshot.size;
    return totalUsers;
  } catch (error) {
    console.error('Error getting total students:', error);
    throw new Error('Error getting total students: ' + error.message);
  }
};

// Get total number of students across all courses
const getTotalStudents = async () => {
  try {
    const snapshot = await EnrollmentCollection.get();
    const totalStudents = snapshot.size;

    return totalStudents;
  } catch (error) {
    console.error('Error getting total students:', error);
    throw new Error('Error getting total students: ' + error.message);
  }
};

// Get number of students enroll per month
const getMonthlyEnrollments = async (year) => {
  try {
    const enrollmentsSnapshot = await EnrollmentCollection.get();
    const monthlyEnrollments = {};

    enrollmentsSnapshot.forEach(doc => {
      const enrollmentData = doc.data();
      const enrollmentDay = enrollmentData.enrollmentDay.toDate();

      if (year && enrollmentDay.getFullYear() != year) return;

      const monthKey = `${enrollmentDay.getFullYear()}-${(enrollmentDay.getMonth() + 1).toString().padStart(2, '0')}`;

      if (!monthlyEnrollments[monthKey]) {
        monthlyEnrollments[monthKey] = 0;
      }
      monthlyEnrollments[monthKey]++;
    });

    return monthlyEnrollments;
  } catch (error) {
    console.error('Error getting monthly enrollments:', error);
    throw new Error('Error getting monthly enrollments: ' + error.message);
  }
};

const getYearlyEnrollments = async () => {
  try {
    const enrollmentsSnapshot = await EnrollmentCollection.get();
    const yearlyEnrollments = {};

    enrollmentsSnapshot.forEach(doc => {
      const enrollmentData = doc.data();
      const enrollmentDay = enrollmentData.enrollmentDay.toDate();
      const year = enrollmentDay.getFullYear();

      if (!yearlyEnrollments[year]) {
        yearlyEnrollments[year] = 0;
      }
      yearlyEnrollments[year]++;
    });

    return yearlyEnrollments;
  } catch (error) {
    console.error('Error getting yearly enrollments:', error);
    throw new Error('Error getting yearly enrollments: ' + error.message);
  }
};

const getEnrollmentsByDateRange = async (startDate, endDate) => {
  try {
    const enrollmentsSnapshot = await EnrollmentCollection.get();
    const enrollments = {};

    enrollmentsSnapshot.forEach(doc => {
      const enrollmentData = doc.data();
      const enrollmentDay = enrollmentData.enrollmentDay.toDate();

      if (startDate && endDate && (enrollmentDay < new Date(startDate) || enrollmentDay > new Date(endDate))) return;

      const dateKey = enrollmentDay.toISOString().split('T')[0];

      if (!enrollments[dateKey]) {
        enrollments[dateKey] = 0;
      }
      enrollments[dateKey]++;
    });

    return enrollments;
  } catch (error) {
    console.error('Error getting enrollments:', error);
    throw new Error('Error getting enrollments: ' + error.message);
  }
};

// transactions
const getYearlyRevenue = async () => {
  try {
    const snapshot = await TransactionCollection.where('status', '==', 'succeeded').get();
    const yearlyRevenue = {};

    snapshot.forEach(doc => {
      const transactionData = doc.data();
      const transactionDate = transactionData.createdAt.toDate();
      const year = transactionDate.getFullYear();

      if (!yearlyRevenue[year]) {
        yearlyRevenue[year] = 0;
      }
      yearlyRevenue[year] += transactionData.amount || 0;
    });

    return yearlyRevenue;
  } catch (error) {
    console.error('Error getting yearly revenue:', error);
    throw new Error('Error getting yearly revenue: ' + error.message);
  }
};

const getMonthlyRevenue = async (year) => {
  try {
    const snapshot = await TransactionCollection.where('status', '==', 'succeeded').get();
    const monthlyRevenue = {};

    snapshot.forEach(doc => {
      const transactionData = doc.data();
      const transactionDate = transactionData.createdAt.toDate();

      if (year && transactionDate.getFullYear() != year) return;

      const monthKey = `${transactionDate.getFullYear()}-${(transactionDate.getMonth() + 1).toString().padStart(2, '0')}`;

      if (!monthlyRevenue[monthKey]) {
        monthlyRevenue[monthKey] = 0;
      }
      monthlyRevenue[monthKey] += transactionData.amount || 0;
    });

    return monthlyRevenue;
  } catch (error) {
    console.error('Error getting monthly revenue:', error);
    throw new Error('Error getting monthly revenue: ' + error.message);
  }
};

const getRevenueByDateRange = async (startDate, endDate) => {
  try {
    const snapshot = await TransactionCollection.where('status', '==', 'succeeded').get();

    const revenue = {};

    snapshot.forEach(doc => {
      const transactionData = doc.data();
      // console.log(transactionData)
      const transactionDate = transactionData.createdAt.toDate();

      if (startDate && endDate && (transactionDate < new Date(startDate) || transactionDate > new Date(endDate))) return;

      const dateKey = transactionDate.toISOString().split('T')[0];
      console.log(dateKey)
      // const dateKey1 = new Date(transactionDate.getTime() - transactionDate.getTimezoneOffset() * 60000)
      // console.log(dateKey1)
      // const dateKey = dateKey1.toISOString().split('T')[0];
      if (!revenue[dateKey]) {
        revenue[dateKey] = 0;
      }
      revenue[dateKey] += transactionData.amount || 0;
    });

    return revenue;
  } catch (error) {
    console.error('Error getting revenue by date range:', error);
    throw new Error('Error getting revenue by date range: ' + error.message);
  }
};

const getTotalCourses = async () => {
  try {
    const totalCountSnapshot = await CourseCollection.where('isPublic', '==', true).get();
    const totalCourseCount = totalCountSnapshot.size;
    return totalCourseCount;
  } catch (error) {
    console.error('Error getting total courses:', error);
    throw new Error('Error getting total courses: ' + error.message);
  }

}

const getRevenue = async () => {
  try {
    const snapshot = await TransactionCollection.where('status', '==', 'succeeded').get();
    let totalRevenue = 0;
    snapshot.forEach(doc => {
      const revenue = doc.data();
      totalRevenue += revenue.amount || 0;
    });
    return totalRevenue;
  } catch (error) {
    console.error('Error getting total revenue:', error);
    throw new Error('Error getting total revenue: ' + error.message);
  }
}

const getAllReportsPaginated = async (limit, startAfter, searchQuery) => {
  try {
    let query = ReportCollection.orderBy('timestamp', 'desc').limit(limit);

    // Apply search query if provided
    if (searchQuery) {
      query = query.where('from', '>=', searchQuery)
        .where('from', '<=', searchQuery + '\uf8ff');
    }

    // Apply pagination if provided
    if (startAfter) {
      const startAfterDoc = await ReportCollection.doc(startAfter).get();
      query = query.startAfter(startAfterDoc);
    }

    const snapshot = await query.get();
    const totalCountSnapshot = await ReportCollection.get();
    const totalCount = totalCountSnapshot.size;

    const reports = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));


    console.log(reports)

    return { reports, totalCount };
  } catch (error) {
    console.error('Error getting reports: ', error);
    throw new Error('Error getting reports: ' + error.message);
  }
};

const getEnrollmentsToday = async () => {
  try {
    const today = new Date();
    const startOfToday = new Date(today.setHours(0, 0, 0, 0));
    const endOfToday = new Date(today.setHours(23, 59, 59, 999));
    const result = {}
    const snapshot = await EnrollmentCollection
      .where("enrollmentDay", ">=", admin.firestore.Timestamp.fromDate(startOfToday))
      .where("enrollmentDay", "<=", admin.firestore.Timestamp.fromDate(endOfToday))
      .get();

    const enrollmentsToday = snapshot.size;
    const dateKey = startOfToday.toISOString().split('T')[0];
    result[dateKey] = enrollmentsToday
    return result
  } catch (error) {
    console.error('Error getting enrollments today:', error);
    throw new Error('Error getting enrollments today: ' + error.message);
  }
};


const getRevenueToday = async () => {
  try {
    const today = new Date();
    const startOfToday = new Date(today.setHours(0, 0, 0, 0));
    const endOfToday = new Date(today.setHours(23, 59, 59, 999));
    let total = 0;
    const result = {}

    const snapshot = await TransactionCollection
      .where("confirmedAt", ">=", admin.firestore.Timestamp.fromDate(startOfToday))
      .where("confirmedAt", "<=", admin.firestore.Timestamp.fromDate(endOfToday))
      .get();
    snapshot.forEach(doc => {
      const transactionData = doc.data();
      total += transactionData.amount;
    });
    const dateKey = startOfToday.toISOString().split('T')[0];
    result[dateKey] = total

    return result;
  } catch (error) {
    console.error('Error getting enrollment today:', error);
    throw new Error('Error getting enrollment today: ' + error.message);
  }
}

module.exports = {
  loginUser,
  logout,
  getEnrollmentsToday,
  getRevenueToday,
  getAllUsersPaginated,
  getAllCoursesPaginated,
  getAllTransactionsPaginated,
  getAllReportsPaginated,
  lockUser,
  unlockUser,
  getTotalStudents,
  getMonthlyEnrollments,
  getYearlyEnrollments,
  getEnrollmentsByDateRange,
  getTotalCourses,
  getRevenue,
  getYearlyRevenue,
  getMonthlyRevenue,
  getRevenueByDateRange,
  getTotalUsers,
  unpublishCourse
};
