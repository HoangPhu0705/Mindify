const request = require('supertest');
const app = require('../app');
const { signInUser } = require('./authenticate.test');
let token
beforeAll(async () => {
    const email = 'hieuga678902003@gmail.com';
    const password = '123456';
    const idToken = await signInUser(email, password);
    token = idToken;
});

describe('GET /:userId/checkSavedCourses?courseId=:courseId', () => {
    it('should return true if user saved the course', async () => {
        // console.log(token)
        const userId = "AMAVeLkYQeW1q6U0ZPka5k8FLeL2";
        const courseId = "wQJnzGx5aMBwJvxy4Uq3"
        const res = await request(app)
            .get(`/api/users/${userId}/checkSavedCourse?courseId=${courseId}`)
            .set('Authorization', `Bearer ${token}`);

        // console.log('Response Status:', res.statusCode);  
        // console.log('Response Body:', res.body); 

        expect(res.statusCode).toEqual(200);
        expect(res.body).toHaveProperty('isSaved', res.body.isSaved);
        expect(res.body.isSaved).toEqual(true);
        //   expect(res.body.length).toBeGreaterThan(0);
    });
    it('should return false if user saved the course', async () => {
        // console.log(token)
        const userId = "AMAVeLkYQeW1q6U0ZPka5k8FLeL2";
        const courseId = "0RQOju0oLh3ANohplN5a"
        const res = await request(app)
            .get(`/api/users/${userId}/checkSavedCourse?courseId=${courseId}`)
            .set('Authorization', `Bearer ${token}`);

        // console.log('Response Status:', res.statusCode);  
        // console.log('Response Body:', res.body); 

        expect(res.statusCode).toEqual(200);
        expect(res.body).toHaveProperty('isSaved', res.body.isSaved);
        expect(res.body.isSaved).toEqual(false);

        //   expect(res.body.length).toBeGreaterThan(0);
    });
    it('should get 401 because of no token to authorization', async () => {
        const userId = "AMAVeLkYQeW1q6U0ZPka5k8FLeL2";
        const courseId = "wQJnzGx5aMBwJvxy4Uq3"
        const res = await request(app)
            .get(`/api/users/${userId}/checkSavedCourse?courseId=${courseId}`)

        // console.log('Response Status:', res.statusCode);  
        // console.log('Response Body:', res.body); 

        expect(res.statusCode).toEqual(401);
    });
});

describe('POST /:userId/savedCourses', () => {
    it('should return true if user saved the course', async () => {
        // console.log(token)
        const userId = "AMAVeLkYQeW1q6U0ZPka5k8FLeL2";
        const courseId = "0RQOju0oLh3ANohplN5a"
        const res = await request(app)
            .post(`/api/users/${userId}/saveCourse`)
            .set('Authorization', `Bearer ${token}`)
            .send({ courseId })

        expect(res.statusCode).toEqual(201);
        // message: 'Save course successfully'
        expect(res.body).toHaveProperty('message', res.body.message);
        expect(res.body.message).toEqual('Save course successfully');
    });
    it('should get 401 because of no token to authorization', async () => {
        const userId = "AMAVeLkYQeW1q6U0ZPka5k8FLeL2";
        const courseId = "0RQOju0oLh3ANohplN5a"
        const res = await request(app)
            .post(`/api/users/${userId}/saveCourse`)
            .send({ courseId })
        expect(res.statusCode).toEqual(401);
    });
});

describe('POST /:userId/unSavedCourse', () => {
    it('should return true if user saved the course', async () => {
        // console.log(token)
        const userId = "AMAVeLkYQeW1q6U0ZPka5k8FLeL2";
        const courseId = "0RQOju0oLh3ANohplN5a"
        const res = await request(app)
            .post(`/api/users/${userId}/unsaveCourse`)
            .set('Authorization', `Bearer ${token}`)
            .send({ courseId })

        expect(res.statusCode).toEqual(200);
        // message: 'Unsave course successfully'
        expect(res.body).toHaveProperty('message', res.body.message);
        expect(res.body.message).toEqual('Unsave course successfully');
    });
    it('should get 401 because of no token to authorization', async () => {
        const userId = "AMAVeLkYQeW1q6U0ZPka5k8FLeL2";
        const courseId = "0RQOju0oLh3ANohplN5a"
        const res = await request(app)
            .post(`/api/users/${userId}/unsaveCourse`)
            .send({ courseId })
        expect(res.statusCode).toEqual(401);
    });
});

// followUserId
describe('POST /:userId/follow', () => {
    it('should return true if user saved the course', async () => {
        // console.log(token)
        const userId = "AMAVeLkYQeW1q6U0ZPka5k8FLeL2";
        const followUserId = "IGCGG54sO4QjSIj206dfWnbX2mR2"
        const res = await request(app)
            .post(`/api/users/${userId}/follow`)
            .set('Authorization', `Bearer ${token}`)
            .send({ followUserId })

        expect(res.statusCode).toEqual(200);
        // message: 'Successfully followed the user'
        expect(res.body).toHaveProperty('message', res.body.message);
        expect(res.body.message).toEqual('Successfully followed the user');
    });
    it('should get 401 because of no token to authorization', async () => {
        const userId = "AMAVeLkYQeW1q6U0ZPka5k8FLeL2";
        const followUserId = "IGCGG54sO4QjSIj206dfWnbX2mR2"
        const res = await request(app)
            .post(`/api/users/${userId}/follow`)
            .send({ followUserId })
        expect(res.statusCode).toEqual(401);
    });
});

// unfollowUserId
describe('POST /:userId/unfollow', () => {
    it('should return true if user saved the course', async () => {
        // console.log(token)
        const userId = "AMAVeLkYQeW1q6U0ZPka5k8FLeL2";
        const unfollowUserId = "IGCGG54sO4QjSIj206dfWnbX2mR2"
        const res = await request(app)
            .post(`/api/users/${userId}/unfollow`)
            .set('Authorization', `Bearer ${token}`)
            .send({ unfollowUserId })

        expect(res.statusCode).toEqual(200);
        // message: 'Successfully unfollowed the user'
        expect(res.body).toHaveProperty('message', res.body.message);
        expect(res.body.message).toEqual('Successfully unfollowed the user');
    });
    it('should get 401 because of no token to authorization', async () => {
        const userId = "AMAVeLkYQeW1q6U0ZPka5k8FLeL2";
        const unfollowUserId = "IGCGG54sO4QjSIj206dfWnbX2mR2"
        const res = await request(app)
            .post(`/api/users/${userId}/unfollow`)
            .send({ unfollowUserId })
        expect(res.statusCode).toEqual(401);
    });
});