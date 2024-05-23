const db = require('../../config/firebase');
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
            const course = {
                title: req.body.title,
                description: req.body.description,
                createdAt: new Date().toLocaleString(),
            };
            const docRef = await db.collection('courses').add(course);
            res.status(201).send({ message: 'Course added successfully', courseId: docRef.id });
        } catch (error) {
            console.error('Error adding course: ', error);
            res.status(500).send('Error adding course');
        }
    }
}

module.exports = new CourseController();
