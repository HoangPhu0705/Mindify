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

describe('GET /courses/top5', () => {
  it('should get top5 courses', async () => {
    // console.log(token)
    const res = await request(app)
      .get('/api/courses/top5')
      .set('Authorization', `Bearer ${token}`);

    // console.log('Response Status:', res.statusCode);  
    // console.log('Response Body:', res.body); 

    expect(res.statusCode).toEqual(200);
    expect(res.body.length).toBeGreaterThan(0);
  });
  it('should get 401 because of no token to authorization', async () => {
    // console.log(token)
    const res = await request(app)
      .get('/api/courses/top5')

    // console.log('Response Status:', res.statusCode);  
    // console.log('Response Body:', res.body); 

    expect(res.statusCode).toEqual(401);
  });
});

describe('GET /courses/newest', () => {
  it('should get 5 newest courses', async () => {
    // console.log(token)
    const res = await request(app)
      .get('/api/courses/top5')
      .set('Authorization', `Bearer ${token}`);

    // console.log('Response Status:', res.statusCode);  
    // console.log('Response Body:', res.body); 

    expect(res.statusCode).toEqual(200);
    expect(res.body.length).toBeGreaterThan(0);
  });
  it('should get 401 because of no token to authorization', async () => {
    // console.log(token)
    const res = await request(app)
      .get('/api/courses/newest')

    // console.log('Response Status:', res.statusCode);  
    // console.log('Response Body:', res.body); 

    expect(res.statusCode).toEqual(401);
  });
});

describe('POST /courses/searchCourses', () => {
  it('should find courses has query is code', async () => {
    // console.log(token)
    const query = "code";
    const res = await request(app)
      .post('/api/courses/searchCourses')
      .set('Authorization', `Bearer ${token}`)
      .send({ query });

    // console.log('Response Status:', res.statusCode);  
    // console.log('Response Body:', res.body); 

    expect(res.statusCode).toEqual(200);
    expect(res.body.courses.length).toBeGreaterThan(0);
  });
  it('should get 401 because of no token to authorization', async () => {
    // console.log(token)
    const query = "code";
    const res = await request(app)
      .post('/api/courses/searchCourses')
      .send({ query });
    // console.log('Response Status:', res.statusCode);  
    // console.log('Response Body:', res.body); 

    expect(res.statusCode).toEqual(401);
  });
});

describe('GET /courses/:courseId/lessons', () => {
  it('should return all the lessons of course by courseId', async () => {
    // console.log(token)
    const courseId = "4vsBY1bDvSnnf3CZeSgB";
    const res = await request(app)
      .get(`/api/courses/${courseId}/lessons`)
      .set('Authorization', `Bearer ${token}`)
    // .send({query});

    // console.log('Response Status:', res.statusCode);  
    // console.log('Response Body:', res.body); 

    expect(res.statusCode).toEqual(200);
    expect(res.body.length).toBeGreaterThan(0);
  });
  it('should get 401 because of no token to authorization', async () => {
    // console.log(token)
    const courseId = "4vsBY1bDvSnnf3CZeSgB";
    const res = await request(app)
      .get(`/api/courses/${courseId}/lessons`)
    // .send({query});
    // console.log('Response Status:', res.statusCode);  
    // console.log('Response Body:', res.body); 

    expect(res.statusCode).toEqual(401);
  });
});