const admin = require('firebase-admin');
const schedule = require('node-schedule');
const { UserCollection } = require('./Collections')
const jobs = {};

exports.addReminder = async (userId, day, time) => {
  const reminderRef = await UserCollection.doc(userId).collection('reminders').add({
    day,
    time,
    created_at: admin.firestore.FieldValue.serverTimestamp(),
  });
  const reminderId = reminderRef.id;

  scheduleReminder(userId, reminderId, { day, time });

  return reminderId;
}

exports.deleteReminder = async (userId, reminderId) => {
  await UserCollection.doc(userId).collection('reminders').doc(reminderId).delete();

  if (jobs[reminderId]) {
    jobs[reminderId].cancel();
    delete jobs[reminderId];
  }
}

const scheduleReminder = async (userId, reminderId, reminder) => {
  const { day, time } = reminder;
  const [hour, minute] = time.split(':').map(Number);

  jobs[reminderId] = schedule.scheduleJob(`${minute} ${hour} * * ${day}`, async () => {
    await sendNotification(userId, reminder);
  });
}

const sendNotification = async (userId, reminder) => {
  const userDoc = await UserCollection.doc(userId).get();
  const deviceTokens = userDoc.data().deviceTokens;

  if (!deviceTokens || deviceTokens.length === 0) {
    console.log(`No device tokens for user ${userId}`);
    return;
  }

  const message = {
    notification: {
      title: 'Learning Reminder',
      body: `Time to study! ${reminder.day} at ${reminder.time}`
    },
    tokens: deviceTokens
  };

  await admin.messaging().sendMulticast(message);
}
