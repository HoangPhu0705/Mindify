const UserService = require('../service/UserService');

exports.saveCourseForUser = async (req, res) => {
    try {
        const userId = req.params.userId;
        const { courseId } = req.body;
        const response = await UserService.saveCourseForUser(userId, courseId);
        res.status(201).json(response);
    } catch (error) {
        res.status(500).send({ message: 'Error happen when save course', error: error.message });
    }
};

exports.unsaveCourseForUser = async (req, res) => {
    try {
        const userId = req.params.userId;
        const { courseId } = req.body;
        const response = await UserService.unsaveCourseForUser(userId, courseId);
        res.status(200).json(response);
    } catch (error) {
        res.status(500).send({ message: 'Error happened when unsaving course', error: error.message });
    }
};

exports.getSavedCourses = async (req, res) => {
    try {
        const userId = req.params.userId;
        const response = await UserService.getSavedCourses(userId);
        res.status(200).json(response);
    } catch (error) {
        res.status(500).send({ message: 'Error happened when getting saved courses', error: error.message });
    }
};


exports.createInstructorSignUpRequest = async (req, res) => {
    try {
        await UserService.createInstructorSignUpRequest(req.body);
        res.status(201).json("success");
    } catch (error) {
        res.status(500).send({ message: 'Error happened when requesting instructor', error: error.message });
    }
}

exports.approveInstructorRequest = async (req, res) => {
    try {
        const requestId = req.params.requestId;
        const response = await UserService.approveInstructorRequest(requestId);
        res.status(200).json(response);
    } catch (error) {
        res.status(500).send({ message: 'Error happened when approving request', error: error.message });
    }
};

exports.getUnapprovedRequests = async (req, res) => {
    try {
        const response = await UserService.getUnapprovedRequests();
        res.status(200).json(response);
    } catch (error) {
        res.status(500).send({ message: 'Error fetching unapproved requests', error: error.message });
    }
};
