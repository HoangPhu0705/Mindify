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