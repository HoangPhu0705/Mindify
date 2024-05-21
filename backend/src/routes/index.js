const courseRouter = require('./courses')
const studentRouter = require('./students');

function route(app){
    app.use('/api/course', courseRouter)
    app.use('/api/student', studentRouter)

}

module.exports = route


