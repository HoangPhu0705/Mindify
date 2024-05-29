class Course {
    constructor(id, title, description, teacher, upDate) {
      this.id = id;
      this.title = title;
      this.description = description;
      this.teacher = teacher;
      this.upDate = upDate;
    }
  
    static fromSnapshot(doc) {
      const data = doc.data();
      return new Course(
        doc.id,
        data.title,
        data.description,
        data.teacher,
        data.upDate.toDate(),
      );
    }
  }

module.exports = new Course();