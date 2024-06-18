const CourseService = require('../service/CourseService');

class CourseController {
  getAllCourses = async (req, res) => {
    try {
      const courses = await CourseService.getAllCourses();
      res.status(200).json(courses);
    } catch (error) {
      res.status(500).send(error.message);
    }
  };
  
  createCourse = async (req, res) => {
    try {
      const course = req.body;
      const courseId = await CourseService.createCourse(course);
      res.status(201).send({ id: courseId, ...course });
    } catch (error) {
      res.status(500).send({ message: 'Error creating course', error: error.message });
    }
  };
  
  getCourseById = async (req, res) => {
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
  
  updateCourse = async (req, res) => {
    try {
      const updates = req.body;
      await CourseService.updateCourse(req.params.id, updates);
      res.sendStatus(204);
    } catch (error) {
      res.status(500).send({ message: 'Error updating course', error: error.message });
    }
  };
  
  deleteCourse = async (req, res) => {
    try {
      await CourseService.deleteCourse(req.params.id);
      res.sendStatus(204);
    } catch (error) {
      res.status(500).send({ message: 'Error deleting course', error: error.message });
    }
  };
  
  getTop5Courses = async (req, res) => {
    try {
      const courses = await CourseService.getTop5Courses();
      res.status(200).json(courses);
    } catch (error) {
      res.status(500).send(error.message);
    }
    
  };
  
  getRandomCourses = async (req, res) => {
    try {
      const courses = await CourseService.getRandomCourses();
      res.status(200).json(courses);
    } catch (error) {
      res.status(500).send(error.message);
    }
  };
  
}

module.exports = new CourseController();
