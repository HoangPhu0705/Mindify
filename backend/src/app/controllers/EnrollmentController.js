const EnrollmentService = require('../service/EnrollmentService');

exports.createEnrollment = async (req, res) => {
    try {
        const enrollment = await EnrollmentService.createEnrollment(req.body);
        res.status(201).json(enrollment);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
}