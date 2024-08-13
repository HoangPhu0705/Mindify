import React, { useEffect, useState } from 'react';
import { useParams, useLocation } from 'react-router-dom';
import axios from 'axios';
import { Card, Typography, Spinner, Button } from "@material-tailwind/react";

const CourseDetail = () => {
  const { courseId } = useParams();
  const { state } = useLocation();
  const requestId = state?.requestId;
  const [course, setCourse] = useState(null);
  const [loading, setLoading] = useState(true);
  const [selectedLesson, setSelectedLesson] = useState(null);
  const token = localStorage.getItem('token');

  useEffect(() => {
    fetchCourseDetail();
  }, [courseId]);

  const fetchCourseDetail = async () => {
    setLoading(true);
    try {
      const response = await axios.get(`/api/courses/${courseId}`, {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });
      const sortedLessons = response.data.lessons.sort((a, b) => a.index - b.index);
      setCourse({ ...response.data, lessons: sortedLessons });
      setSelectedLesson(sortedLessons[0]);
    } catch (error) {
      console.error('Error fetching course details: ', error);
    } finally {
      setLoading(false);
    }
  };

  const handleApprove = async () => {
    try {
      await axios.post(`/api/courseRequest/${requestId}/approve`, {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });
      fetchCourseDetail();
    } catch (error) {
      console.error('Error approving course: ', error);
    }
  };
  // await axios.put(
  //   `/api/users/requests/${requestId}/reject`,
  //   { content: rejectionContent },
  //   {
  //     headers: {
  //       Authorization: `Bearer ${token}`,
  //     },
  //   }
  // );
  const handleReject = async () => {
    try {
      await axios.post(
        `/api/courseRequest/${requestId}/reject`,
        {}, // Empty body if not sending data
        {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        }
      );
      fetchCourseDetail();
    } catch (error) {
      console.error("Error rejecting course: ", error);
      if (error.response && error.response.status === 401) {
        // Handle 401 error, e.g., redirect to login or show a message
        alert("Session expired. Please log in again.");
      }
    }
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
    <Card className="h-full w-full p-6">
      {course.isPublic === false && requestId && (
        <div className="flex flex-row justify-end mt-4 space-x-2">
          <Button color="green" onClick={handleApprove}>Approve</Button>
          <Button color="red" onClick={handleReject}>Reject</Button>
        </div>
      )}
      <div className="flex flex-col md:flex-row items-start h-full">
        <div className="w-4/6">
          {selectedLesson && (
            <video
              key={selectedLesson.id}
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
        <div className="w-2/6 md:pl-6 overflow-y-auto h-full">
          <div className="space-y-2">
            {course.lessons.map((lesson) => (
              <Button
                key={lesson.id}
                color="cyan"
                className="w-full p-4 flex items-center justify-center"
                onClick={() => setSelectedLesson(lesson)}
              >
                <div className="text-left line-clamp-2">
                  {lesson.title}
                </div>
              </Button>
            ))}
          </div>
        </div>
      </div>
    </Card>
  );
};

export default CourseDetail;
