const db = require('../../config/firebase');
const course = require('../models/course.model')
class CourseController {

    getAllCourses(req, res){
        res.send("All course");
    }

    updateCourse(req, res){
        res.send("Course updated");
    }

    deleteCourse(req, res){
        res.send("Course deleted");
    }


    async addCourse(req, res) {
        try {
            const courseData = {
                title: req.body.title,
                description: req.body.description,

                upDay: new Date().toISOString(),
            };

            const course = new Course(null, courseData.title, courseData.description, null, null);

            const docRef = await db.collection('courses').add(course);

            res.status(201).send({ message: 'Course added successfully', courseId: docRef.id });
        } catch (error) {
            console.error('Error adding course: ', error);
            res.status(500).send('Error adding course');
        }
    }
}

module.exports = new CourseController();
