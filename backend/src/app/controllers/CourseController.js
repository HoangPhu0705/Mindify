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

exports.getCourseByUserId = async (req, res) => {
  const { id } = req.params;
  try {
    const course = await CourseService.getCourseByUserId(id);
    res.status(200).json(course);
  } catch (error) {
    res.status(500).send({ message: 'Error fetching course by user ID', error: error.message });
  }
}







exports.updateLessonCountForCourses = async (req, res) => {
  try {
    const response = await CourseService.updateLessonCountForCourses();
    res.status(200).json(response);
  } catch (error) {
    res.status(500).json({ message: 'Error updating lesson count for courses', error: error.message });
  }
};

exports.changeTheInstructorId = async (req, res) => {
  try {
    const response = await CourseService.changeTheInstructorId();
    res.status(200).json(response);
  } catch (error) {
    res.status(500).json({ message: 'Error adding author Id to all courses', error: error.message });
  }
};

exports.updateAllLessonLinksController = async (req, res) => {
  const { newLink } = req.body;

  if (!newLink) {
    return res.status(400).json({ error: "newLink is required" });
  }

  try {
    const result = await CourseService.updateAllLessonLinks(newLink);
    res.status(200).json(result);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.updateCourseDescriptions = async (req, res, next) => {
  // const { courseId } = req.params; // If courseId is needed
  try {
    const result = await CourseService.updateCourseDescriptions();
    res.status(200).json(result);
  } catch (error) {
    console.error('Error updating course descriptions:', error);
    res.status(500).json({ error: 'Failed to update course descriptions' });
  }
};

exports.getCoursesByCategory = async (req, res) => {
  try {
    const userCategories = req.body.categories; 
    const response = await CourseService.getCoursesByCategory(userCategories);
    res.status(200).json(response);
  } catch (error) {
    res.status(500).send({ message: 'Error happened when getting courses by category', error: error.message });
  }
};