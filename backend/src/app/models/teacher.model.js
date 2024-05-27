class Teacher {
    constructor(id, fullName, bio, imageUrl, coursesTaught) {
      this.id = id;
      this.fullName = fullName;
      this.bio = bio;
      this.imageUrl = imageUrl;
      this.coursesTaught = coursesTaught || [];
    }
  
    static fromSnapshot(doc) {
      const data = doc.data();
      return new Teacher(
        doc.id,
        data.fullName,
        data.bio,
        data.imageUrl,
        data.coursesTaught.map(courseId => Course.fromSnapshot(db.collection('courses').doc(courseId)))
      );
    }
  }
  
  module.exports = Teacher;