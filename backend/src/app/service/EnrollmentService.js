const { firestore } = require('firebase-admin');
const { EnrollmentCollection } = require('./Collections');

exports.createEnrollment = async (data) => {
    try {
        const docRef = EnrollmentCollection.doc();
        await docRef.set({
            ...data,
            enrollmentDay: firestore.FieldValue.serverTimestamp(),
            downloadedLessons: []
        });
        return { "enrollmentId": docRef.id };
    } catch (error) {
        console.error('Error creating course:', error);
        throw error;
    }
};

exports.checkEnrollment = async (userId, courseId) => {
    try {
        const snapshot = await EnrollmentCollection
            .where('userId', '==', userId)
            .where('courseId', '==', courseId)
            .limit(1)
            .get();

        if (snapshot.empty) {
            return false; 
        } else {
            return true; 
        }
    } catch (error) {
        console.error('Error checking enrollment:', error);
        throw error;
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