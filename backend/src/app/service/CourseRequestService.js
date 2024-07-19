const { CourseRequestCollection, CourseCollection, UserCollection } = require('./Collections');
const { firestore } = require('firebase-admin');
const admin = require('firebase-admin');
const { transporter } = require('../../utils/sender.util');

const sendEmail = async (email, subject, content) => {
    const mailOptions = {
        from: process.env.EMAIL_USER,
        to: email,
        subject: subject,
        html: content
    };

    return transporter.sendMail(mailOptions);
};

exports.getRequests = async (limit, startAfter) => {
    try {
        let query = CourseRequestCollection.orderBy('createdAt').limit(limit);

        if (startAfter) {
            const lastDoc = await CourseRequestCollection.doc(startAfter).get();
            query = query.startAfter(lastDoc);
        }

        const snapshot = await query.get();
        if (snapshot.empty) {
            return { requests: [], totalCount: 0 };
        }

        const requests = [];
        snapshot.forEach(doc => {
            requests.push({ id: doc.id, ...doc.data() });
        });

        const totalCountSnapshot = await CourseRequestCollection.get();
        const totalCount = totalCountSnapshot.size;

        return { requests, totalCount };
    } catch (error) {
        throw new Error(`Error happened when fetching unapproved requests: ${error.message}`);
    }
};

exports.sendRequest = async (courseId) => {
  try {
      // get course data
      const courseDoc = await CourseCollection.doc(courseId).get();
      if (!courseDoc.exists) {
          throw new Error('Course not found');
      }

      const courseData = courseDoc.data();
      console.log('Course Data:', courseData);

      // Get user data from Firestore
      const userDoc = await UserCollection.doc(courseData.authorId).get();
      const userData = userDoc.data();
      console.log('User Data:', userData);

      const displayName = userData.displayName || 'Unknown Author';

      // create request
      const request = await CourseRequestCollection.add({
          courseName: courseData.courseName,
          coursePrice: courseData.price,
          author: displayName,
          email: userData.email,
          createdAt: firestore.FieldValue.serverTimestamp(),
          courseId: courseId
      });

      // update request of course
      await CourseCollection.doc(courseId).update({
          request: true
      });

      console.log('Request sent successfully');
      return request;
  } catch (error) {
      console.error('Error occurred:', error);
      throw new Error(`Error happened when sending request: ${error.message}`);
  }
};


exports.approveRequest = async (requestId) => {
    try {
        const requestDoc = await CourseRequestCollection.doc(requestId).get();

        if (!requestDoc.exists) {
            throw new Error('Request not found');
        }

        const requestData = requestDoc.data();
        const courseId = requestData.courseId;
        const email = requestData.email;
        const author = requestData.author;
        const courseName = requestData.courseName;

        // Update the course status to approved
        await CourseCollection.doc(courseId).update({
            status: 'approved'
        });

        // Delete the request document
        await CourseRequestCollection.doc(requestId).delete();

        const content = `
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Course Approval Notification</title>
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
    <h1>Course Approval Notification</h1>
    <p>Hello ${author},</p>
    <p>Your course: ${courseName} has been approved and is now available on our platform.</p>
    <p>Best regards,<br>
    Mindify Team</p>
  </div>
</body>
</html>
`;

        await sendEmail(email, "Your Mindify Course Was Approved", content);

        console.log('Request approved successfully');
        return { message: 'Request approved successfully' };
    } catch (error) {
        throw new Error(`Error happened when approving request: ${error.message}`);
    }
};

exports.rejectRequest = async (requestId) => {
    try {
        const requestDoc = await CourseRequestCollection.doc(requestId).get();

        if (!requestDoc.exists) {
            throw new Error('Request not found');
        }

        const requestData = requestDoc.data();
        const courseId = requestData.courseId;
        const email = requestData.email;
        const author = requestData.author;
        const courseName = requestData.courseName;

        // Update the course request status to false
        await CourseCollection.doc(courseId).update({
            request: false
        });

        // Delete the request document
        await CourseRequestCollection.doc(requestId).delete();

        const content = `
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Course Rejection Notification</title>
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
    <h1>Course Rejection Notification</h1>
    <p>Hello ${author},</p>
    <p>We regret to inform you that your course: ${courseName} has been rejected due to a violation of our terms of service.</p>
    <p>Best regards,<br>
    Mindify Team</p>
  </div>
</body>
</html>
`;

        await sendEmail(email, "Your Mindify Course Was Rejected", content);

        console.log('Request rejected successfully');
        return { message: 'Request rejected successfully' };
    } catch (error) {
        throw new Error(`Error happened when rejecting request: ${error.message}`);
    }
};
