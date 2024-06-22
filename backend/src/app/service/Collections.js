const { db } = require('../../config/firebase');

const CourseCollection = db.collection("courses");
const UserCollection = db.collection("users");
const LessonCollection = db.collection("lessons");



module.exports = { CourseCollection, UserCollection, LessonCollection };