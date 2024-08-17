const {
  loginUser,
  logout,
  getEnrollmentsToday,
  getRevenueToday,
  unpublishCourse,
  getAllUsersPaginated,
  getAllCoursesPaginated,
  getAllTransactionsPaginated,
  getAllReportsPaginated,
  lockUser,
  unlockUser,
  getTotalStudents,
  getMonthlyEnrollments,
  getYearlyEnrollments,
  getEnrollmentsByDateRange,
  getTotalCourses,
  getRevenue,
  getYearlyRevenue,
  getMonthlyRevenue,
  getRevenueByDateRange,
  getTotalUsers,
} = require("../service/AdminService");

class AdminController {
  loginController = async (req, res) => {
    const { email, password } = req.body;

    console.log("Login controller triggered with email: ", email);
    try {
      const { uid, token } = await loginUser(email, password);
      console.log("Login successful, responding with uid and token");
      res.status(200).json({ uid, token });
    } catch (error) {
      console.error("Login failed: ", error.message);
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
  };

  showAllUsers = async (req, res) => {
    const { limit, startAfter, searchQuery } = req.query;
    try {
      const { users, totalCount } = await getAllUsersPaginated(
        parseInt(limit),
        startAfter,
        searchQuery || ""
      );
      res.status(200).json({ users, totalCount });
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  };

  showAllCourses = async (req, res) => {
    const { limit, startAfter, searchQuery } = req.query;
    try {
      const { courses, totalCount } = await getAllCoursesPaginated(
        parseInt(limit),
        startAfter,
        searchQuery || "" // Pass searchQuery to getAllCoursesPaginated
      );
      res.status(200).json({ courses, totalCount });
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  };

  unpublishCourse = async (req, res) => {
    try{
      const { courseId } = req.params
      const { authorId, courseName, unpublishReason, reportId } = req.body
      const message = await unpublishCourse(courseId, authorId, courseName, unpublishReason, reportId);
      res.status(204).json(message);
    }catch(error){
      res.status(500).json({ message: error.message });
    }
  }

  showAllTransactions = async (req, res) => {
    const { limit, startAfter, searchQuery } = req.query;
    try {
      const { transactions, totalCount } = await getAllTransactionsPaginated(
        parseInt(limit),
        startAfter,
        searchQuery || "" // Pass searchQuery to getAllCoursesPaginated
      );
      res.status(200).json({ transactions, totalCount });
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  };

  showAllReports = async (req, res) => {
    const { limit, startAfter, searchQuery } = req.query;
    try {
      const { reports, totalCount } = await getAllReportsPaginated(
        parseInt(limit),
        startAfter,
        searchQuery || "" // Pass searchQuery to getAllCoursesPaginated
      );
      res.status(200).json({ reports, totalCount });
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
  };

  unlockUser = async (req, res) => {
    const { uid } = req.body;
    try {
      const message = await unlockUser(uid);
      res.status(200).json({ message });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  };

  getTotalStudentsController = async (req, res) => {
    try {
      const totalStudents = await getTotalStudents();
      res.status(200).json({ totalStudents });
    } catch (error) {
      console.error("Error getting total students:", error);
      res.status(500).json({ message: "Error getting total students" });
    }
  };

  getMonthlyEnrollments = async (req, res) => {
    const { year } = req.query;
    try {
      const monthlyEnrollments = await getMonthlyEnrollments(year);
      res.status(200).json({ enrollments: monthlyEnrollments });
    } catch (error) {
      console.error("Error getting monthly enrollments:", error);
      res.status(500).json({ message: "Error getting monthly enrollments" });
    }
  };

  getYearlyEnrollments = async (req, res) => {
    try {
      const yearlyEnrollments = await getYearlyEnrollments();
      res.status(200).json({ enrollments: yearlyEnrollments });
    } catch (error) {
      console.error("Error getting yearly enrollments:", error);
      res.status(500).json({ message: "Error getting yearly enrollments" });
    }
  };

  getEnrollmentsByDateRange = async (req, res) => {
    const { startDate, endDate } = req.query;
    try {
      const enrollments = await getEnrollmentsByDateRange(startDate, endDate);
      res.status(200).json({ enrollments });
    } catch (error) {
      console.error("Error getting enrollments:", error);
      res.status(500).json({ message: "Error getting enrollments" });
    }
  };
  getEnrollmentsToday = async (req, res) => {
    try {
      const enrollments = await getEnrollmentsToday();
      res.status(200).json({enrollments})
    }catch (error) {
      console.error("Error getting enrollments:", error);
      res.status(500).json({ message: "Error getting enrollments" });
    }
  }
  getRevenueToday = async (req, res) => {
    try {
      const revenue = await getRevenueToday();
      res.status(200).json(revenue)
    }catch (error) {
      res.status(500).json({ message: error.message });
    }
  }

  // transactions
  getYearlyRevenue = async (req, res) => {
    try {
      const revenue = await getYearlyRevenue();
      res.status(200).json(revenue);
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  };

  getMonthlyRevenue = async (req, res) => {
    try {
      const { year } = req.params;
      const revenue = await getMonthlyRevenue(year);
      res.status(200).json(revenue);
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  };

  getRevenueByDateRange = async (req, res) => {
    try {
      const { startDate, endDate } = req.query;
      const revenue = await getRevenueByDateRange(startDate, endDate);
      res.status(200).json(revenue);
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  };
  getTotalUsers = async (req, res) => {
    try {
      const totalUsers = await getTotalUsers();
      res.status(200).json({ totalUsers });
    } catch (error) {
      console.error("Error getting total users", error);
      res.status(500).json({ message: "Error getting total users" });
    }
  };

  // getTotalCourses
  getTotalCourses = async (req, res) => {
    try {
      const totalCourses = await getTotalCourses();
      res.status(200).json({ totalCourses });
    } catch (error) {
      console.error("Error getting total courses", error);
      res.status(500).json({ message: "Error getting total courses" });
    }
  };
  //   getRevenue
  getRevenue = async (req, res) => {
    try {
      const totalRevenue = await getRevenue();
      res.status(200).json({ totalRevenue });
    } catch (error) {
      console.error("Error getting revenue", error);
      res.status(500).json({ message: "Error getting revenue" });
    }
  };
}

module.exports = new AdminController();
