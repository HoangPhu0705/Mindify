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
            metadata: { courseId: courseId }
        });

        const enrollment = await EnrollmentService.createEnrollment({ userId, courseId, paymentIntent });

        await TransactionCollection.doc(paymentIntent.id).set({
            courseId,
            userId,
            status: 'succeeded',
            amount: course.price,
            currency: 'vnd',
            createdAt: firestore.FieldValue.serverTimestamp(),
            enrollmentId: enrollment.enrollmentId,
          });

        return {
          paymentIntent: paymentIntent.client_secret,
          paymentIntentData: paymentIntent,
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

        // if (paymentIntent.status !== 'succeeded') {
        //     throw new Error('Payment not successful');
        // }

        // const enrollment = await require('./EnrollemntService').createEnrollment({ userId, courseId });

        // // Transaction
        // const transactionDoc = TransactionCollection.doc();
        // await transactionDoc.set({
        //     userId,
        //     courseId,
        //     paymentIntentId,
        //     amount: paymentIntent.amount,
        //     currency: paymentIntent.currency,
        //     status: paymentIntent.status,
        //     enrollmentId: enrollment.enrollmentId,
        //     transactionDate: new Date()
        // });

        // return { enrollmentId: enrollment.enrollmentId };


        // nhap
        if (paymentIntent.status === 'succeeded') {
            const { courseId, userId } = paymentIntent.metadata;
        
            
        
            // await db.collection('enrollments').add({
            //   userId,
            //   courseId,
            //   paymentIntentId,
            //   status: 'enrolled',
            //   enrolledAt: admin.firestore.FieldValue.serverTimestamp(),
            // });

            const enrollment = await EnrollmentService.createEnrollment({ userId, courseId, paymentIntent });
            await TransactionCollection.doc(paymentIntentId).update({
                status: 'succeeded',
                amount: paymentIntent.amount,
                currency: paymentIntent.currency,
                status: paymentIntent.status,
                enrollmentId: enrollment.enrollmentId,
                confirmedAt: firestore.FieldValue.serverTimestamp(),
              });
            return { success: true };
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
