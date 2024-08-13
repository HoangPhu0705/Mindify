// cBplvRJ366Zapos0k2G4oRsM0xU2

// HzCIT55fq624DohU5U0e

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
// sY6owsqSRA91a6ptId5u
// get project of user
describe('GET /courses/:courseId/lessons', () => {
    it('should get lessons for courseId = HzCIT55fq624DohU5U0e', async () => {
        // console.log(token)
        const courseId = 'HzCIT55fq624DohU5U0e';
        // const userId = 'cBplvRJ366Zapos0k2G4oRsM0xU2'
        const res = await request(app)
            .get(`/api/courses/${courseId}/lessons`)
            .set('Authorization', `Bearer ${token}`);

        // console.log('Response Status:', res.statusCode);  
        // console.log('Response Body:', res.body); 

        expect(res.statusCode).toEqual(200);
        expect(res.body.length).toEqual(7);
    });
    it('should get 401 because of no token to authorization', async () => {
        // console.log(token)
        const courseId = 'HzCIT55fq624DohU5U0e';
        // const userId = 'cBplvRJ366Zapos0k2G4oRsM0xU2'
        const res = await request(app)
            .get(`/api/courses/${courseId}/lessons`)

        // console.log('Response Status:', res.statusCode);  
        // console.log('Response Body:', res.body); 

        expect(res.statusCode).toEqual(401);
    });
});