const { firestore } = require('firebase-admin');
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

      batch.set(courseRef, {
        ...courseInfo,
        createdAt: firestore.FieldValue.serverTimestamp(),
      });

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
    await courseRef.set({
      ...courseInfo,
      createdAt: firestore.FieldValue.serverTimestamp(),
    });

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
    await docRef.set({
      ...course,
      createdAt: firestore.FieldValue.serverTimestamp(),
    });
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
    const snapshot = await CourseCollection.where('isPublic', '==', true).orderBy('students', 'desc').limit(5).get();
    const courses = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
    return courses;
  } catch (error) {
    console.error('Error fetching top 5 courses:', error);
    throw error;
  }
};

exports.getFiveNewestCourse = async () => {
  try {
    const snapshot = await CourseCollection.where('isPublic', '==', true).orderBy('createdAt', 'desc').limit(5).get();
    const courses = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
    return courses;
  } catch (error) {
    console.error('Error fetching the newest 5 courses:', error);
    throw error;
  }
};

exports.getRandomCourses = async () => {
  try {
    const snapshot = await CourseCollection.where('isPublic', '==', true).get();
    const allCourseIds = snapshot.docs.map(doc => doc.id);

    const randomCourseIds = [];
    for (let i = 0; i < 5; i++) {
      const randomIndex = Math.floor(Math.random() * allCourseIds.length);
      randomCourseIds.push(allCourseIds[randomIndex]);
      allCourseIds.splice(randomIndex, 1); 
    }

    const courses = randomCourseIds.map(async id => {
      const doc = await CourseCollection.doc(id).get();
      return {
        id: doc.id,
        ...doc.data()
      };
    });

    const resolvedCourses = await Promise.all(courses);
    return resolvedCourses;
  } catch (error) {
    console.error('Error fetching random courses:', error);
    throw error;
  }
};

// bonus func
exports.addPriceToAllCourses = async () => {
  try {
    const snapshot = await CourseCollection.get();
    
    const batch = CourseCollection.firestore.batch();
    const prices = [199000, 249000, 299000, 349000, 399000];
    
    snapshot.docs.forEach(doc => {
      const randomPrice = prices[Math.floor(Math.random() * prices.length)];
      batch.update(doc.ref, { price: randomPrice });
    });
    
    await batch.commit();
    return { message: "Added random price to all courses successfully" };
  } catch (error) {
    console.error('Error adding random price to all courses:', error);
    throw error;
  }
};

exports.updateLessonLinkByIndex = async (index, newLink) => {
  try {
    const snapshot = await CourseCollection.get();

    const batch = CourseCollection.firestore.batch();

    snapshot.docs.forEach((doc) => {
      const lessonsRef = doc.ref.collection('lessons');
      lessonsRef.where('index', '==', index).get().then((lessonsSnapshot) => {
        lessonsSnapshot.docs.forEach((lessonDoc) => {
          batch.update(lessonDoc.ref, { link: newLink });
        });
      });
    });

    await batch.commit();
    return { message: `Updated lessons with index ${index} successfully` };
  } catch (error) {
    console.error('Error updating lessons link:', error);
    throw error;
  };
    
};

exports.getCourseByUserId = async (userId) => {
  try {
    const snapshot = await CourseCollection.where('authorId', '==', userId).get();
    const courses = await Promise.all(
      snapshot.docs.map(async doc => {
        const lessonsSnapshot = await doc.ref.collection('lessons').get();
        const lessons = lessonsSnapshot.docs.map(lessonDoc => ({ id: lessonDoc.id, ...lessonDoc.data() }));
        return { id: doc.id, ...doc.data(), lessons };
      })
    );
    return courses;
  } catch (error) {
    console.error('Error fetching courses by user ID:', error);
    throw error;
  }
}

exports.updateLessonCountForCourses = async () => {
  try {
    const snapshot = await CourseCollection.get();

    const batch = CourseCollection.firestore.batch();

    await Promise.all(snapshot.docs.map(async (doc) => {
      const lessonsSnapshot = await doc.ref.collection('lessons').get();
      const lessonCount = lessonsSnapshot.size;

      batch.update(doc.ref, { lessonNum: lessonCount });
    }));

    await batch.commit();
    return { message: "Updated lesson count for all courses successfully" };
  } catch (error) {
    console.error('Error updating lesson count for courses:', error);
    throw error;
  }
};

exports.changeTheInstructorId = async () => {
  try {
    const snapshot = await CourseCollection.get();
    
    const batch = CourseCollection.firestore.batch();
    const instructorId = ["K0TVyBUIYiag23kc7DQrlrplF853", "JODO8VMzDWfGmcsYgNqNrNrLrt22",
                          "AMAVeLkYQeW1q6U0ZPka5k8FLeL2"];
    
    snapshot.docs.forEach(doc => {
      const randomId = instructorId[Math.floor(Math.random() * instructorId.length)];
      batch.update(doc.ref, { authorId: randomId });
    });
    
    await batch.commit();
    return { message: "Added random id to all courses successfully" };
  } catch (error) {
    console.error('Error adding random id to all courses:', error);
    throw error;
  }
};

exports.updateAllLessonLinks = async (newLink) => {
  try {
    const snapshot = await CourseCollection.get();
    const batch = CourseCollection.firestore.batch();

    for (const doc of snapshot.docs) {
      const lessonsRef = doc.ref.collection('lessons');
      const lessonsSnapshot = await lessonsRef.get();

      lessonsSnapshot.docs.forEach((lessonDoc) => {
        batch.update(lessonDoc.ref, { link: newLink });
      });
    }

    await batch.commit();
    return { message: "All lesson links updated successfully" };
  } catch (error) {
    console.error('Error updating lesson links:', error);
    throw error;
  }
};

exports.updateCourseDescriptions = async () => {
  try {
    const snapshot = await CourseCollection.get();

    const batch = CourseCollection.firestore.batch();

    snapshot.docs.forEach(doc => {
      const courseData = doc.data();
      const projectDescription = courseData.projectDescription || '';
      const description = courseData.description || '';

      const updatedProjectDescription = JSON.stringify([{ "insert": `${projectDescription}\n` }]);
      const updatedDescription = JSON.stringify([{ "insert": `${description}\n` }]);

      batch.update(doc.ref, {
        projectDescription: updatedProjectDescription,
        description: updatedDescription
      });
    });

    await batch.commit();
    return { message: "Updated descriptions for all courses successfully" };
  } catch (error) {
    console.error('Error updating course descriptions:', error);
    throw error;
  }
};

exports.getCoursesByCategory = async (userCategories) => {
  try {
    // Assuming userCategories is an array of categories the user is interested in
    const snapshot = await CourseCollection.where('isPublic', '==', true).get();
    console
    
    // Initialize a result object with categories as keys and empty arrays as values
    const result = userCategories.reduce((acc, category) => {
      acc[category] = [];
      return acc;
    }, {});
    
    snapshot.docs.forEach(doc => {
      const courseData = doc.data();
      if (Array.isArray(courseData.category)) {
        userCategories.forEach(category => {
          const matches = courseData.category.some(courseCategory => 
            courseCategory.toLowerCase().includes(category.toLowerCase())
          );
          if (matches) {
            result[category].push({ id: doc.id, ...courseData });
          }
        });
      }
    });

    return result;
  } catch (error) {
    console.error('Error fetching courses by category:', error);
    throw error;
  }
};


