const { firestore } = require('firebase-admin');
const { EnrollmentCollection, CourseCollection } = require('./Collections');

exports.createEnrollment = async (data) => {
    try {
        const docRef = EnrollmentCollection.doc();
        await docRef.set({
            ...data,
            status: "enrolled",
            enrollmentDay: firestore.FieldValue.serverTimestamp(),
            downloadedLessons: []
        });

        // +1 student
        const courseRef = CourseCollection.doc(data.courseId);
        await courseRef.update({
            students: firestore.FieldValue.increment(1)
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

exports.getProgressOfEnrollment = async (enrollmentId) => {
    try {
        const docRef = EnrollmentCollection.doc(enrollmentId);
        const doc = await docRef.get();

        if (!doc.exists) {
            throw new Error('Enrollment not found');
        }

        const data = doc.data();
        return data.progress || [];
    } catch (error) {
        console.error('Error getting progress of enrollment:', error);
        throw error;
    }
};


exports.addProgressToEnrollment = async (enrollmentId, data) => {
    try {
        const docRef = EnrollmentCollection.doc(enrollmentId);
        await docRef.update({
            progress: firestore.FieldValue.arrayUnion(data)
        });
        console.log(data);
        return { "message": "Progress added successfully" };
    } catch (error) {
        console.error('Error adding progress to enrollment:', error);
        throw error;
    }
};


