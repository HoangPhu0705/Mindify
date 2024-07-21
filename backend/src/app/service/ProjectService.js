const { CourseCollection } = require("./Collections");
const { firestore } = require('firebase-admin');

exports.submitProject = async (courseId, project) => {
    try {
        const newProject = {
            ...project,
            createdAt: firestore.FieldValue.serverTimestamp(),
        };

        await CourseCollection.doc(courseId).collection('projects').add(newProject);

        return { success: true, project: newProject };
    } catch (error) {
        console.error("Error submitting project:", error);
        return { success: false, error };
    }
};

exports.removeProject = async (courseId, projectId) => {
    try {
        await CourseCollection.doc(courseId).collection('projects').doc(projectId).delete();

        return { success: true };
    } catch (error) {
        console.error("Error removing project:", error);
        return { success: false, error };
    }
};

exports.getAllProjects = async (courseId) => {
    try {
        const projectsSnapshot = await CourseCollection.doc(courseId).collection('projects').get();

        const projects = projectsSnapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data()
        }));

        return { success: true, projects };
    } catch (error) {
        console.error("Error getting projects:", error);
        return { success: false, error };
    }
};

exports.getUserProject = async (courseId, userId) => {
    try {
        const projectsSnapshot = await CourseCollection
            .doc(courseId)
            .collection('projects')
            .where('userId', '==', userId)
            .get();

        if (projectsSnapshot.empty) {
            return { success: false, error: "No project found" };
        }

        const project = projectsSnapshot.docs[0].data();
        return { success: true, project };
    } catch (error) {
        console.error("Error getting user project:", error);
        return { success: false, error };
    }
};