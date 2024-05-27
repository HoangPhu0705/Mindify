class Student {
    constructor(id, fullName, email, image, gender, profileId, createdAt) {
      this.id = id;
      this.fullName = fullName;
      this.email = email;
      this.image = image;
      this.gender = gender;
      this.profileId = profileId;
      this.createdAt = createdAt || Date.now();
    }
  
    static fromSnapshot(doc) {
      const data = doc.data();
      return new Student(
        doc.id,
        data.fullName,
        data.email,
        data.image,
        data.gender,
        data.profileId,
        data.createdAt.toDate()
      );
    }
  }
  
module.exports = Student;
  