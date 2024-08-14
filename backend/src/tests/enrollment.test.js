const request = require('supertest');
const app = require('../app');
const { signInUser } = require('./authenticate.test');
let token
beforeAll(async () => {
    const email = 'phuhoang07051003@gmail.com';
    const password = '123123';
    const idToken = await signInUser(email, password);
    token = idToken;
    // console.log(token)
});

// HzCIT55fq624DohU5U0e enrolled
// userId: cBplvRJ366Zapos0k2G4oRsM0xU2
//  not enrolled 0RQOju0oLh3ANohplN5a
// course

describe('GET /enrollments/checkEnrollment?userId=:userId&courseId=:courseId CASE TRUE', () => {
    it('should check true for courseId = HzCIT55fq624DohU5U0e of user cBplvRJ366Zapos0k2G4oRsM0xU2', async () => {
        // console.log(token)
        const courseId = 'HzCIT55fq624DohU5U0e';
        const userId = 'cBplvRJ366Zapos0k2G4oRsM0xU2'
        const res = await request(app)
            .get(`/api/enrollments/checkEnrollment?userId=${userId}&courseId=${courseId}`)
            .set('Authorization', `Bearer ${token}`);

        // console.log('Response Status:', res.statusCode);  
        // console.log('Response Body:', res.body); 

        expect(res.statusCode).toEqual(200);
        expect(res.body.isEnrolled).toEqual(true)
        // expect(res.body.length).toEqual(1);
    });
    it('should get 401 because of no token to authorization', async () => {
        // console.log(token)
        const courseId = 'HzCIT55fq624DohU5U0e';
        const userId = 'cBplvRJ366Zapos0k2G4oRsM0xU2'
        const res = await request(app)
            .get(`/api/enrollments/checkEnrollment?userId=${userId}&courseId=${courseId}`)


        // console.log('Response Status:', res.statusCode);  
        // console.log('Response Body:', res.body); 

        expect(res.statusCode).toEqual(401);
    });
});

describe('GET /enrollments/checkEnrollment?userId=:userId&courseId=:courseId CASE FALSE', () => {
    it('should check true for courseId = 0RQOju0oLh3ANohplN5a of user cBplvRJ366Zapos0k2G4oRsM0xU2', async () => {
        // console.log(token)
        const courseId = '0RQOju0oLh3ANohplN5a';
        const userId = 'cBplvRJ366Zapos0k2G4oRsM0xU2'
        const res = await request(app)
            .get(`/api/enrollments/checkEnrollment?userId=${userId}&courseId=${courseId}`)
            .set('Authorization', `Bearer ${token}`);

        // console.log('Response Status:', res.statusCode);  
        // console.log('Response Body:', res.body); 

        expect(res.statusCode).toEqual(200);
        expect(res.body).toEqual(null)
        // expect(res.body.length).toEqual(1);
    });
    it('should get 401 because of no token to authorization', async () => {
        // console.log(token)
        const courseId = '0RQOju0oLh3ANohplN5a';
        const userId = 'cBplvRJ366Zapos0k2G4oRsM0xU2'
        const res = await request(app)
        .get(`/api/enrollments/checkEnrollment?userId=${userId}&courseId=${courseId}`)


        // console.log('Response Status:', res.statusCode);  
        // console.log('Response Body:', res.body); 

        expect(res.statusCode).toEqual(401);
    });
});

describe('GET /enrollments/userEnrollments?userId=:userId', () => {
    it('should get all enrollment of user cBplvRJ366Zapos0k2G4oRsM0xU2', async () => {
        // console.log(token)
        // const courseId = '0RQOju0oLh3ANohplN5a';
        const userId = 'cBplvRJ366Zapos0k2G4oRsM0xU2'
        const res = await request(app)
            .get(`/api/enrollments/userEnrollments?userId=${userId}`)
            .set('Authorization', `Bearer ${token}`);

        // console.log('Response Status:', res.statusCode);  
        // console.log('Response Body:', res.body); 

        expect(res.statusCode).toEqual(200);
        // expect(res.body).toHaveProperty("enrollments", res.body.enrollments)
        expect(res.body.length).toEqual(3);
    });
    it('should get 401 because of no token to authorization', async () => {
        // console.log(token)
        // const courseId = '0RQOju0oLh3ANohplN5a';
        const userId = 'cBplvRJ366Zapos0k2G4oRsM0xU2'
        const res = await request(app)
        .get(`/api/enrollments/checkEnrollment?userId=${userId}`)


        // console.log('Response Status:', res.statusCode);  
        // console.log('Response Body:', res.body); 

        expect(res.statusCode).toEqual(401);
    });
});