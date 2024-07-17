
require('dotenv').config();

const jwt = require('jsonwebtoken');
const admin = require('firebase-admin');

const generateToken = (uid) => {
  return jwt.sign({ uid }, process.env.JWT_SECRET, { expiresIn: '1h' });
};

const verifyToken = (token) => {
  return jwt.verify(token, process.env.JWT_SECRET);
};

const verifyAdminRole = async (uid) => {
  const user = await admin.auth().getUser(uid);
  return user.customClaims && user.customClaims.admin === true;
};

module.exports = { generateToken, verifyToken, verifyAdminRole };
