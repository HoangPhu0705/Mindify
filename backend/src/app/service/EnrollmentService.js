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