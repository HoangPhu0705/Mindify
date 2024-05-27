class Question {
    constructor(id, text, type, options, answer) {
      this.id = id;
      this.text = text;
      this.type = type; // 'multiple-choice', 'true-or-false', etc.
      this.options = options || []; // Options for multiple-choice questions
      this.answer = answer;
    }
  
    static fromSnapshot(doc) {
      const data = doc.data();
      return new Question(
        doc.id,
        data.text,
        data.type,
        data.options,
        data.answer
      );
    }
  }
  
module.exports = Question;
  