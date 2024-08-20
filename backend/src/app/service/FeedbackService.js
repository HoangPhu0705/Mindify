const { firestore } = require('firebase-admin');
const { CourseCollection } = require('./Collections');
// const admin = require('firebase-admin');

exports.giveFeedback = async (courseId, userId, feedback) => {
    try {
        const newFeedback = {
            ...feedback,
            userId: userId,
            createdAt: firestore.FieldValue.serverTimestamp(),
        };
    
        const docRef = await CourseCollection.doc(courseId).collection('feedbacks').add(newFeedback);
        
        return { feedbackId: docRef.id, newFeedback };
    } catch (error) {
        console.error("Error submitting feedback:", error);
        return { error };
    }
};

exports.ratingOfCourse = async (courseId) => {
    try {
        const feedbacksSnapshot = await CourseCollection.doc(courseId).collection('feedbacks').get();

        if (feedbacksSnapshot.empty) {
            return 0;
        }

        let totalRating = 0;
        let count = 0;

        feedbacksSnapshot.forEach(doc => {
            const feedback = doc.data();
            if (feedback.rating && typeof feedback.rating === 'number') {
                totalRating += feedback.rating;
                count++;
            }
        });

        const averageRating = count > 0 ? totalRating / count : 0.0;
        console.log(averageRating); 

        return parseFloat(averageRating.toFixed(2));
    } catch (error) {
        console.log("Error getting rating of course", error);
        return 0; 
    }
};
