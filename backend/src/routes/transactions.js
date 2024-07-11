const express = require('express');
const router = express.Router();
const TransactionController = require('../app/controllers/TransactionController');

router.post('/createPaymentIntent', TransactionController.createPaymentIntent);
router.post('/confirmPayment', TransactionController.confirmPayment);

module.exports = router;
