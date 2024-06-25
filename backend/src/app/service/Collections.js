const { db } = require('../../config/firebase');

const CourseCollection = db.collection("courses");
const UserCollection = db.collection("users");
const LessonCollection = db.collection("lessons");
const RequestCollection = db.collection("requests");


module.exports = { CourseCollection, UserCollection, LessonCollection, RequestCollection };