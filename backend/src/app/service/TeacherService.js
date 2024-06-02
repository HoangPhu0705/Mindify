const { TeacherCollection } = require('./Collections')

exports.createTeacher = async (teacher) => {
    try {
        const docRef = TeacherCollection.doc();
        await docRef.set(teacher);
        return docRef.id;
    } catch (error) {
        console.error('Error creating teacher:', error);
        throw error;
    }
};

exports.getAllTeachers = async () => {
    try {
        const snapshot = await TeacherCollection.get();
        if (!snapshot.empty) {
            return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
        } else {
            console.error('No documents found in the teachers collection.');
            return [];
        }
    } catch (error) {
        console.error('Error fetching teachers:', error);
        throw error;
    }
};

exports.getTeacherById = async (id) => {
    try {
        const doc = await TeacherCollection.doc(id).get();
        return doc.exists ? { id: doc.id, ...doc.data() } : null;
    } catch (error) {
        console.error('Error fetching teacher by ID:', error);
        throw error;
    }
};

exports.updateTeacher = async (id, updates) => {
    try {
        await TeacherCollection.doc(id).update(updates);
    } catch (error) {
        console.error('Error updating teacher:', error);
        throw error;
    }
};

exports.deleteTeacher = async (id) => {
    try {
        await TeacherCollection.doc(id).delete();
    } catch (error) {
        console.error('Error deleting teacher:', error);
        throw error;
    }
};