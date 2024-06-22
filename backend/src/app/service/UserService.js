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

        return { message: 'Khóa học được lưu thành công', savedClasses: savedClasses };
    } catch (error) {
        throw new Error(`Lỗi khi lưu khóa học cho user: ${error.message}`);
    }
};