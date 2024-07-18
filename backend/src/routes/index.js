const courseRouter = require('./courses');
const userRouter = require('./users');
const enrollmentRouter = require('./enrollments');
const folderRouter = require('./folders')
const transactionRouter = require('./transactions')
const quizRouter = require('./quizzes')
const adminAuthRouter = require('./adminAuth')
const qqRouter = require('./qq');
function route(app){
    app.use('/admin', adminAuthRouter)
    app.use('/api/courses', courseRouter)
    app.use('/api/users', userRouter)
    app.use('/api/enrollments', enrollmentRouter)
    app.use('/api/folders', folderRouter)
    app.use('/api/transactions', transactionRouter)
    app.use('/api/quizzes', quizRouter)
    app.use('/lon', qqRouter)
}

module.exports = route


