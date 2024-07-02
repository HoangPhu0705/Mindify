const CourseService = require('../service/CourseService');

exports.getAllCourses = async (req, res) => {
  try {
    const courses = await CourseService.getAllCourses();
    res.status(200).json(courses);
  } catch (error) {
    res.status(500).send(error.message);
  }
};


exports.getPublicCourse = async (req, res) => {
  try {
    const courses = await CourseService.getPublicCourses();
    res.status(200).json(courses);
  } catch (error) {
    res.status(500).send(error.message);
  }

}

exports.addCourses = async (req, res) => {
  try {
    const courses = req.body;
    const response = await CourseService.addCourses(courses);

    res.status(201).json(response);
  } catch (error) {
    res.status(500).send({ message: 'Error creating courses with lessons', error: error.message });
  }
};


exports.createCourseWithLessons = async (req, res) => {
  try {
    const courseData = req.body;
    const response = await CourseService.createCourseWithLessons(courseData);
    res.status(201).json(response);
  } catch (error) {
    res.status(500).send({ message: 'Error creating course with lessons', error: error.message });
  }
};

exports.createCourse = async (req, res) => {
  try {
    const course = req.body;
    console.log(course);
    const courseId = await CourseService.createCourse(course);
    res.status(201).send({ id: courseId});
  } catch (error) {
    res.status(500).send({ message: 'Error creating course', error: error.message });
  }
};

exports.getCourseById = async (req, res) => {
  try {
    const course = await CourseService.getCourseById(req.params.id);
    if (course) {
      res.status(200).send(course);
    } else {
      res.status(404).send({ message: 'Course not found' });
    }
  } catch (error) {
    res.status(500).send({ message: 'Error fetching course by ID', error: error.message });
  }
};

exports.updateCourse = async (req, res) => {
  try {
    const updates = req.body;
    await CourseService.updateCourse(req.params.id, updates);
    res.sendStatus(204);
  } catch (error) {
    res.status(500).send({ message: 'Error updating course', error: error.message });
  }
};

exports.deleteCourse = async (req, res) => {
  try {
    await CourseService.deleteCourse(req.params.id);
    res.sendStatus(204);
  } catch (error) {
    res.status(500).send({ message: 'Error deleting course', error: error.message });
  }
};

exports.getTop5Courses = async (req, res) => {
  try {
    const courses = await CourseService.getTop5Courses();
    res.status(200).json(courses);
  } catch (error) {
    res.status(500).send(error.message);
  }
};

exports.getFiveNewestCourse = async (req, res) => {
  try {
    const courses = await CourseService.getFiveNewestCourse();
    res.status(200).json(courses);
  } catch (error) {
    res.status(500).send(error.message);
  }
};

exports.getRandomCourses = async (req, res) => {
  try {
    const courses = await CourseService.getRandomCourses();
    res.status(200).json(courses);
  } catch (error) {
    res.status(500).send(error.message);
  }
};
// bonus price
exports.addPriceToAllCourses = async (req, res) => {
  try {
    const response = await CourseService.addPriceToAllCourses();
    res.status(200).json(response);
  } catch (error) {
    res.status(500).json({ message: 'Error adding price to all courses', error: error.message });
  }
};

exports.updateLessonLinkByIndex = async (req, res) => {
  const { index, newLink } = req.body;
  try {
    const response = await CourseService.updateLessonLinkByIndex(index, newLink);
    res.status(200).json(response);
  } catch (error) {
    res.status(500).send({ message: 'Error updating lessons link', error: error.message });
  }
};


