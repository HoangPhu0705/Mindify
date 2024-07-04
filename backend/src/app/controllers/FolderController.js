const FolderService = require('../service/FolderService');

exports.createFolder = async (req, res) => {
    try {
        const folder = await FolderService.createFolder(req.body);
        res.status(201).json(folder);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
}

exports.getFoldersofUser = async (req, res) => {
    const { userId } = req.query;

    if (!userId) {
        return res.status(400).json({ error: 'Missing userId' });
    }

    try {
        const folders = await FolderService.getFoldersofUser(userId);
        res.status(200).json(folders);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.addCourseToFolder = async (req, res) => {
    const { folderId, courseId } = req.body;
    if (!folderId || !courseId) {
        return res.status(400).json({ error: 'Missing folderId or courseId' });
    }
    try {
        const response = await FolderService.addCourseToFolder(folderId, courseId);
        res.status(200).json(response);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};