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


exports.addQuestionToQuiz = async (quizId, questionData) => {
    try {
        const questionsCollection = QuizCollection.doc(quizId).collection('questions');
        const questionRef = questionsCollection.doc();
        await questionRef.set({
            ...questionData,
            createdAt: firestore.FieldValue.serverTimestamp(),
        });
        return questionRef.id;
    } catch (error) {
        console.error('Error adding question to quiz:', error);
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

exports.updateQuiz = async (quizId, data) => {
    try{
        await QuizCollection.doc(quizId).update(data);
        return {success: true}
    }catch (error) {
        console.error('Error updating quiz:', error);
        throw error;
    }
}

exports.getQuestionById = async (quizId, questionId) => {
    try {
        const questionRef = QuizCollection.doc(quizId).collection('questions').doc(questionId);
        const questionDoc = await questionRef.get();
        if (!questionDoc.exists) {
            throw new Error('Question not found');
        }
        return { id: questionDoc.id, ...questionDoc.data() };
    } catch (error) {
        console.error('Error getting question by ID:', error);
        throw error;
    }
};

exports.updateQuestion = async (quizId, questionId, data) => {
    try {
        const questionRef = QuizCollection.doc(quizId).collection('questions').doc(questionId);
        await questionRef.update(data);
        return { success: true };
    } catch (error) {
        console.error('Error updating question:', error);
        throw error;
    }
};


exports.deleteQuestion = async (quizId, questionId) => {
    try {
        const questionRef = QuizCollection.doc(quizId).collection('questions').doc(questionId);
        await questionRef.delete();
        return { success: true };
    } catch (error) {
        console.error('Error deleting question:', error);
        throw error;
    }
}

exports.getQuizzById = async (quizId) => {
    try {
        const quizDoc = await QuizCollection.doc(quizId).get();
        if (!quizDoc.exists) {
            throw new Error('Quiz not found');
        }
        return { id: quizDoc.id, ...quizDoc.data() };
    }catch(error){
        console.error('Error getting quiz by ID:', error);
        throw error;
    }
}

exports.getQuestionByQuizzId = async (quizId) => {
    try {
        const questionsSnapshot = await QuizCollection.doc(quizId).collection('questions').orderBy("index", 'desc').get();
        if (questionsSnapshot.empty) {
            return [];
        }

        const questions = [];
        questionsSnapshot.forEach(doc => {
            questions.push({ id: doc.id, ...doc.data() });
        });

        return questions;
    } catch (error) {
        console.error('Error fetching questions:', error);
        throw error;
    }
}


