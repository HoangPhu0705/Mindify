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

exports.addCourses = async (courses) => {
  try {
    const batch = CourseCollection.firestore.batch();

    courses.forEach((courseData) => {
      const { lessons, ...courseInfo } = courseData;
      const courseRef = CourseCollection.doc();

      batch.set(courseRef, courseInfo);

      lessons.forEach((lesson) => {
        const lessonRef = courseRef.collection('lessons').doc();
        batch.set(lessonRef, lesson);
      });
    });

    await batch.commit();
    return { message: "Courses and lessons created successfully" };
  } catch (error) {
    console.error('Error creating courses with lessons:', error);
    throw error;
  }
};

exports.createCourseWithLessons = async (courseData) => {
  const { lessons, ...courseInfo } = courseData;

  try {
    const courseRef = CourseCollection.doc();
    await courseRef.set(courseInfo);

    const lessonsPromises = lessons.map((lesson) => {
      const lessonRef = courseRef.collection('lessons').doc();
      return lessonRef.set(lesson);
    });

    await Promise.all(lessonsPromises);

    return { courseId: courseRef.id, message: "Course and lessons created successfully" };
  } catch (error) {
    console.error('Error creating course with lessons:', error);
    throw error;
  }
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
    // First, get all course IDs
    const snapshot = await CourseCollection.get();
    const allCourseIds = snapshot.docs.map(doc => doc.id);

    // Then, select 5 random IDs
    const randomCourseIds = [];
    for (let i = 0; i < 5; i++) {
      const randomIndex = Math.floor(Math.random() * allCourseIds.length);
      randomCourseIds.push(allCourseIds[randomIndex]);
      allCourseIds.splice(randomIndex, 1); // Remove the selected ID from the array
    }

    // Then, get the full course data for the selected IDs
    const courses = randomCourseIds.map(async id => {
      const doc = await CourseCollection.doc(id).get();
      const lessonsSnapshot = await doc.ref.collection('lessons').get();
      const lessons = lessonsSnapshot.docs.map(lessonDoc => ({
        id: lessonDoc.id,
        ...lessonDoc.data()
      }));
      return {
        id: doc.id,
        ...doc.data(),
        lessons: lessons
      };
    });

    const resolvedCourses = await Promise.all(courses);
    return resolvedCourses;
  } catch (error) {
    console.error('Error fetching random courses:', error);
    throw error;
  }
};

