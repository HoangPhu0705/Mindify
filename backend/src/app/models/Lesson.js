class Lesson {
    constructor(id, title, content, urlVideo, quizQuestions) {
      this.id = id;
      this.title = title;
      this.content = content;
      this.urlVideo = urlVideo;
      this.quizQuestions = quizQuestions || [];
    }
  
    static fromSnapshot(doc) {
      const data = doc.data();
      return new Lesson(
        doc.id,
        data.title,
        data.content,
        data.urlVideo,
        data.quizQuestions.map(q => Question.fromSnapshot(q))
      );
    }
  }
  
  module.exports = Lesson;