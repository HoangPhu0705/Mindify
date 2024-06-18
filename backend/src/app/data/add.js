// const fs = require('fs');
// const axios = require('axios');

// // Đọc dữ liệu từ file JSON
// const courses = JSON.parse(fs.readFileSync('courses.json', 'utf8'));

// // Function to split array into chunks
// function chunkArray(array, size) {
//   const result = [];
//   for (let i = 0; i < array.length; i += size) {
//     result.push(array.slice(i, i + size));
//   }
//   return result;
// }

// // Function to send chunks
// async function sendChunks(courses) {
//   const chunks = chunkArray(courses, 10); // Chia nhỏ thành các phần 10 khóa học mỗi lần
//   for (const chunk of chunks) {
//     try {
//       const response = await axios.post('http://localhost:3000/courses/batch', chunk);
//       console.log('Chunk sent successfully:', response.data);
//     } catch (error) {
//       console.error('Error sending chunk:', error.response ? error.response.data : error.message);
//     }
//   }
// }

// sendChunks(courses);
