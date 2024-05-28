const coursesService = require('../service/course.service');
exports.getAllCourses = async (req, res) => {
    try {
      const courses = await coursesService.getAllCourses();
      res.status(200).json(courses);
    } catch (error) {
      res.status(500).send(error.message);
    }
  };
exports.createCourse = async (req, res) => {
  try {
    const newCourse = req.body;
    const courseId = await coursesService.createCourse(newCourse);
    res.status(201).json({ id: courseId });
  } catch (error) {
    res.status(400).send(error.message);
  }
};

exports.updateCourse = async (req, res) => {
  try {
    const courseId = req.params.id;
    const updates = req.body;
    await coursesService.updateCourse(courseId, updates);
    res.status(200).json({ message: "Course updated successfully" });
  } catch (error) {
    res.status(404).send(error.message);
  }
};

exports.deleteCourse = async (req, res) => {
  try {
    const courseId = req.params.id;
    await coursesService.deleteCourse(courseId);
    res.status(204).send();
  } catch (error) {
    res.status(404).send(error.message);
  }
};

exports.getCourseById = async (req, res) => {
  try {
    const courseId = req.params.id;
    const course = await coursesService.getCourseById(courseId);
    res.status(200).json(course);
  } catch (error) {
    res.status(404).send(error.message);
  }
};
