const { FolderCollection } = require('./Collections');
const { firestore } = require('firebase-admin');

exports.getFoldersofUser = async (userId) => {
    try {
        const snapshot = await FolderCollection
            .where('userId', '==', userId)
            .get();

        if (snapshot.empty) {
            return [];
        }

        const folders = [];
        snapshot.forEach(doc => {
            folders.push({ id: doc.id, ...doc.data() });
        });

        return folders;
    } catch (error) {
        console.error(`Error getting folders of user ${userId}:`, error);
        throw error;
    }
};

exports.createFolder = async (data) => {
    try {
        const docRef = FolderCollection.doc();
        await docRef.set({
            ...data,
            courses: []
        });
        return { "folderId": docRef.id };
    } catch (error) {
        console.error('Error creating folder:', error);
        throw error;
    }
};

exports.addCourseToFolder = async (folderId, courseId) => {
    try {
        const docRef = FolderCollection.doc(folderId);
        await docRef.update({
            courses: firestore.FieldValue.arrayUnion(courseId)
        });
        return { "message": "courseId added successfully" };
    } catch (error) {
        console.error('Error adding courseId to folder:', error);
        throw error;
    }
};

exports.deleteFolder = async (folderId) => {
    try {
        const docRef = FolderCollection.doc(folderId);
        await docRef.delete();
        return { "message": "Folder deleted successfully" };
    } catch (error) {
        console.error('Error deleting folder:', error);
        throw error;
    }   
}

exports.getFolderById = async (folderId) => {
    try {
        const doc = await FolderCollection.doc(folderId).get();
        if (!doc.exists) {
            return null;
        }

        return { id: doc.id, ...doc.data() };
    } catch (error) {
        console.error(`Error getting folder ${folderId}:`, error);
        throw error;
    }
}

exports.getCoursesOfFolder = async (folderId) => {
    try {
        const doc = await FolderCollection.doc(folderId).get();
        if (!doc.exists) {
            return null;
        }

        return doc.data().courses;
    } catch (error) {
        console.error(`Error getting courses of folder ${folderId}:`, error);
        throw error;
    }
}