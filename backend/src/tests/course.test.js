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

describe('POST /courses/top5', () => {
  it('should get top5 courses', async () => {
    console.log(token)
    const res = await request(app)
      .get('/api/courses/top5')
      .set('Authorization', `Bearer ${token}`);

    console.log('Response Status:', res.statusCode);  // Kiểm tra mã trạng thái phản hồi
    console.log('Response Body:', res.body);  // Kiểm tra nội dung phản hồi

    expect(res.statusCode).toEqual(200);
    expect(res.body.courses.length).toBeGreaterThan(0);
  });
});
