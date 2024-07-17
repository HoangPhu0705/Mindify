const { loginUser } = require('../service/AdminService');

const loginController = async (req, res) => {
    const { email, password } = req.body;

    console.log('Login controller triggered with email: ', email);
    try {
        const { uid, token } = await loginUser(email, password);
        console.log('Login successful, responding with uid and token');
        res.status(200).json({ uid, token });
    } catch (error) {
        console.error('Login failed: ', error.message);
        res.status(500).json({ message: error.message });
    }
};

module.exports = { loginController };
