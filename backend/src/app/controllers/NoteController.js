const { addNote, deleteNote, updateNote, getAllNotesOfEnrollment } = require('../service/NoteService');

exports.addNoteController = async (req, res) => {
    const { enrollmentId, data } = req.body;
    try {
        const noteId = await addNote(enrollmentId, data);
        res.status(200).json({ message: 'Note added successfully', noteId });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

exports.deleteNoteController = async (req, res) => {
    const { enrollmentId, noteId } = req.params;
    try {
        await deleteNote(enrollmentId, noteId);
        res.status(200).json({ message: 'Note deleted successfully' });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

exports.updateNoteController = async (req, res) => {
    const { enrollmentId, noteId } = req.params;
    const data = req.body;
    try {
        await updateNote(enrollmentId, noteId, data);
        res.status(200).json({ message: 'Note updated successfully' });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

exports.getAllNotesOfEnrollmentController = async (req, res) => {
    const { enrollmentId } = req.params;
    try {
        const notes = await getAllNotesOfEnrollment(enrollmentId);
        res.status(200).json(notes);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};
