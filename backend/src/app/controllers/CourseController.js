const { createCourse,
  getCourseById,
  getAllCourses,
  updateCourse,
  deleteCourse
} = require('../service/CourseService');

exports.getAllCourses = async (req, res) => {
  try {
    const courses = await getAllCourses;
    res.status(200).json(courses);
  } catch (error) {
    res.status(500).send(error.message);
  }
};
