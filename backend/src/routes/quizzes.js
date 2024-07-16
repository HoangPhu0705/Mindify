const express = require('express');
const router = express.Router();
const QuizController = require('../app/controllers/QuizController');

router.get('/:courseId', QuizController.getQuizzesByCourseId);
router.post('/', QuizController.createQuiz);
router.delete('/:quizId', QuizController.deleteQuiz);

module.exports = router;
