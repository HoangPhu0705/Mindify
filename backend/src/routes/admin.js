const express = require('express');
const AdminController = require('../app/controllers/AdminController');
const { authenticateJWT } = require('../app/middleware/auth')
const router = express.Router();

router.post('/admin-login', AdminController.loginController);
router.get('/admin-logout', AdminController.logOut);
router.get('/users-management', authenticateJWT, AdminController.showAllUsers);
router.get('/transactions-management', authenticateJWT, AdminController.showAllTransactions);
router.get('/revenue-today', authenticateJWT, AdminController.getRevenueToday);
router.get('/enrollments-today', authenticateJWT, AdminController.getEnrollmentsToday);
router.get('/reports', authenticateJWT, AdminController.showAllReports);
router.get('/courses-management', authenticateJWT, AdminController.showAllCourses);
router.get('/total-students', authenticateJWT, AdminController.getTotalStudentsController);
router.get('/total-users', authenticateJWT, AdminController.getTotalUsers)
router.get('/monthly-enrollments', authenticateJWT, AdminController.getMonthlyEnrollments);
router.get('/yearly-enrollments', authenticateJWT, AdminController.getYearlyEnrollments);
router.get('/date-range-enrollments', authenticateJWT, AdminController.getEnrollmentsByDateRange);
router.get('/total-courses', authenticateJWT, AdminController.getTotalCourses);
router.get('/get-revenue', authenticateJWT, AdminController.getRevenue);
router.get('/yearly-transactions', authenticateJWT, AdminController.getYearlyRevenue);
router.get('/monthly-transactions', authenticateJWT, AdminController.getMonthlyRevenue);
router.get('/date-range-transactions', authenticateJWT, AdminController.getRevenueByDateRange);
router.post('/lock-user', authenticateJWT, AdminController.lockUser);
router.post('/unlock-user', authenticateJWT, AdminController.unlockUser);
router.patch('/unpublish/:courseId', authenticateJWT, AdminController.unpublishCourse);
module.exports = router;
