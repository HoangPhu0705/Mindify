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

exports.addProgressToEnrollment = async (req, res) => {
    const { enrollmentId } = req.params;
    const { lessonId } = req.body;

    if (!lessonId) {
        return res.status(400).send({ error: 'Lesson ID is required' });
    }

    try {
        const response = await EnrollmentService.addProgressToEnrollment(enrollmentId, lessonId);
        res.status(200).send(response);
    } catch (error) {
        res.status(500).send({ error: error.message });
    }
}

exports.getProgressOfEnrollment = async (req, res) => {
    const { enrollmentId } = req.params;

    try {
        const progress = await EnrollmentService.getProgressOfEnrollment(enrollmentId);
        res.status(200).send(progress);
    } catch (error) {
        res.status(500).send({ error: error.message });
    }
}

exports.showStudentsOfCourse = async (req, res) => {
    const { courseId } = req.params;
    try {
        const result = await EnrollmentService.showStudentsOfCourse(courseId);
        res.status(200).send({ 
            message: "get student success",
            success: true,
            data: result
        })
    } catch (error) {
        res.status(500).send({ error: error.message })
    }
}

// exports.getStudentsOfMonth = async (req, res) => {
//     const { userId } = req.params;
//     try{
//         const totalEnrollments = await EnrollmentService.getStudentsOfMonth(userId);
//         res.status(200).send({ 
//             message: "get num of student success",
//             success: true,
//             data: totalEnrollments
//         })
//     }catch (error) {
//         res.status(500).send({ error: error.message })
//     }
// }

// exports.getRevenueOfMonth = async (req, res) => {
//     const { userId } = req.params;
//     try{
//         const totalEnrollments = await EnrollmentService.getRevenueOfMonth(userId);
//         res.status(200).send({ 
//             message: "get num of student success",
//             success: true,
//             data: totalEnrollments
//         })
//     }catch (error) {
//         res.status(500).send({ error: error.message })
//     }
// }
exports.getDashboardData = async (req, res) => {
    const { userId } = req.params;
    const { month, year } = req.query;

    if (!month || !year) {
        return res.status(400).json({ error: "Month and year are required" });
    }

    try {
        const totalEnrollments = await EnrollmentService.getStudentsOfMonth(userId, parseInt(month), parseInt(year));
        const totalRevenue = await EnrollmentService.getRevenueOfMonth(userId, parseInt(month), parseInt(year));

        res.status(200).json({
            message: "get num of student success",
            success: true,
            data: {
            enrollments: totalEnrollments,
            revenue: totalRevenue
        }
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.getNumStudentsAndRevenue = async (req, res) => {
    try {
        const { userId } = req.params;

        const data = await EnrollmentService.getNumStudentsAndRevenue(userId);

        return res.status(200).json({
            message: "get stats of courses success",
            success: true,
            data: data
        });
    } catch (error) {
        console.error('Error in getNumStudentsAndRevenueController:', error);
        return res.status(500).json({
            success: false,
            message: 'Could not retrieve courses'
        });
    }
};