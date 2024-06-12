const courseRouter = require('./courses');
const studentRouter = require('./students');
const teacherRouter = require('./teachers');
// const lessonRouter = require('./lessons');
function route(app){
    app.use('/api/course', courseRouter)
    // app.use('/api/student', studentRouter)
    app.use('/api/teacher', teacherRouter)
    // app.use('/api/course:courseId/lesson', lessonRouter)
}

module.exports = route


