const { CourseCollection } = require('./Collections');

exports.getAllCourses = async () => {
  const snapshot = await CourseCollection.get();
  const courses = await Promise.all(
    snapshot.docs.map(async doc => {
      const lessonsSnapshot = await doc.ref.collection('lessons').get();
      const lessons = lessonsSnapshot.docs.map(lessonDoc => ({ id: lessonDoc.id, ...lessonDoc.data() }));
      return { id: doc.id, ...doc.data(), lessons };
    })
  );
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
    if (!doc.exists) return null;

    const lessonsSnapshot = await doc.ref.collection('lessons').get();
    const lessons = lessonsSnapshot.docs.map(lessonDoc => ({ id: lessonDoc.id, ...lessonDoc.data() }));

    return { id: doc.id, ...doc.data(), lessons };
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

exports.getTop5Courses = async () => {
  try {
    const snapshot = await CourseCollection.orderBy('popularity', 'desc').limit(5).get();
    const courses = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    return courses;
  } catch (error) {
    console.error('Error fetching top 5 courses:', error);
    throw error;
  }
};

exports.getRandomCourses = async () => {
  try {
    const snapshot = await CourseCollection.get();
    const courses = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    const shuffled = courses.sort(() => 0.5 - Math.random());
    return shuffled.slice(0, 5);
  } catch (error) {
    console.error('Error fetching random courses:', error);
    throw error;
  }
};
