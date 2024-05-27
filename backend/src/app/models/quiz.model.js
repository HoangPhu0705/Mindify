class Quiz {
    constructor(id, title, questions) {
      this.id = id;
      this.title = title;
      this.questions = questions || [];
    }
  
    static fromSnapshot(doc) {
      const data = doc.data();
      return new Quiz(
        doc.id,
        data.title,
        data.questions.map(q => Question.fromSnapshot(q))
      );
    }
  }
  
module.exports = Quiz;
  