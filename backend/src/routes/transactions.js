const express = require('express');
const router = express.Router();
const TransactionController = require('../app/controllers/TransactionController');
//Stripe
router.post('/createPaymentIntent', TransactionController.createPaymentIntent);
router.post('/confirmPayment', TransactionController.confirmPayment);
// VNPay
router.post('/createVNPayPayment', TransactionController.createVNPayPayment);
router.get('/confirmVNPayPayment', TransactionController.confirmVNPayPayment);
module.exports = router;
