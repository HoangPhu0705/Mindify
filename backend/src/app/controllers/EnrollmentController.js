const EnrollmentService = require('../service/EnrollmentService');

exports.createEnrollment = async (req, res) => {
    try {
        const enrollment = await EnrollmentService.createEnrollment(req.body);
        res.status(201).json(enrollment);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
}

exports.checkEnrollment = async (req, res) => {
    const { userId, courseId } = req.query;

    if (!userId || !courseId) {
        return res.status(400).json({ error: 'Missing userId or courseId' });
    }

    try {
        const isEnrolled = await EnrollmentService.checkEnrollment(userId, courseId);
        res.status(200).json({ isEnrolled });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};