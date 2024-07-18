const express = require('express');
const router = express.Router();
const QuizController = require('../app/controllers/QuizController');

router.get('/:courseId', QuizController.getQuizzesByCourseId);
router.post('/', QuizController.createQuiz);
router.post('/:quizId/questions', QuizController.addQuestionToQuiz); //
router.delete('/:quizId', QuizController.deleteQuiz);
router.patch('/:quizId', QuizController.updateQuiz);
module.exports = router;
