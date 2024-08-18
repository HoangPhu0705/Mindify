const { firestore } = require('firebase-admin');
const { EnrollmentCollection, CourseCollection } = require('./Collections');
const UserService = require('./UserService');

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
        const courseEnrollmentRef = EnrollmentCollection.where("courseId", "==", courseId);
        const courseEnrollment = await courseEnrollmentRef.get();
        const studentNum = courseEnrollment.size;
        const result = {}
        const students = []
        for (const enrollmentDoc of courseEnrollment.docs) {
            const enrollmentData = enrollmentDoc.data();
            const userId = enrollmentData.userId;
            const enrollmentDay = enrollmentData.enrollmentDay;

            const { displayName, photoUrl } = await UserService.getUserNameAndAvatar(userId);

            students.push({
                userId,
                displayName,
                photoUrl,
                enrollmentDay: enrollmentDay.toDate(),
            });
        }
        result['studentNum'] = studentNum;
        result['students'] = students
        return result;
    }catch(error){
        console.error('Error get students', error);
        throw error;
    }
}


