const { firestore } = require('firebase-admin');
const { EnrollmentCollection } = require('./Collections');

exports.createEnrollment = async (data) => {
    try {
        const docRef = EnrollmentCollection.doc();
        await docRef.set({
            ...data,
            status: "enrolled",
            enrollmentDay: firestore.FieldValue.serverTimestamp(),
            downloadedLessons: []
        });
        return { "enrollmentId": docRef.id };
    } catch (error) {
        console.error('Error creating enrollment:', error);
        throw error;
    }
};

exports.checkEnrollment = async (userId, courseId) => {
    try {
        const enrollmentSnapshot = await EnrollmentCollection
          .where('userId', '==', userId)
          .where('courseId', '==', courseId)
          .get();
    
        if (enrollmentSnapshot.empty) {
          return null;
        }
    
        else{
            const enrollment = enrollmentSnapshot.docs[0];
            return { isEnrolled: true, enrollmentId: enrollment.id };
        }
    
      } catch (error) {
        throw new Error('Error retrieving enrollment: ' + error.message);
      }
};

exports.getUserEnrollments = async (userId) => {
    try {
        const snapshot = await EnrollmentCollection
            .where('userId', '==', userId)
            .get();

        if (snapshot.empty) {
            return [];
        }

        const enrollments = [];
        snapshot.forEach(doc => {
            enrollments.push({ id: doc.id, ...doc.data() });
        });

        return enrollments;
    } catch (error) {
        console.error('Error getting user enrollments:', error);
        throw error;
    }
};

exports.addLessonToEnrollment = async (enrollmentId, lessonId) => {
    try {
        const docRef = EnrollmentCollection.doc(enrollmentId);
        await docRef.update({
            downloadedLessons: firestore.FieldValue.arrayUnion(lessonId)
        });
        return { "message": "Lesson added successfully" };
    } catch (error) {
        console.error('Error adding lesson to enrollment:', error);
        throw error;
    }
};

exports.getDownloadedLessons = async (userId) => {
    try {
        const snapshot = await EnrollmentCollection
            .where('userId', '==', userId)
            .get();

        if (snapshot.empty) {
            return [];
        }

        const downloadedCourses = [];
        snapshot.forEach(doc => {
            const data = doc.data();
            downloadedCourses.push({
                courseId: data.courseId,
                downloadedLessons: data.downloadedLessons
            });
        });

        return downloadedCourses;
    } catch (error) {
        console.error('Error getting downloaded lessons:', error);
        throw error;
    }
};

