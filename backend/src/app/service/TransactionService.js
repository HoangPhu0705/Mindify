require('dotenv').config();
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
