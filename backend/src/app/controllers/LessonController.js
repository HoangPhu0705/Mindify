const LessonService = require('../service/LessonService');

exports.getAllLesson = async (req, res) => {
    try {
        const lessons = await LessonService.getAllLessons(req.params.courseId);
        res.status(200).send(lessons);
    } catch (error) {
        res.status(500).send({ message: 'Internal Server Error', error: error.message });
    }
};

exports.createLesson = async (req, res) => {
    try {
        const lessonId = await LessonService.createLesson(req.params.courseId, req.body);
        res.status(201).send({ lessonId });
      } catch (error) {
        res.status(500).send({ message: 'Internal Server Error', error });
      }
}

exports.getLessonById = async (req, res) => {
    try {
        const lesson = await LessonService.getLessonById(req.params.courseId, req.params.lessonId);
        if (lesson) {
          res.status(200).send(lesson);
        } else {
          res.status(404).send({ message: 'Lesson not found' });
        }
      } catch (error) {
        res.status(500).send({ message: 'Internal Server Error', error });
      }
};

exports.updateLesson = async (req, res) => {
    try {
        await LessonService.updateLesson(req.params.courseId, req.params.lessonId, req.body);
        res.status(204).send();
      } catch (error) {
        res.status(500).send({ message: 'Internal Server Error', error });
      }
};

exports.deleteLesson = async (req, res) => {
    try {
        await LessonService.deleteLesson(req.params.courseId, req.params.lessonId);
        res.status(204).send();
      } catch (error) {
        res.status(500).send({ message: 'Internal Server Error', error });
      }
};