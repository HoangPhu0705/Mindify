// service/CourseService.js
const { CourseCollection } = require('./Collections');

// Ví dụ CRUD đơn giản
const getAllCourses = async () => {
  const snapshot = await CourseCollection.get();
  const courses = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
  return courses;
};

const createCourse = async (course) => {
  const result = await CourseCollection.add(course);
  return result.id;
};

const getCourseById = async (id) => {
  const doc = await CourseCollection.doc(id).get();
  if (!doc.exists) {
    throw new Error('Course not found');
  }
  return { id: doc.id, ...doc.data() };
};

const updateCourse = async (id, updates) => {
  await CourseCollection.doc(id).update(updates);
  return getCourseById(id);
};

const deleteCourse = async (id) => {
  await CourseCollection.doc(id).delete();
};

module.exports = {
  getAllCourses,
  createCourse,
  getCourseById,
  updateCourse,
  deleteCourse
};
