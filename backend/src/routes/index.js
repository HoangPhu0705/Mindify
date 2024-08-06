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
const { authenticate } = require('../app/middleware/auth');

function route(app){
    app.use('/admin', adminRouter)
    app.use('/api/courses', courseRouter)
    app.use('/api/users', userRouter)
    app.use('/api/enrollments', authenticate, enrollmentRouter)
    app.use('/api/folders', authenticate, folderRouter)
    app.use('/api/projects', authenticate, projectRouter)
    app.use('/api/transactions', authenticate, transactionRouter)
    app.use('/api/quizzes', authenticate, quizRouter)
    app.use('/api/courseRequest', courseRequestRouter)
    // app.use('/lon', qqRouter)
}

module.exports = route


