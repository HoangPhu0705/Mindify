class Payment {
    constructor(id, studentId, courseId, amount, status, timestamp) {
      this.id = id;
      this.studentId = studentId;
      this.courseId = courseId;
      this.amount = amount;
      this.status = status; // 'pending', 'completed', 'refunded', etc.
      this.timestamp = timestamp || Date.now();
    }
  
    static fromSnapshot(doc) {
      const data = doc.data();
      return new Payment(
        doc.id,
        data.studentId,
        data.courseId,
        data.amount,
        data.status,
        data.timestamp.toDate()
      );
    }
  }
  
  module.exports = Payment;
  