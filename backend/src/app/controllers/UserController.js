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

exports.getRequests = async (req, res) => {
    try {
        const response = await UserService.getRequests();
        res.status(200).json(response);
    } catch (error) {
        res.status(500).send({ message: 'Error fetching unapproved requests', error: error.message });
    }
};

exports.getRequestDetails = async (req, res) => {
    try {
        const requestId = req.params.requestId;
        const response = await UserService.getRequestDetails(requestId);
        res.status(200).json(response);
    } catch (error) {
        res.status(500).send({ message: 'Error fetching request details', error: error.message });
    }
};


exports.getUserData = async (req, res) => {
    try {
        const userId = req.params.userId;
        const response = await UserService.getUserData(userId);
        res.status(200).json(response);
    } catch (error) {
        res.status(500).send({ message: 'Error fetching user data', error: error.message });
    }
}

exports.rejectInstructorRequest = async (req, res) => {
    try {
        const requestId = req.params.requestId;
        const { content } = req.body; 
        const response = await UserService.rejectInstructorRequest(requestId, content);
        res.status(200).json(response);
    } catch (error) {
        res.status(500).send({ message: 'Error happened when rejecting request', error: error.message });
    }
};
