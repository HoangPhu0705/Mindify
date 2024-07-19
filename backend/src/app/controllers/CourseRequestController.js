const { CourseRequestCollection } = require('../service/Collections');
const CourseRequestService = require('../service/CourseRequestService');

exports.getRequests = async (req, res) => {
    try {
        const requests = await CourseRequestService.getRequests();
        res.status(200).json(requests);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.sendRequest = async (req, res) => {
    try {
        const request = await CourseRequestService.sendRequest(req.params.courseId);
        res.status(200).json(request);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.approveRequest = async (req, res) => {
    try {
        const result = await CourseRequestService.approveRequest(req.params.requestId);
        res.status(200).json(result);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.rejectRequest = async (req, res) => {
    try {
        const result = await CourseRequestService.rejectRequest(req.params.requestId);
        res.status(200).json(result);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
