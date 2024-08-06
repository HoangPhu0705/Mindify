const admin = require('firebase-admin');
const jwt = require('jsonwebtoken');

const jwtSecret = process.env.JWT_SECRET; 

const authenticate = async (req, res, next) => {
    const idToken = req.headers.authorization?.split('Bearer ')[1];

    if (!idToken) {
        return res.status(401).send('Unauthorized');
    }

    try {
        const decodedToken = await admin.auth().verifyIdToken(idToken);
        req.user = decodedToken;
        next();
    } catch (error) {
        return res.status(401).send('Unauthorized');
    }
};

// for admin's APIs
const authenticateJWT = (req, res, next) => {
    const authHeader = req.headers.authorization;
  
    if (authHeader) {
      const token = authHeader.split(' ')[1];
  
      jwt.verify(token, jwtSecret, (err, user) => {
        if (err) {
          return res.sendStatus(403); 
        }
  
        req.user = user;
        next(); 
      });
    } else {
      res.sendStatus(401);
    }
  };

  const combinedAuthenticate = async (req, res, next) => {
    const authHeader = req.headers.authorization;
    
    if (!authHeader) {
        return res.status(401).send('Unauthorized');
    }

    const token = authHeader.split(' ')[1];

    try {
        const decodedToken = await admin.auth().verifyIdToken(token);
        req.user = decodedToken;
        return next();
    } catch (error) {
        console.log('Failed to authenticate with Firebase, trying JWT...');
    }

    jwt.verify(token, jwtSecret, (err, user) => {
        if (err) {
            return res.status(403).send('Forbidden'); 
        }
  
        req.user = user;
        next();
    });
};


module.exports = {
    authenticate,
    authenticateJWT,
    combinedAuthenticate
};