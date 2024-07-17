const admin = require('firebase-admin');

const assignAdminRole = async (uid) => {
  try {
    await admin.auth().setCustomUserClaims(uid, { admin: true });
    return `Successfully assigned admin role to user ${uid}`;
  } catch (error) {
    throw new Error('Error assigning admin role: ' + error.message);
  }
};

module.exports = { assignAdminRole };
