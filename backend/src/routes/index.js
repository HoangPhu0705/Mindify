const courseRouter = require('./courses');
const userRouter = require('./users');
const enrollmentRouter = require('./enrollment');
function route(app){
    app.use('/api/courses', courseRouter)
    app.use('/api/users', userRouter)
    app.use('/api/enrollments', enrollmentRouter)
    // app.use('/api/course:courseId/lesson', lessonRouter)
}

module.exports = route


