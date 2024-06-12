const { db } = require('../../config/firebase');

const CourseCollection = db.collection("courses");
const TeacherCollection = db.collection("teachers");
const LessonCollection = db.collection("lessons");



module.exports = { CourseCollection, TeacherCollection, LessonCollection };