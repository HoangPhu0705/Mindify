const { loginUser } = require('../app/service/AdminService');
let token;
describe('Firebase Authentication', () => {
  it('should log in and retrieve ID token', async () => {
    const email = 'hieuga678902003@gmail.com';
    const password = '123456';

    const idToken = await loginUser(email, password);
    token = idToken.token
    expect(idToken).toBeDefined();
    console.log('Retrieved ID token:', JSON.stringify(idToken.token));
    console.log('Token:', token); // Thêm dòng này trong test của bạn

  });
});

module.exports = { token };
