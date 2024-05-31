const TeacherService = require('../service/TeacherService');

exports.createTeacher = async (req, res) => {
    const teacher = req.body;
    const teacherId = await TeacherService.createTeacher(teacher);
    res.status(201).send({ id: teacherId, ...teacher });
}

exports.getAllTeachers = async (req, res) => {
    const teachers = await TeacherService.getAllTeachers();
    res.send(teachers);
};

exports.getTeacherById = async (req, res) => {
    const teacher = await TeacherService.getTeacherById(req.params.id);
    res.send(teacher);
};

exports.updateTeacher = async (req, res) => {
    const updates = req.body;
    await TeacherService.updateTeacher(req.params.id, updates);
    res.sendStatus(204);
};

exports.deleteTeacher = async (req, res) => {
    await TeacherService.deleteTeacher(req.params.id);
    res.sendStatus(204);
};