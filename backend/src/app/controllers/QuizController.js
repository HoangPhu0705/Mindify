const QuizService = require("../service/QuizService");

exports.createQuiz = async (req, res) => {
  try {
    const quiz = req.body;
    const quizId = await QuizService.createQuiz(quiz);
    res.status(201).send({ id: quizId });
  } catch (error) {
    res
      .status(500)
      .send({ message: "Error creating quiz", error: error.message });
  }
};

exports.addQuestionToQuiz = async (req, res) => {
  try {
    const { quizId } = req.params;
    const question = req.body;
    const questionId = await QuizService.addQuestionToQuiz(quizId, question);
    res.status(201).send({ id: questionId });
  } catch (error) {
    res
      .status(500)
      .send({ message: "Error adding question to quiz", error: error.message });
  }

}

exports.getQuizzesByCourseId = async (req, res) => {
  try {
    const { courseId } = req.params;
    const quizzes = await QuizService.getQuizzesByCourseId(courseId);
    res.status(200).send(quizzes);
  } catch (error) {
    res
      .status(500)
      .send({ message: "Error fetching quizzes", error: error.message });
  }
};

exports.deleteQuiz = async (req, res) => {
  try {
    await QuizService.deleteQuiz(req.params.quizId);
    res.status(200).json({ message: "Quiz deleted successfully" });
  } catch (error) {
    res.status(500).json({ error: "Failed to delete quiz" });
  }
};

exports.updateQuiz = async (req, res) => {
  try {
    await QuizService.updateQuiz(req.params.quizId, req.body);
    res.status(200).json({ message: "Quiz updated successfully" });

  } catch (error) {
    res.status(500).json({ error: "Failed to update quiz" });
  }
};

exports.getQuestionById = async (req, res) => {
  try {
    const questionData = await QuizService.getQuestionById(req.params.quizId, req.params.questionId);
    res.status(200).send(questionData);

  } catch (error) {
    res.status(500).json({ error: "Failed to update quiz" });
  }
}

exports.updateQuestion = async (req, res) => {
  try {
    await QuizService.updateQuestion(req.params.quizId, req.params.questionId, req.body);
    res.status(204).json({ message: "Question updated successfully" });

  } catch (error) {
    res.status(500).json({ error: "Failed to update question" });
  }
};


