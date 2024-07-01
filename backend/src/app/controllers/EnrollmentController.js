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
        const enrollmentStatus = await EnrollmentService.checkEnrollment(userId, courseId);
        res.status(200).json(enrollmentStatus);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.getUserEnrollments = async (req, res) => {
    const { userId } = req.query;

    if (!userId) {
        return res.status(400).json({ error: 'Missing userId' });
    }

    try {
        const enrollments = await EnrollmentService.getUserEnrollments(userId);
        res.status(200).json(enrollments);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.addLessonToEnrollment = async (req, res) => {
    const { enrollmentId, lessonId } = req.body;
    if (!enrollmentId || !lessonId) {
        return res.status(400).json({ error: 'Missing enrollmentId or lessonId' });
    }
    try {
        const response = await EnrollmentService.addLessonToEnrollment(enrollmentId, lessonId);
        res.status(200).json(response);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.getDownloadedLessons = async (req, res) => {
    const { userId } = req.query;

    if (!userId) {
        return res.status(400).json({ error: 'Missing userId' });
    }

    try {
        const downloadedLessons = await EnrollmentService.getDownloadedLessons(userId);
        res.status(200).json(downloadedLessons);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
