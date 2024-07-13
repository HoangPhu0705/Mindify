require('dotenv').config();
const crypto = require('crypto');
const moment = require('moment');
const { configVNP } = require('../../config/config_VNPAY');
const querystring = require('querystring');
const STRIPE_SK = process.env.STRIPE_SECRET_KEY
const EnrollmentService = require('./EnrollmentService');
const { firestore } = require('firebase-admin');
const { CourseCollection, TransactionCollection } = require('./Collections');

const stripe = require('stripe')(STRIPE_SK);

exports.createPaymentIntent = async (courseId, userId) => {
    try {
        const courseDoc = await CourseCollection.doc(courseId).get();
        if (!courseDoc.exists) {
            throw new Error('Course not found');
        }

        const course = courseDoc.data();
        const paymentIntent = await stripe.paymentIntents.create({
            amount: course.price,
            currency: 'vnd',
            metadata: { courseId: courseId, userId: userId }
        });

        await TransactionCollection.doc(paymentIntent.id).set({
            courseId,
            userId,
            payment: "Stripe",
            status: 'pending',
            amount: course.price,
            currency: 'vnd',
            createdAt: firestore.FieldValue.serverTimestamp(),
            // Enrollment will be created in confirmPayment
        });

        return {
            paymentIntent: paymentIntent.client_secret,
            paymentIntentId: paymentIntent.id,
            amount: course.price,
            currency: 'vnd'
        };
    } catch (error) {
        console.error('Error creating payment intent:', error);
        throw error;
    }
};

exports.confirmPayment = async (paymentIntentId) => {
    try {
        const paymentIntent = await stripe.paymentIntents.retrieve(paymentIntentId);

        if (paymentIntent.status === 'succeeded') {
            const { courseId, userId } = paymentIntent.metadata;

            const enrollment = await EnrollmentService.createEnrollment({ userId, courseId, paymentIntentId });

            await TransactionCollection.doc(paymentIntentId).update({
                status: 'succeeded',
                amount: paymentIntent.amount,
                currency: paymentIntent.currency,
                enrollmentId: enrollment.enrollmentId,
                confirmedAt: firestore.FieldValue.serverTimestamp(),
            });

            return { success: true, enrollmentId: enrollment.enrollmentId };
        } else {
            await TransactionCollection.doc(paymentIntentId).update({
                status: 'failed',
            });

            throw new Error('Payment not succeeded');
        }
    } catch (error) {
        console.error('Error confirming payment:', error);
        throw error;
    }
};

// VNPAY
exports.createVNPayPayment = async (courseId, userId) => {
    try {
        const courseDoc = await CourseCollection.doc(courseId).get();
        if (!courseDoc.exists) {
            throw new Error('Course not found');
        }

        const course = courseDoc.data();
        const amount = course.price * 100;
        const orderId = Date.now().toString();
        const createDate = moment().format('YYYYMMDDHHmmss');

        const vnp_Params = {
            vnp_Version: '2.0.0',
            vnp_TmnCode: configVNP.vnp_TmnCode,
            vnp_Amount: amount,
            vnp_Command: 'pay',
            vnp_CreateDate: createDate,
            vnp_CurrCode: 'VND',
            vnp_IpAddr: '127.0.0.1',
            vnp_Locale: 'vn',
            vnp_OrderInfo: `Thanh toan khoa hoc ${courseId}`,
            vnp_OrderType: 'billpayment',
            vnp_TxnRef: orderId,
        };

        vnp_Params.vnp_SecureHash = createSecureHash(vnp_Params);

        const paymentUrl = `${configVNP.vnp_Url}?${querystring.stringify(vnp_Params)}`;

        await TransactionCollection.doc(orderId).set({
            courseId,
            userId,
            payment: 'VNPay',
            status: 'pending',
            amount: course.price,
            currency: 'vnd',
            createdAt: firestore.FieldValue.serverTimestamp(),
        });

        return {
            paymentUrl,
            orderId,
            amount: course.price,
            currency: 'vnd',
        };
    } catch (error) {
        console.error('Error creating VNPay payment:', error);
        throw error;
    }
};

function createSecureHash(vnp_Params) {
    const signData = querystring.stringify(vnp_Params, { encode: false });
    const hmac = crypto.createHmac('sha512', configVNP.vnp_HashSecret);
    return hmac.update(Buffer.from(signData, 'utf-8')).digest('hex');
}

exports.confirmVNPayPayment = async (vnpParams) => {
    try {
        const secureHash = vnpParams['vnp_SecureHash'];
        delete vnpParams['vnp_SecureHash'];

        const sortedParams = {};
        const sortedKeys = Object.keys(vnpParams).sort();
        sortedKeys.forEach(key => {
            sortedParams[key] = vnpParams[key];
        });

        const querystring = new URLSearchParams(sortedParams).toString();
        const hashData = crypto.createHmac('sha512', configVNP.vnp_HashSecret).update(querystring).digest('hex');

        if (secureHash !== hashData) {
            throw new Error('Invalid secure hash');
        }

        const transactionDoc = await TransactionCollection.doc(vnpParams['vnp_TxnRef']).get();
        if (!transactionDoc.exists) {
            throw new Error('Transaction not found');
        }

        const transaction = transactionDoc.data();
        if (vnpParams['vnp_ResponseCode'] === '00') {
            const { courseId, userId } = transaction;

            const enrollment = await EnrollmentService.createEnrollment({ userId, courseId, paymentIntentId: vnpParams['vnp_TxnRef'] });

            await TransactionCollection.doc(vnpParams['vnp_TxnRef']).update({
                status: 'succeeded',
                amount: vnpParams['vnp_Amount'],
                currency: 'vnd',
                enrollmentId: enrollment.enrollmentId,
                confirmedAt: firestore.FieldValue.serverTimestamp(),
            });

            return { success: true, enrollmentId: enrollment.enrollmentId };
        } else {
            await TransactionCollection.doc(vnpParams['vnp_TxnRef']).update({
                status: 'failed',
            });

            throw new Error('Payment not succeeded');
        }
    } catch (error) {
        console.error('Error confirming VNPay payment:', error);
        throw error;
    }
};