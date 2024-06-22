const courseRouter = require('./courses');
const studentRouter = require('./students');
const teacherRouter = require('./teachers');
const userRouter = require('./users');
function route(app){
    app.use('/api/courses', courseRouter)
    app.use('/api/users', userRouter)
    app.use('/api/teacher', teacherRouter)
    // app.use('/api/course:courseId/lesson', lessonRouter)
}

module.exports = route


