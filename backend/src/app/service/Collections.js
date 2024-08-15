const { db } = require('../../config/firebase');

const CourseCollection = db.collection("courses");
const UserCollection = db.collection("users");
const LessonCollection = db.collection("lessons");
const RequestCollection = db.collection("requests");
const EnrollmentCollection = db.collection("enrollments");
const TransactionCollection = db.collection("transactions");
const FolderCollection = db.collection("folders");
const QuizCollection = db.collection("quizzes");
const CourseRequestCollection = db.collection("course_requests");
const ReportCollection = db.collection("reports");

module.exports = { CourseCollection, 
                    UserCollection, 
                    LessonCollection, 
                    RequestCollection, 
                    EnrollmentCollection,
                    TransactionCollection,
                    FolderCollection,
                    QuizCollection,
                    CourseRequestCollection,
                    ReportCollection
                 };