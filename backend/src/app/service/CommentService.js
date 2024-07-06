const { CourseCollection } = require('./Collections');

exports.createComment = async (courseId, userId, content) => {
  try {
    const commentRef = CourseCollection.doc(courseId).collection('comments').doc();
    const createdAt = new Date().toISOString();
    const comment = {
      id: commentRef.id,
      userId: userId,
      content: content,
      createdAt: createdAt,
    };
    
    await commentRef.set(comment);
    return commentRef.id;
  } catch (error) {
    console.error('Error creating comment:', error);
    throw error;
  }
};

exports.showComments = async (courseId) => {
    try {
      const commentsSnapshot = await CourseCollection.doc(courseId).collection('comments').get();
      const comments = await Promise.all(commentsSnapshot.docs.map(async (doc) => {
        const repliesSnapshot = await doc.ref.collection('replies').get();
        const replies = repliesSnapshot.docs.map(replyDoc => ({ id: replyDoc.id, ...replyDoc.data() }));
        return { id: doc.id, ...doc.data(), replies };
      }));
      return comments;
    } catch (error) {
      console.error('Error getting comments:', error.message);
      throw error;
    }
  };
  

exports.replyComment = async (courseId, commentId, userId, content) => {
  try {
    const replyRef = CourseCollection.doc(courseId).collection('comments').doc(commentId).collection('replies').doc();
    const createdAt = new Date().toISOString();
    const reply = {
      id: replyRef.id,
      userId: userId,
      content: content,
      createdAt: createdAt,
    };
    
    await replyRef.set(reply);
    return replyRef.id;
  } catch (error) {
    console.error('Error replying to comment:', error);
    throw error;
  }
};
