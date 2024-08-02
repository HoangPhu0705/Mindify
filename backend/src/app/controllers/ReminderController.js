const ReminderService = require('../service/ReminderService');

exports.addReminder = async (req, res) => {
  try {
    const userId = req.params.userId;
    const { day, time } = req.body;
    const reminderId = await ReminderService.addReminder(userId, day, time);
    res.status(200).send({ reminderId });
  } catch (error) {
    res.status(500).send({ message: 'Failed to add reminder', error });
  }
};

exports.deleteReminder = async (req, res) => {
  try {
    const { userId, reminderId } = req.params;
    await ReminderService.deleteReminder(userId, reminderId);
    res.status(200).send({ message: 'Reminder deleted successfully' });
  } catch (error) {
    res.status(500).send({ message: 'Failed to delete reminder', error });
  }
};