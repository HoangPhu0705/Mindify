const { loginUser,
    logout,
    getAllUsersPaginated,
    getAllCoursesPaginated,
    lockUser, 
    unlockUser
} = require('../service/AdminService');


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
        } catch (error) {
            console.error("Logout failed: ", error.message);
            res.status(500).json({ message: error.message });
        }
    }

    showAllUsers = async (req, res) => {
        const { limit, startAfter } = req.query;
        try {
            const users = await getAllUsersPaginated(parseInt(limit), startAfter);
            res.status(200).json(users);
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    };

    showAllCourses = async (req, res) => {
        const { limit, startAfter } = req.query;
        try {
            const { courses, totalCount } = await getAllCoursesPaginated(parseInt(limit), startAfter);
            res.status(200).json({ courses, totalCount });
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    };

    lockUser = async (req, res) => {
        const { uid } = req.body;
        try {
            const message = await lockUser(uid);
            res.status(200).json({ message });
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    }

    unlockUser = async (req, res) => {
        const { uid } = req.body;
        try {
            const message = await unlockUser(uid);
            res.status(200).json({ message });
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    }

}

module.exports = new AdminController();
