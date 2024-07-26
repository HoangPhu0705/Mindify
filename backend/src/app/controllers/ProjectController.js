const ProjectService = require("../service/ProjectService");

exports.submitProject = async (req, res) => {
    const { courseId } = req.params;
    const content = req.body;

    const response = await ProjectService.submitProject(courseId, content);

    if (response.success) {
        res.status(201).json({ message: "Project submitted successfully", project: response.project });
    } else {
        res.status(500).json({ message: "Internal server error", error: response.error });
    }
};

exports.removeProject = async (req, res) => {
    const { courseId, projectId } = req.params;

    const response = await ProjectService.removeProject(courseId, projectId);

    if (response.success) {
        res.status(200).json({ message: "Project removed successfully" });
    } else {
        res.status(500).json({ message: "Internal server error", error: response.error });
    }
};

exports.getAllProjects = async (req, res) => {
    const { courseId } = req.params;

    const response = await ProjectService.getAllProjects(courseId);

    if (response.success) {
        res.status(200).json({ projects: response.projects });
    } else {
        res.status(500).json({ message: "Internal server error", error: response.error });
    }
};

exports.getUserProject = async (req, res) => {
    const { courseId, userId } = req.params;

    const response = await ProjectService.getUserProject(courseId, userId);

    if (response.success) {
        res.status(200).json({ project: response.project });
    } else {
        res.status(404).json({ message: "Project not found", error: response.error });
    }
};


exports.updateProject = async (req, res) => {
    const { courseId, projectId } = req.params;
    const content = req.body;

    const response = await ProjectService.updateProject(courseId, projectId, content);

    if (response.success) {
        res.status(200).json({ message: "Project updated successfully" });
    } else {
        res.status(500).json({ message: "Internal server error", error: response.error });
    }
}