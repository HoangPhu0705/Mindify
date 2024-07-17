const { QuizCollection, CourseCollection } = require("./Collections");
const { firestore } = require('firebase-admin');

exports.createQuiz = async (data) => {
    try {
        const docRef = QuizCollection.doc();
        await docRef.set({
            ...data,
            createdAt: firestore.FieldValue.serverTimestamp(),
        });
        return docRef.id;
    } catch (error) {
        console.error('Error creating quizz:', error);
        throw error;
    }
};

exports.getQuizzesByCourseId = async (courseId) => {
    try {
        const quizzesSnapshot = await QuizCollection.where('courseId', '==', courseId).get();
        if (quizzesSnapshot.empty) {
            return [];
        }

        const quizzes = [];
        quizzesSnapshot.forEach(doc => {
            quizzes.push({ id: doc.id, ...doc.data() });
        });

        return quizzes;
    } catch (error) {
        console.error('Error fetching quizzes:', error);
        throw error;
    }
};

exports.deleteQuiz = async (quizId) => {
    try {
        await QuizCollection.doc(quizId).delete();
        return { success: true };
    } catch (error) {
        console.error('Error deleting quiz:', error);
        throw error;
    }
};
