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



exports.getCombinedDuration = async (courseId) => {
  try {
    const lessonsSnapshot = await CourseCollection.doc(courseId)
                                   .collection('lessons')
                                   .get();

    let totalSeconds = 0;

    lessonsSnapshot.forEach(doc => {
      const duration = doc.data().duration;
      const [minutes, seconds] = duration.split(':').map(Number);
      totalSeconds += minutes * 60 + seconds;
    });

    const totalMinutes = Math.floor(totalSeconds / 60);
    const totalHours = Math.floor(totalMinutes / 60);
    const remainingMinutes = totalMinutes % 60;

    let result;
    if (totalHours > 0) {
      result = `${totalHours}h ${remainingMinutes}m`;
    } else if (totalMinutes > 0) {
      result = `${totalMinutes}m`;
    } else {
      result = '0';
    }

    return result;
  } catch (error) {
    console.error("Error getting combined duration: ", error);
    throw new Error("Failed to get combined duration");
  }
};