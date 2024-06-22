const { UserCollection } = require('./Collections');

exports.saveCourseForUser = async (userId, courseId) => {
    try {
        const userRef = UserCollection.doc(userId);
        const userDoc = await userRef.get();
        if (!userDoc.exists) {
            throw new Error("User didn't exists");
        }

        const userData = userDoc.data();
        const savedClasses = userData.savedClasses || [];

        if (!savedClasses.includes(courseId)) {
            savedClasses.push(courseId);
            await userRef.update({
                savedClasses: savedClasses
            });
        }

        // return { message: 'Save course successfully', savedClasses: savedClasses };
        return { message: 'Save course successfully' }
    } catch (error) {
        throw new Error(`Error when save course for user: ${error.message}`);
    }
};

exports.unsaveCourseForUser = async (userId, courseId) => {
    try {
        const userRef = UserCollection.doc(userId);
        const userDoc = await userRef.get();
        if (!userDoc.exists) {
            throw new Error("User doesn't exist");
        }

        const userData = userDoc.data();
        const savedClasses = userData.savedClasses || [];

        if (savedClasses.includes(courseId)) {
            const updatedSavedClasses = savedClasses.filter(id => id !== courseId);
            await userRef.update({
                savedClasses: updatedSavedClasses
            });
        }

        return { message: 'Unsave course successfully' };
    } catch (error) {
        throw new Error(`Error when unsaving course for user: ${error.message}`);
    }
};

exports.getSavedCourses = async (userId) => {
    try {
        const userRef = UserCollection.doc(userId);
        const userDoc = await userRef.get();
        if (!userDoc.exists) {
            throw new Error("User doesn't exist");
        }

        const userData = userDoc.data();
        const savedClasses = userData.savedClasses || [];

        return { savedClasses: savedClasses };
    } catch (error) {
        throw new Error(`Error when getting saved courses for user: ${error.message}`);
    }
};