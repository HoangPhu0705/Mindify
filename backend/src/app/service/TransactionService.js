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
exports.createVnpayPaymentUrl = async (courseId, userId, amount) => {
    const tmnCode = configVNP.vnp_TmnCode;
    const secretKey = configVNP.vnp_HashSecret;
    const vnpUrl = configVNP.vnp_Url;
    const returnUrl = configVNP.vnp_ReturnUrl;

    const createDate = moment().format('YYYYMMDDHHmmss');
    const orderId = moment().format('YYYYMMDDHHmmss');
    const orderInfo = `Payment for course ${courseId}`;
    const orderType = 'topup';
    const locale = 'vn';
    const currCode = 'VND';

    const vnpParams = {
        vnp_Version: '2.1.0',
        vnp_Command: 'pay',
        vnp_TmnCode: tmnCode,
        vnp_Amount: (amount * 100).toString(), // Amount in VNPAY is in smallest currency unit
        vnp_CreateDate: createDate,
        vnp_CurrCode: currCode,
        vnp_IpAddr: '127.0.0.1',
        vnp_Locale: locale,
        vnp_OrderInfo: orderInfo,
        vnp_OrderType: orderType,
        vnp_ReturnUrl: returnUrl,
        vnp_TxnRef: orderId,
        vnp_ExpireDate: moment().add(15, 'minutes').format('YYYYMMDDHHmmss')
    };

    const sortedParams = Object.keys(vnpParams).sort().reduce((result, key) => {
        result[key] = vnpParams[key];
        return result;
    }, {});

    const signData = querystring.stringify(sortedParams, { encode: false });
    const hmac = crypto.createHmac('sha512', secretKey);
    const signed = hmac.update(Buffer.from(signData, 'utf-8')).digest('hex');
    sortedParams['vnp_SecureHash'] = signed;
    const paymentUrl = vnpUrl + '?' + querystring.stringify(sortedParams, { encode: false });

    await TransactionCollection.doc(orderId).set({
        courseId,
        userId,
        payment: "VNPAY",
        status: 'pending',
        amount: amount,
        currency: 'vnd',
        createdAt: firestore.FieldValue.serverTimestamp(),
    });

    return paymentUrl;
};

exports.verifyVnpayPayment = async (vnpParams) => {
    const secureHash = vnpParams['vnp_SecureHash'];
    delete vnpParams['vnp_SecureHash'];
    delete vnpParams['vnp_SecureHashType'];

    const sortedParams = Object.keys(vnpParams).sort().reduce((result, key) => {
        result[key] = vnpParams[key];
        return result;
    }, {});

    const signData = querystring.stringify(sortedParams, { encode: false });
    const hmac = crypto.createHmac('sha512', configVNP.vnp_HashSecret);
    const signed = hmac.update(new Buffer.from(signData, 'utf-8')).digest('hex');

    if (secureHash === signed) {
        const responseCode = vnpParams['vnp_ResponseCode'];
        const transactionRef = vnpParams['vnp_TxnRef'];
        if (responseCode === '00') {
            const { courseId, userId } = vnpParams['vnp_OrderInfo'].split(' ');

            const enrollment = await EnrollmentService.createEnrollment({ userId, courseId, paymentIntentId: transactionRef });

            await TransactionCollection.doc(transactionRef).update({
                status: 'succeeded',
                amount: vnpParams['vnp_Amount'] / 100,
                currency: vnpParams['vnp_CurrCode'],
                enrollmentId: enrollment.enrollmentId,
                confirmedAt: firestore.FieldValue.serverTimestamp(),
            });

            return { success: true, message: 'Payment successful', enrollmentId: enrollment.enrollmentId };
        } else {
            await TransactionCollection.doc(transactionRef).update({
                status: 'failed',
            });

            return { success: false, message: 'Payment failed', vnpParams };
        }
    } else {
        return { success: false, message: 'Invalid signature' };
    }
};

