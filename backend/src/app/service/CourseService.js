// service/CourseService.js
const { CourseCollection } = require('./Collections');


exports.getAllCourses = async () => {
  const snapshot = await CourseCollection.get();
  const courses = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
  return courses;
};

exports.createCourse = async (course) => {
  try {
    const docRef = CourseCollection.doc();
    await docRef.set(course);
    return docRef.id;
  } catch (error) {
    console.error('Error creating course:', error);
    throw error;
  }
};

exports.getCourseById = async (id) => {
  try {
      const doc = await CourseCollection.doc(id).get();
      return doc.exists ? { id: doc.id, ...doc.data() } : null;
  } catch (error) {
      console.error('Error fetching course by ID:', error);
      throw error;
  }
};

exports.updateCourse = async (id, updates) => {
  try {
      await CourseCollection.doc(id).update(updates);
  } catch (error) {
      console.error('Error updating course:', error);
      throw error;
  }
};

exports.deleteCourse = async (id) => {
  try {
      await CourseCollection.doc(id).delete();
  } catch (error) {
      console.error('Error deleting course:', error);
      throw error;
  }
};
