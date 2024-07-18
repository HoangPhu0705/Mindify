import React, { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';
import axios from 'axios';
import { Card, Typography, Spinner, Button } from "@material-tailwind/react";

const CourseDetail = () => {
  const { courseId } = useParams();
  const [course, setCourse] = useState(null);
  const [loading, setLoading] = useState(true);
  const [selectedLesson, setSelectedLesson] = useState(null);

  useEffect(() => {
    fetchCourseDetail();
  }, [courseId]);

  const fetchCourseDetail = async () => {
    setLoading(true);
    try {
      const response = await axios.get(`http://localhost:3000/api/courses/${courseId}`);
      const sortedLessons = response.data.lessons.sort((a, b) => a.index - b.index);
      setCourse({ ...response.data, lessons: sortedLessons });
      setSelectedLesson(sortedLessons[0]);
    } catch (error) {
      console.error('Error fetching course details: ', error);
    } finally {
      setLoading(false);
    }
  };

  const handleLessonClick = (lesson) => {
    setSelectedLesson(lesson);
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center h-full">
        <Spinner color="blue" />
      </div>
    );
  }

  if (!course) {
    return (
      <div className="flex justify-center items-center h-full">
        <Typography variant="h5" color="red">Course not found</Typography>
      </div>
    );
  }

  return (
    <Card className="h-full w-full overflow-scroll p-6">
      <div className="flex flex-col md:flex-row">
        <div className="flex-2">
          {selectedLesson && (
            <video
              key={selectedLesson.id} // Force re-render by changing key
              className="h-full w-full rounded-lg object-fit"
              controls
              autoPlay
            >
              <source src={selectedLesson.link} type="video/mp4" />
              Your browser does not support the video tag.
            </video>
          )}
          <Typography variant="h3" color="black" className="mb-4">{course.courseName}</Typography>
          <Typography variant="h5" color="black" className="mb-2">Author: {course.author}</Typography>
          <Typography variant="h6" color="black" className="mb-4">Lessons: {course.lessonNum}</Typography>
        </div>
        <div className="flex-1 md:pl-6">
          <div className="space-y-2">
            {course.lessons.map((lesson) => (
              <Button
                key={lesson.id}
                color="cyan"
                className="w-full text-left"
                onClick={() => handleLessonClick(lesson)}
              >
                {lesson.title}
              </Button>
            ))}
          </div>
        </div>
      </div>
    </Card>
  );
};

export default CourseDetail;
