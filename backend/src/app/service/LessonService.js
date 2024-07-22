const { CourseCollection } = require('./Collections');

exports.getAllLessons = async (courseId) => {
  try {
    const lessonsSnapshot = await CourseCollection.doc(courseId).collection('lessons').get();
    const lessons = lessonsSnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    return lessons;
  } catch (error) {
    console.error('Error getting all lessons:', error);
    throw error;
  }
};

exports.createLesson = async (courseId, lesson) => {
  try {
    const lessonRef = CourseCollection.doc(courseId).collection('lessons').doc();
    await lessonRef.set(lesson);
    return lessonRef.id;
  } catch (error) {
    console.error('Error creating lesson:', error);
    throw error;
  }
};

exports.getLessonById = async (courseId, lessonId) => {
  try {
    const lessonDoc = await CourseCollection.doc(courseId).collection('lessons').doc(lessonId).get();
    return lessonDoc.exists ? { id: lessonDoc.id, ...lessonDoc.data() } : null;
  } catch (error) {
    console.error('Error fetching lesson by ID:', error);
    throw error;
  }
};

exports.updateLesson = async (courseId, lessonId, updates) => {
  try {
    await CourseCollection.doc(courseId).collection('lessons').doc(lessonId).update(updates);
  } catch (error) {
    console.error('Error updating lesson:', error);
    throw error;
  }
};

exports.deleteLesson = async (courseId, lessonId) => {
  try {
    await CourseCollection.doc(courseId).collection('lessons').doc(lessonId).delete();
  } catch (error) {
    console.error('Error deleting lesson:', error);
    throw error;
  }
};


const durationToSeconds = (duration) => {
  const [hours, minutes] = duration.split(':').map(Number);
  return hours * 3600 + minutes * 60;
};

// Helper function to convert seconds to "HH:MM"
const secondsToDuration = (seconds) => {
  const hours = Math.floor(seconds / 3600);
  const minutes = Math.floor((seconds % 3600) / 60);
  return `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}`;
};

exports.getCombinedDuration = async (courseId) => {
  try {
    const lessonsSnapshot = await CourseCollection.doc(courseId).collection('lessons').get();
    const totalSeconds = lessonsSnapshot.docs.reduce((acc, doc) => {
      const { duration } = doc.data();
      return acc + durationToSeconds(duration);
    }, 0);
    return secondsToDuration(totalSeconds);
  } catch (error) {
    console.error('Error getting combined duration:', error);
    throw error;
  }
};
