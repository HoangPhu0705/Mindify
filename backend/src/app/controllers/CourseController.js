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


    
    


}

module.exports = new CourseController();
