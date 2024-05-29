// services/coursesService.js
const { db } = require('../../config/firebase');
const Course = require('../models/course.model');

// Create
async function createCourse(courseData) {
  const docRef = await db.collection('courses').add(courseData);
  return docRef.id;
}

// Read
async function getAllCourses() {
  const snapshot = await db.collection('courses').get();
  const courses = snapshot.docs.map(Course.fromSnapshot);
  return courses;
}

async function getCourseById(id) {
  const doc = await db.collection('courses').doc(id).get();
  if (!doc.exists) {
    throw new Error("Document doesn't exist");
  }
  return Course.fromSnapshot(doc);
}

// Update
async function updateCourse(id, updates) {
  await db.collection('courses').doc(id).update(updates);
}

// Delete
async function deleteCourse(id) {
  await db.collection('courses').doc(id).delete();
}

module.exports = {
  createCourse,
  getAllCourses,
  getCourseById,
  updateCourse,
  deleteCourse
};
