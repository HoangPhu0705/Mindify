const request = require('supertest');
const app = require('../app');
const { token } = require('./authenticate.test');

describe('Course Routes', () => {
  it('should search courses', async () => {
    const query = 'code';
    
    const res = await request(app)
      .post('/api/courses/searchCourses')
      .set('Authorization', `Bearer ${token}`)
      .send({ query });

    console.log('Response Status:', res.statusCode);  // Kiểm tra mã trạng thái phản hồi
    console.log('Response Body:', res.body);  // Kiểm tra nội dung phản hồi
    
    expect(res.statusCode).toEqual(200);
    expect(res.body.courses.length).toBeGreaterThan(0);
  });
});
