require('dotenv').config();

const nodeMailer = require('nodemailer')

const transporter = nodeMailer.createTransport({
    host: process.env.EMAIL_HOST,
    port: process.env.PORT,
    auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASSWORD
    }
})
console.log(process.env.EMAIL_HOST);
console.log(process.env.PORT);
console.log(process.env.EMAIL_USER);
console.log(process.env.EMAIL_PASSWORD);

