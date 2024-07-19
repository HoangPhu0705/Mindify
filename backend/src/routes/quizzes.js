const express = require('express');
const router = express.Router();
const QuizController = require('../app/controllers/QuizController');

router.get('/:courseId', QuizController.getQuizzesByCourseId);
router.get('/:quizId/questions/:questionId', QuizController.getQuestionById)
router.patch('/:quizId/questions/:questionId', QuizController.updateQuestion)
router.delete('/:quizId/questions/:questionId', QuizController.deleteQuestion)


router.post('/', QuizController.createQuiz);
router.post('/:quizId/questions', QuizController.addQuestionToQuiz); //
router.delete('/:quizId', QuizController.deleteQuiz);
router.patch('/:quizId', QuizController.updateQuiz);
module.exports = router;
