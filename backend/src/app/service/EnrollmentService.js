const { firestore } = require('firebase-admin');
const { EnrollmentCollection, CourseCollection, TransactionCollection } = require('./Collections');
const UserService = require('./UserService');
// const { Timestamp } = firestore;

exports.createEnrollment = async (data) => {
    try {
        const docRef = EnrollmentCollection.doc();
        await docRef.set({
            ...data,
            status: "enrolled",
            enrollmentDay: firestore.FieldValue.serverTimestamp(),
            downloadedLessons: [],
            progress: []
        });

        // +1 student
        const courseRef = CourseCollection.doc(data.courseId);
        await courseRef.update({
            students: firestore.FieldValue.increment(1)
        });

        return { "enrollmentId": docRef.id };
    } catch (error) {
        console.error('Error creating enrollment:', error);
        throw error;
    }
};

exports.checkEnrollment = async (userId, courseId) => {
    try {
        const enrollmentSnapshot = await EnrollmentCollection
          .where('userId', '==', userId)
          .where('courseId', '==', courseId)
          .get();
    
        if (enrollmentSnapshot.empty) {
          return null;
        }
    
        else{
            const enrollment = enrollmentSnapshot.docs[0];
            return { isEnrolled: true, enrollmentId: enrollment.id };
        }
    
      } catch (error) {
        throw new Error('Error retrieving enrollment: ' + error.message);
      }
};

exports.getUserEnrollments = async (userId) => {
    try {
        const snapshot = await EnrollmentCollection
            .where('userId', '==', userId)
            .get();

        if (snapshot.empty) {
            return [];
        }

        const enrollments = [];
        snapshot.forEach(doc => {
            enrollments.push({ id: doc.id, ...doc.data() });
        });

        return enrollments;
    } catch (error) {
        console.error('Error getting user enrollments:', error);
        throw error;
    }
};

exports.addLessonToEnrollment = async (enrollmentId, lessonId) => {
    try {
        const docRef = EnrollmentCollection.doc(enrollmentId);
        await docRef.update({
            downloadedLessons: firestore.FieldValue.arrayUnion(lessonId)
        });
        return { "message": "Lesson added successfully" };
    } catch (error) {
        console.error('Error adding lesson to enrollment:', error);
        throw error;
    }
};

exports.getDownloadedLessons = async (userId) => {
    try {
        const snapshot = await EnrollmentCollection
            .where('userId', '==', userId)
            .get();

        if (snapshot.empty) {
            return [];
        }

        const downloadedCourses = [];
        snapshot.forEach(doc => {
            const data = doc.data();
            downloadedCourses.push({
                courseId: data.courseId,
                downloadedLessons: data.downloadedLessons
            });
        });

        return downloadedCourses;
    } catch (error) {
        console.error('Error getting downloaded lessons:', error);
        throw error;
    }
};

exports.getProgressOfEnrollment = async (enrollmentId) => {
    try {
        const docRef = EnrollmentCollection.doc(enrollmentId);
        const doc = await docRef.get();

        if (!doc.exists) {
            throw new Error('Enrollment not found');
        }

        const data = doc.data();
        return data.progress || [];
    } catch (error) {
        console.error('Error getting progress of enrollment:', error);
        throw error;
    }
};


exports.addProgressToEnrollment = async (enrollmentId, lessonId) => {
    try {
        const docRef = EnrollmentCollection.doc(enrollmentId);
        const doc = await docRef.get();

        if (!doc.exists) {
            throw new Error('Enrollment document does not exist');
        }

        const enrollmentData = doc.data();
        const currentProgress = enrollmentData.progress || [];

        if (!currentProgress.includes(lessonId)) {
            await docRef.update({
                progress: firestore.FieldValue.arrayUnion(lessonId)
            });
            console.log(lessonId);
            return { message: "Progress added successfully" };
        } else {
            console.log('Lesson already in progress');
            return { message: "Lesson already in progress" };
        }
    } catch (error) {
        console.error('Error adding progress to enrollment:', error);
        throw error;
    }
};

exports.showStudentsOfCourse = async (courseId) => {
    try{
        const course = await CourseCollection.doc(courseId).get();
        const lessonNum = course.data().lessonNum;
        const courseEnrollmentRef = EnrollmentCollection.where("courseId", "==", courseId);
        const courseEnrollment = await courseEnrollmentRef.get();
        const studentNum = courseEnrollment.size;
        const result = {}
        const students = []
        for (const enrollmentDoc of courseEnrollment.docs) {
            const enrollmentData = enrollmentDoc.data();
            const userId = enrollmentData.userId;
            const enrollmentDay = enrollmentData.enrollmentDay;
            const enrollmentId = enrollmentDoc.id;
            const { displayName, photoUrl } = await UserService.getUserNameAndAvatar(userId);

            students.push({
                enrollmentId,
                userId,
                displayName,
                photoUrl,
                enrollmentDay: enrollmentDay.toDate(),
            });
        }
        result['studentNum'] = studentNum;
        result['lessonNum'] = lessonNum;
        result['students'] = students;
        return result;
    }catch(error){
        console.error('Error get students', error);
        throw error;
    }
}

exports.getStudentsOfMonth = async (userId, month, year) => {
    const startOfMonth = firestore.Timestamp.fromDate(new Date(year, month - 1, 1));
    const endOfMonth = firestore.Timestamp.fromDate(new Date(year, month, 0, 23, 59, 59));

    const courseSnapshot = await CourseCollection.where("authorId", "==", userId).get();

    let totalEnrollments = 0;

    for (const courseDoc of courseSnapshot.docs) {
        const courseId = courseDoc.id;

        const courseEnrollmentRef = EnrollmentCollection
                                        .where("courseId", "==", courseId)
                                        .where("enrollmentDay", ">=", startOfMonth)
                                        .where("enrollmentDay", "<=", endOfMonth);

        const enrollmentSnapshot = await courseEnrollmentRef.get();

        totalEnrollments += enrollmentSnapshot.size;
    }

    return {
        month: `${month.toString().padStart(2, '0')}-${year}`,
        totalEnrollments
    };
};

exports.getRevenueOfMonth = async (userId, month, year) => {
    const startOfMonth = firestore.Timestamp.fromDate(new Date(year, month - 1, 1));
    const endOfMonth = firestore.Timestamp.fromDate(new Date(year, month, 0, 23, 59, 59));

    const courseSnapshot = await CourseCollection.where("authorId", "==", userId).get();

    let totalRevenue = 0;

    for (const courseDoc of courseSnapshot.docs) {
        const courseId = courseDoc.id;

        const enrollmentSnapshot = await EnrollmentCollection
                                        .where("courseId", "==", courseId)
                                        .get();

        for (const enrollmentDoc of enrollmentSnapshot.docs) {
            const enrollmentId = enrollmentDoc.id;

            const transactionSnapshot = await TransactionCollection
                                            .where("enrollmentId", "==", enrollmentId)
                                            .where("confirmedAt", ">=", startOfMonth)
                                            .where("confirmedAt", "<=", endOfMonth)
                                            .get();

            transactionSnapshot.forEach(transactionDoc => {
                const transactionData = transactionDoc.data();
                totalRevenue += transactionData.amount;
            });
        }
    }

    return {
        month: `${month.toString().padStart(2, '0')}-${year}`,
        totalRevenue
    };
};

exports.getNumStudentsAndRevenue = async (userId) => {
    try {
        const coursesSnapshot = await CourseCollection.where('isPublic', '==', true).where('authorId', '==', userId).get();

        if (coursesSnapshot.empty) {
            return [];
        }

        const result = [];

        coursesSnapshot.forEach(doc => {
            const courseData = doc.data();
            const courseName = courseData.courseName;
            const students = courseData.students;
            const revenue = students * courseData.price;

            result.push({
                courseId: doc.id,
                courseName: courseName,
                students: students,
                revenue: revenue
            });
        });
        console.log(result.length)
        result.sort((a, b) => b.students - a.students);

        return result;

    } catch (error) {
        console.error('Error fetching courses:', error);
        throw new Error('Could not retrieve courses');
    }
};
