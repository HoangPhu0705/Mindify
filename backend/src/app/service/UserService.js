const { UserCollection, RequestCollection } = require('./Collections');
const { transporter } = require('../../utils/sender.util')
const admin = require('firebase-admin');
require('dotenv').config();

const sendRejectionEmail = async (email, firstName, content) => {
    const mailOptions = {
        from: process.env.EMAIL_USER,
        to: email,
        subject: 'Rejection Notification',
        text: `Hello ${firstName},\n\nYour instructor sign-up request has been rejected.
            \n
            ${content}
            \nBest regards,\nPhu Phan`
    };

    return transporter.sendMail(mailOptions);
};

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

        await requestRef.update({ isApproved: true, status: "Approved" });

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

exports.getRequests = async () => {
    try {
        const snapshot = await RequestCollection.get();
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


//Get user data by user id snapsho
exports.getUserData = async (userId) => {
    try {
        const userRef = UserCollection.doc(userId);
        const userDoc = await userRef.get();
        if (!userDoc.exists) {
            throw new Error("User doesn't exist");
        }

        const userData = userDoc.data();
        return userData;
    } catch (error) {
        throw new Error(`Error when getting user data: ${error.message}`);
    }
};

exports.rejectInstructorRequest = async (requestId, content) => {
    try {
        const requestRef = RequestCollection.doc(requestId);
        const requestDoc = await requestRef.get();

        if (!requestDoc.exists) {
            throw new Error("Request doesn't exist");
        }

        const requestData = requestDoc.data();
        const userId = requestData.user_id;
        await requestRef.update({ status: "Declined" });


        const userRef = UserCollection.doc(userId);
        const userDoc = await userRef.get();

        if (!userDoc.exists) {
            throw new Error("User doesn't exist");
        }

        await userRef.update({
            requestSent: false,
            
        });


        await sendRejectionEmail(requestData.user_email, requestData.firstName, content);

        return { message: 'Request rejected successfully' };
    } catch (error) {
        throw new Error(`Error when rejecting request: ${error.message}`);
    }
};

exports.followUser = async (userId, followUserId) => {
    const userRef = UserCollection.doc(userId);
    const followUserRef = UserCollection.doc(followUserId);

    const [userDoc, followUserDoc] = await Promise.all([userRef.get(), followUserRef.get()]);

    if (!userDoc.exists) {
        throw new Error("User doesn't exist");
    }

    if (!followUserDoc.exists) {
        throw new Error("User to follow doesn't exist");
    }

    await admin.firestore().runTransaction(async (transaction) => {
        const userData = userDoc.data();
        const followUserData = followUserDoc.data();

        const updatedFollowingUser = userData.followingUser || [];
        if (!updatedFollowingUser.includes(followUserId)) {
            updatedFollowingUser.push(followUserId);
            transaction.update(userRef, {
                followingUser: updatedFollowingUser,
                followingNum: admin.firestore.FieldValue.increment(1)
            });
        }

        const updatedFollowerUser = followUserData.followerUser || [];
        if (!updatedFollowerUser.includes(userId)) {
            updatedFollowerUser.push(userId);
            transaction.update(followUserRef, {
                followerUser: updatedFollowerUser,
                followerNum: admin.firestore.FieldValue.increment(1)
            });
        }

        const deviceToken = followUserData.deviceToken;
        if (deviceToken) {
            const message = {
                notification: {
                    title: 'New Follower',
                    body: `${userData.displayName} has followed you.`
                },
                token: deviceToken
            };

            await admin.messaging().send(message);
        }

        // save to firestore
        const notificationsRef = UserCollection.doc(followUserId).collection('notifications');
        await notificationsRef.add({
            title: 'New Follower',
            body: `${userData.displayName} has followed you.`,
            timestamp: admin.firestore.FieldValue.serverTimestamp()
        });
    });
};

exports.checkIfUserFollows = async (userId, followUserId) => {
    try {
        const userRef = UserCollection.doc(userId);
        const userDoc = await userRef.get();

        if (!userDoc.exists) {
            throw new Error("User doesn't exist");
        }

        const userData = userDoc.data();
        const followingUser = userData.followingUser || [];

        return followingUser.includes(followUserId);
    } catch (error) {
        throw new Error(`Error when checking if user follows: ${error.message}`);
    }
};

exports.updateUsers = async () => {
    const usersSnapshot = await UserCollection.get();
    const batch = admin.firestore().batch();

    usersSnapshot.forEach((doc) => {
        const userRef = UserCollection.doc(doc.id);
        batch.update(userRef, {
            followerUser: [],
            followingUser: [],
            followerNum: 0,
            followingNum: 0
        });
    });

    await batch.commit();
    console.log("All users updated successfully");
};

exports.getUserNameAndAvatar = async (uid) => {
    try {
        const userRecord = await admin.auth().getUser(uid);
        const displayName = userRecord.displayName;
        const photoUrl = userRecord.photoURL;

        return { displayName, photoUrl };
    } catch (error) {
        console.error("Error fetching user data:", error);
        throw error;
    }
}