const  CourseService = require('../service/CourseService');

exports.getAllCourses = async (req, res) => {
  



  try {
    const courses = await CourseService.getAllCourses;
    res.status(200).json(courses);
  } catch (error) {
    res.status(500).send(error.message);
  }
};

exports.createCourse = async (req, res) => {
  const course = req.body;
  const courseId = await CourseService.createCourse(course);
  res.status(201).send({ id: courseId, ...course });
}

exports.getCourseById = async (req, res) => {
  const course = await CourseService.getCourseById(req.params.id);
  res.send(course);
};

exports.updateCourse = async (req, res) => {
  const updates = req.body;
  await CourseService.updateCourse(req.params.id, updates);
  res.sendStatus(204);
};

exports.deleteCourse = async (req, res) => {
  await CourseService.deleteCourse(req.params.id);
  res.sendStatus(204);
};