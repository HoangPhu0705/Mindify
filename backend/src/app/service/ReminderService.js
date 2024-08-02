const admin = require('firebase-admin');
const schedule = require('node-schedule');
const { UserCollection } = require('./Collections')
const jobs = {};
const  messaging = admin.messaging();

const dayMap = {
  'Sun': 0,
  'Mon': 1,
  'Tue': 2,
  'Wed': 3,
  'Thu': 4,
  'Fri': 5,
  'Sat': 6
};

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

const convertTo24HourFormat = (time12h) => {
  const [time, modifier] = time12h.split(' ');
  let [hours, minutes] = time.split(':');

  if (hours === '12') {
    hours = '00';
  }

  if (modifier === 'PM') {
    hours = parseInt(hours, 10) + 12;
  }

  return `${hours}:${minutes}`;
};

const scheduleReminder = async (userId, reminderId, reminder) => {
  const { day, time } = reminder;
  const [hour, minute] = convertTo24HourFormat(time).split(':').map(Number);
  const dayOfWeek = dayMap[day];

  console.log(`Scheduling job for user ${userId} at ${hour}:${minute} on day ${dayOfWeek}`);
  jobs[reminderId] = schedule.scheduleJob(`${minute} ${hour} * * ${dayOfWeek}`, async () => {
    console.log("Timeee");
    await sendNotification(userId, reminder);
  });

  if (jobs[reminderId]) {
    console.log(`Job scheduled successfully for reminder ${reminderId}`);
  } else {
    console.log(`Failed to schedule job for reminder ${reminderId}`);
  }
};


const sendNotification = async (userId, reminder) => {
  const userDoc = await UserCollection.doc(userId).get();
  const deviceTokens = userDoc.data().deviceTokens;

  if (deviceTokens && deviceTokens.length > 0) {
    const message = {
      notification: {
        title: 'Learning Reminder',
        body: `Time to study! ${reminder.day} at ${reminder.time}`
      },
      tokens: deviceTokens
    };

    try {
      // Gửi thông báo tới danh sách token
      const response = await messaging.sendMulticast(message);
      console.log('Successfully sent message:', response);
    } catch (sendError) {
      console.error('Error sending message:', sendError);
    }

  } else {
    console.log('No device tokens found for user.');
  }

  // if (!deviceTokens || deviceTokens.length === 0) {
  //   console.log(`No device tokens for user ${userId}`);
  //   return;
  // }

  // const message = {
  //   notification: {
  //     title: 'Learning Reminder',
  //     body: `Time to study! ${reminder.day} at ${reminder.time}`
  //   },
  //   tokens: deviceTokens
  // };

  // await admin.messaging().sendMulticast(message);
}
