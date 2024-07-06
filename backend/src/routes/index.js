const courseRouter = require('./courses');
const userRouter = require('./users');
const enrollmentRouter = require('./enrollments');
const folderRouter = require('./folders')
function route(app){
    app.use('/api/courses', courseRouter)
    app.use('/api/users', userRouter)
    app.use('/api/enrollments', enrollmentRouter)
    app.use('/api/folders', folderRouter)
}

module.exports = route


