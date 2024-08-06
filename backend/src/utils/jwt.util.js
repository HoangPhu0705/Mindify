require('dotenv').config();
const jwt = require('jsonwebtoken');

const generateToken = (uid, claims) => {
    const payload = {
        uid,
        ...claims 
      };
    return jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '1d' });
};

module.exports = { generateToken }