const { EnrollmentCollection } = require('./Collections');


const addNote = async (enrollmentId, data) => {
    try {
        const noteRef = EnrollmentCollection.doc(enrollmentId).collection('notes').doc();
        await noteRef.set(data);
        return noteRef.id;
    } catch (error) {
        throw new Error(`Error adding note: ${error.message}`);
    }
};

const deleteNote = async (enrollmentId, noteId) => {
    try {
        await EnrollmentCollection.doc(enrollmentId).collection('notes').doc(noteId).delete();
    } catch (error) {
        throw new Error(`Error deleting note: ${error.message}`);
    }
};

const updateNote = async (enrollmentId, noteId, data) => {
    try {
        await EnrollmentCollection.doc(enrollmentId).collection('notes').doc(noteId).update(data);
    } catch (error) {
        throw new Error(`Error updating note: ${error.message}`);
    }
};

const getAllNotesOfEnrollment = async (enrollmentId) => {
    try {
        const notesSnapshot = await EnrollmentCollection.doc(enrollmentId).collection('notes').get();
        const notes = notesSnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
        return notes;
    } catch (error) {
        throw new Error(`Error retrieving notes: ${error.message}`);
    }
};

module.exports = {
    addNote,
    deleteNote,
    updateNote,
    getAllNotesOfEnrollment
};