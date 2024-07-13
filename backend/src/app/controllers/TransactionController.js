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
exports.createVNPayPayment = async (req, res) => {
    const { courseId, userId } = req.body;
    if (!courseId || !userId) {
        return res.status(400).json({ error: 'Missing courseId or userId' });
    }

    try {
        const paymentData = await TransactionService.createVNPayPayment(courseId, userId);
        res.status(201).json(paymentData);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.confirmVNPayPayment = async (req, res) => {
    const vnpParams = req.query;

    try {
        const enrollment = await TransactionService.confirmVNPayPayment(vnpParams);
        res.status(200).json(enrollment);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
