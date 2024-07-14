const express = require('express');
const router = express.Router();
const TransactionController = require('../app/controllers/TransactionController');
//Stripe
router.post('/createPaymentIntent', TransactionController.createPaymentIntent);
router.post('/confirmPayment', TransactionController.confirmPayment);
// VNPay
router.post('/createVnpayPaymentUrl', TransactionController.createVnpayPaymentUrl);
router.get('/vnpay_return', TransactionController.verifyVnpayPayment);
module.exports = router;
