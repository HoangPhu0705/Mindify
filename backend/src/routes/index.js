const courseRouter = require('./courses');
const studentRouter = require('./students');
const teacherRouter = require('./teachers');
function route(app){
    app.use('/api/course', courseRouter)
    // app.use('/api/student', studentRouter)
    app.use('/api/teacher', teacherRouter)
}

module.exports = route


