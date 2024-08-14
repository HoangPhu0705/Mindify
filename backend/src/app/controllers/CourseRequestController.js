const { messaging } = require('../../config/firebase');
const { CourseRequestCollection } = require('../service/Collections');
const CourseRequestService = require('../service/CourseRequestService');    

exports.getRequests = async (req, res) => {
    const { limit = 5, startAfter = null } = req.query;

    try {
        const { requests, totalCount } = await CourseRequestService.getRequests(Number(limit), startAfter);
        res.status(200).json({ requests, totalCount });
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
        res.status(200).json({result, messaging: "Successfully sent msg"});
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

exports.deleteCourseRequest = async (req, res) => {
    try {
        const result = await CourseRequestService.deleteCourseRequest(req.params.requestId);
        res.status(200).json(result);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
}
