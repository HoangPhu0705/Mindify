const { db } = require('../../config/firebase');

const CourseCollection = db.collection("courses");
const TeacherCollection = db.collection("teachers");


module.exports = { CourseCollection, TeacherCollection };