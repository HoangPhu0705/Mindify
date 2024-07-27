const express = require('express');
const AdminController = require('../app/controllers/AdminController');

const router = express.Router();

router.post('/admin-login', AdminController.loginController);
router.get('/admin-logout', AdminController.logOut);
router.get('/users-management', AdminController.showAllUsers);
router.get('/courses-management', AdminController.showAllCourses);
router.get('/total-students', AdminController.getTotalStudentsController);
router.get('/total-users', AdminController.getTotalUsers)
router.get('/monthly-enrollments', AdminController.getMonthlyEnrollments);
router.get('/yearly-enrollments', AdminController.getYearlyEnrollments);
router.get('/date-range-enrollments', AdminController.getEnrollmentsByDateRange);
router.get('/total-courses', AdminController.getTotalCourses);
router.get('/get-revenue', AdminController.getRevenue);
router.get('/yearly-transactions', AdminController.getYearlyRevenue);
router.get('/monthly-transactions', AdminController.getMonthlyRevenue);
router.get('/date-range-transactions', AdminController.getRevenueByDateRange);
router.post('/lock-user', AdminController.lockUser);
router.post('/unlock-user', AdminController.unlockUser);

module.exports = router;
