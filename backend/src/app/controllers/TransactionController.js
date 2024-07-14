const TransactionService = require('../service/TransactionService');
// Stripe
exports.createPaymentIntent = async (req, res) => {
    const { courseId, userId } = req.body;
    if (!courseId || !userId) {
        return res.status(400).json({ error: 'Missing courseId or userId' });
    }

    try {
        const paymentIntent = await TransactionService.createPaymentIntent(courseId, userId);
        res.status(201).json(paymentIntent);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.confirmPayment = async (req, res) => {
    const { paymentIntentId } = req.body;
    if (!paymentIntentId) {
        return res.status(400).json({ error: 'Missing paymentIntentId, userId, or courseId' });
    }

    try {
        const enrollment = await TransactionService.confirmPayment(paymentIntentId);
        res.status(200).json(enrollment);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
// VNPAY
exports.createVnpayPaymentUrl = async (req, res) => {
    const { courseId, userId, amount } = req.body;
    if (!courseId || !userId || !amount) {
        return res.status(400).json({ error: 'Missing courseId, userId, or amount' });
    }

    try {
        const paymentUrl = await TransactionService.createVnpayPaymentUrl(courseId, userId, amount);
        res.status(201).json({ paymentUrl });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.verifyVnpayPayment = async (req, res) => {
    try {
        const vnpParams = req.query;
        const result = await TransactionService.verifyVnpayPayment(vnpParams);
        res.status(result.success ? 200 : 400).json(result);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
