const express = require('express');
const router = express.Router();
const ProjectController = require('../app/controllers/ProjectController');


router.get('/:courseId', ProjectController.getAllProjects);
router.post('/:courseId', ProjectController.submitProject);
router.delete('/:courseId/:projectId', ProjectController.removeProject);
router.put('/:courseId/:projectId', ProjectController.updateProject);
router.get('/:courseId/:userId', ProjectController.getUserProject);

module.exports = router;