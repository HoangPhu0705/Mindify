const courseRouter = require('./courses');
const userRouter = require('./users');
const enrollmentRouter = require('./enrollments');
const folderRouter = require('./folders')
const transactionRouter = require('./transactions')
const quizRouter = require('./quizzes')
const adminRouter = require('./admin')
const courseRequestRouter = require('./courseRequest')
const projectRouter = require('./project')
const qqRouter = require('./qq');

function route(app){
    app.use('/admin', adminRouter)
    app.use('/api/courses', courseRouter)
    app.use('/api/users', userRouter)
    app.use('/api/enrollments', enrollmentRouter)
    app.use('/api/folders', folderRouter)
    app.use('/api/projects', projectRouter)
    app.use('/api/transactions', transactionRouter)
    app.use('/api/quizzes', quizRouter)
    app.use('/api/courseRequest', courseRequestRouter)
    // app.use('/lon', qqRouter)
}

module.exports = route


