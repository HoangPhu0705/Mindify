class StudentController {

    getAllStudents(req, res){
        res.send("All students");
    }


}

module.exports = new StudentController();
