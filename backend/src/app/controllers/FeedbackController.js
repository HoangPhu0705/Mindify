const FeedbackService = require("../service/FeedbackService")

exports.giveFeedback = async (req, res) => {
    try {
        const { courseId } = req.params;
        const { userId, feedback } = req.body;
        const result = await FeedbackService.giveFeedback(courseId, userId, feedback);
        res.status(201).send({
            message: "create feedback successfully",
            success: true,
            data: result
        })
    } catch (err) {
        res.status(500).send({ success: false, error: 'Internal Server Error' })
    }
}

exports.getCourseRating = async (req, res) => {
    const { courseId } = req.params;

    try {
        const averageRating = await FeedbackService.ratingOfCourse(courseId);
        return res.status(200).json({ message: "get rating successfully", success: true, averageRating });
    } catch (error) {
        console.error("Error getting course rating:", error);
        return res.status(500).json({ success: false, error: 'Internal Server Error' });
    }
};