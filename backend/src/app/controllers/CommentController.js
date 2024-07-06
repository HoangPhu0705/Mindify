const CommentService = require('../service/CommentService');

exports.createComment = async (req, res) => {
    try {
        const { userId, content } = req.body;
        const commentId = await CommentService.createComment(req.params.id, userId, content);
        res.status(201).send({ commentId });
    } catch (error) {
        console.error('Error in createComment:', error.message);
        res.status(500).send({ message: 'Internal Server Error', error: error.message });
    }
};

exports.showComments = async (req, res) => {
    try {
        const comments = await CommentService.showComments(req.params.id);
        res.status(200).send(comments);
    } catch (error) {
        console.error('Error in showComments:', error.message);
        res.status(500).send({ message: 'Internal Server Error', error: error.message });
    }
};

exports.replyComment = async (req, res) => {
    try {
        const { userId, content } = req.body;
        const replyId = await CommentService.replyComment(req.params.id, req.params.commentId, userId, content);
        res.status(201).send({ replyId });
    } catch (error) {
        console.error('Error in replyComment:', error.message);
        res.status(500).send({ message: 'Internal Server Error', error: error.message });
    }
};
