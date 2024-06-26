const { UserCollection, RequestCollection } = require('./Collections');
const nodemailer = require('nodemailer');
require('dotenv').config();

const transporter = nodemailer.createTransport({
    host: process.env.EMAIL_HOST,
    port: process.env.EMAIL_PORT,
    secure: false,
    auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASSWORD
    }
});

const sendApprovalEmail = async (email, firstName) => {
    const mailOptions = {
        from: process.env.EMAIL_USER,
        to: email,
        subject: 'Approval Success Notification',
        text: `Hello ${firstName},\n\nYour instructor sign-up request has been approved.\n\nBest regards,\nPhu Phan`
    };

    return transporter.sendMail(mailOptions);
};

exports.saveCourseForUser = async (userId, courseId) => {
    try {
        const userRef = UserCollection.doc(userId);
        const userDoc = await userRef.get();
        if (!userDoc.exists) {
            throw new Error("User didn't exists");
        }

        const userData = userDoc.data();
        const savedClasses = userData.savedClasses || [];

        if (!savedClasses.includes(courseId)) {
            savedClasses.push(courseId);
            await userRef.update({
                savedClasses: savedClasses
            });
        }

        // return { message: 'Save course successfully', savedClasses: savedClasses };
        return { message: 'Save course successfully' }
    } catch (error) {
        throw new Error(`Error when save course for user: ${error.message}`);
    }
};

exports.unsaveCourseForUser = async (userId, courseId) => {
    try {
        const userRef = UserCollection.doc(userId);
        const userDoc = await userRef.get();
        if (!userDoc.exists) {
            throw new Error("User doesn't exist");
        }

        const userData = userDoc.data();
        const savedClasses = userData.savedClasses || [];

        if (savedClasses.includes(courseId)) {
            const updatedSavedClasses = savedClasses.filter(id => id !== courseId);
            await userRef.update({
                savedClasses: updatedSavedClasses
            });
        }

        return { message: 'Unsave course successfully' };
    } catch (error) {
        throw new Error(`Error when unsaving course for user: ${error.message}`);
    }
};

exports.getSavedCourses = async (userId) => {
    try {
        const userRef = UserCollection.doc(userId);
        const userDoc = await userRef.get();
        if (!userDoc.exists) {
            throw new Error("User doesn't exist");
        }

        const userData = userDoc.data();
        const savedClasses = userData.savedClasses || [];

        return { savedClasses: savedClasses };
    } catch (error) {
        throw new Error(`Error when getting saved courses for user: ${error.message}`);
    }
};

exports.createInstructorSignUpRequest = async (data) => {
    try {
        await RequestCollection.add(data);
        return { message: 'Instructor sign up request sent successfully' }

        
    }catch(error){
        throw new Error(`Error when sending instructor sign up request: ${error.message}`);
    }    
}


exports.approveInstructorRequest = async (requestId) => {
    try {
        const requestRef = RequestCollection.doc(requestId);
        const requestDoc = await requestRef.get();
        
        if (!requestDoc.exists) {
            throw new Error("Request doesn't exist");
        }

        const requestData = requestDoc.data();
        const userId = requestData.user_id;

        await requestRef.update({ isApproved: true });

        const userRef = UserCollection.doc(userId);
        const userDoc = await userRef.get();

        if (!userDoc.exists) {
            throw new Error("User doesn't exist");
        }

        await userRef.update({
            role: 'teacher',
            category: requestData.category,
            countryName: requestData.countryName,
            dob: requestData.dob,
            phoneNumber: requestData.phoneNumber,
            topicDescription: requestData.topicDescription
        });

        await sendApprovalEmail(requestData.user_email, requestData.firstName);

        return { message: 'Request approved and user updated successfully' };
    } catch (error) {
        throw new Error(`Error when approving request and updating user: ${error.message}`);
    }
};

exports.getUnapprovedRequests = async () => {
    try {
        const snapshot = await RequestCollection.where('isApproved', '==', false).get();
        if (snapshot.empty) {
            return [];
        }

        const requests = [];
        snapshot.forEach(doc => {
            requests.push({ id: doc.id, ...doc.data() });
        });

        return requests;
    } catch (error) {
        throw new Error(`Error happened when fetching unapproved requests: ${error.message}`);
    }
};


exports.getRequestDetails = async (requestId) => {
    try {
        const requestRef = RequestCollection.doc(requestId);
        const requestDoc = await requestRef.get();
        if (!requestDoc.exists) {
            throw new Error("Request doesn't exist");
        }

        const requestData = requestDoc.data();
        const userId = requestData.user_id;

        const userRef = UserCollection.doc(userId);
        const userDoc = await userRef.get();
        if (!userDoc.exists) {
            throw new Error("User doesn't exist");
        }

        const userData = userDoc.data();
        return { user: userData, request: requestData };
    } catch (error) {
        throw new Error(`Error fetching request details: ${error.message}`);
    }
};

