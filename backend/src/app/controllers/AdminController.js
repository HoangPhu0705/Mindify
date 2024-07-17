const { loginUser, logout } = require('../service/AdminService');


class AdminController {

    loginController = async (req, res) => {
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


    logOut = async (req, res) => {
        try {
            await logout();
            res.status(200).json("Logged out");
        }catch (error) {
            console.error("Logout failed: ", error.message);
            res.status(500).json({ message: error.message });
        }
    }

}



module.exports = new AdminController();
