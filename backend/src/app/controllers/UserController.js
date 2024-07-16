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

exports.followUser = async (req, res) => {
    const { userId } = req.params;
    const { followUserId } = req.body;

    if (!userId || !followUserId) {
        return res.status(400).json({ message: "Missing userId or followUserId" });
    }

    try {
        await UserService.followUser(userId, followUserId);
        res.status(200).json({ message: "Successfully followed the user" });
    } catch (error) {
        res.status(500).json({ message: `Error when following user: ${error.message}` });
    }
};

exports.checkIfUserFollows = async (req, res) => {
    try {
        const userId = req.params.userId;
        const followUserId = req.query.userId;

        if (!userId || !followUserId) {
            return res.status(400).json({ message: "Missing userId or followUserId" });
        }

        const isFollowing = await UserService.checkIfUserFollows(userId, followUserId);
        res.status(200).json({ isFollowing });
    } catch (error) {
        res.status(500).send({ message: 'Error happened when checking follow status', error: error.message });
    }
};

exports.unfollowUser = async (req, res) => {
    const { userId } = req.params;
    const { unfollowUserId } = req.body;

    if (!userId || !unfollowUserId) {
        return res.status(400).json({ message: "Missing userId or unfollowUserId" });
    }

    try {
        await UserService.unfollowUser(userId, unfollowUserId);
        res.status(200).json({ message: "Successfully unfollowed the user" });
    } catch (error) {
        res.status(500).json({ message: `Error when unfollowing user: ${error.message}` });
    }
};

exports.updateUsers = async (req, res) => {
    try {
        await UserService.updateUsers();
        res.status(200).json({ message: 'All users updated successfully' });
    } catch (error) {
        res.status(500).json({ error: `Error when updating users: ${error.message}` });
    }
};

exports.getUserNameAndAvatar = async (req, res) => {
    try{
        const userId = req.params.userId;
        const response = await UserService.getUserNameAndAvatar(userId);
        res.status(200).json(response);
    }catch(e){
        res.status(500).json({ error: `Error getting name and avatar ${error.message}` });

    }
}

exports.getWatchedHistories = async (req, res) => {
    try {
        const userId = req.params.userId;
        const watchHistory = await UserService.getWatchedHistories(userId);
        res.status(200).json(watchHistory);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.addToWatchedHistory = async (req, res) => {
    const { userId } = req.params;
    const { lessonId, courseId, time } = req.body;

    if (!lessonId || !time || !courseId) {
        return res.status(400).json({ message: 'lessonId courseId and time are required' });
    }

    try {
        const timestamp = new Date();
        const result = await UserService.addToWatchedHistories(userId, courseId, lessonId, time, timestamp);
        res.status(200).json(result);
    } catch (error) {
        console.error('Error adding watched history:', error);
        res.status(500).json({ message: 'Internal Server Error' });
    }
};


exports.goToVideoWatched = async (req, res) => {
    const { userId, lessonId } = req.params;

    try {
        const result = await UserService.goToVideoWatched(userId, lessonId);
        res.status(200).json(result);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.getWatchedTime = async (req, res) => {
    try {
        const { userId } = req.params;
        const { courseId, lessonId } = req.query;

        if (!userId || !courseId || !lessonId) {
            return res.status(400).json({ error: 'Missing required parameters' });
        }

        const time = await UserService.getWatchedTime(userId, courseId, lessonId);

        if (time === null) {
            return res.status(404).json({ error: 'Watched history not found' });
        }

        res.status(200).json({ time });
    } catch (error) {
        console.error("Error in getWatchedTimeController:", error);
        res.status(500).json({ error: 'Internal Server Error' });
    }
};