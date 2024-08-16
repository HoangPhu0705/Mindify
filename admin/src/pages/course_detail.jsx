import React, { useEffect, useState } from "react";
import { useParams, useLocation, useNavigate } from "react-router-dom";
import axios from "axios";
import UnpublishPopup from "../components/unpublish_popup";
import ReactQuill from "react-quill"; // Import ReactQuill
import "react-quill/dist/quill.snow.css"; // Import Quill styles
import {
  Card,
  Typography,
  Spinner,
  Button,
  Chip,
  Alert,
} from "@material-tailwind/react";
import { PlayCircleIcon } from "@heroicons/react/24/solid";

const CourseDetail = () => {
  const { courseId } = useParams();
  const { state } = useLocation();
  const requestId = state?.requestId;
  const reportId = state?.id;
  const [course, setCourse] = useState(null);
  const [loading, setLoading] = useState(true);
  const [selectedLesson, setSelectedLesson] = useState(null);
  const [popupOpen, setPopupOpen] = useState(false);
  const [alertVisible, setAlertVisible] = useState(false);
  const [unpublishContent, setUnpublishContent] = useState("");
  const token = localStorage.getItem("token");
  const navigate = useNavigate();

  
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
      const sortedLessons = response.data.lessons.sort(
        (a, b) => a.index - b.index
      );
      setCourse({ ...response.data, lessons: sortedLessons });
      setSelectedLesson(sortedLessons[0]);
    } catch (error) {
      console.error("Error fetching course details: ", error);
    } finally {
      setLoading(false);
    }
  };

  const handleApprove = async () => {
    try {
      await axios.post(
        `/api/courseRequest/${requestId}/approve`,
        {}, // Empty body if not sending data
        {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        }
      );
      fetchCourseDetail();
    } catch (error) {
      console.error("Error approving course: ", error);
    }
  };

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
        alert("Session expired. Please log in again.");
      }
    }
  };

  const handleUnpublish = async () => {
    try {
      await axios.patch(
        `/admin/unpublish/${courseId}`,
        {
          // authorId, courseName, unpublishReason
          authorId: course.authorId,
          courseName: course.courseName,
          unpublishReason: unpublishContent,
          reportId: reportId
        }, // Empty body if not sending data
        {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        }
      );
      setPopupOpen(false)
      setAlertVisible(true);
      setTimeout(() => {
        setAlertVisible(false);
        navigate("/course-management");
      }, 2000);
      
    } catch (error) {
      console.error("Error rejecting course: ", error);
      if (error.response && error.response.status === 401) {
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
        <Typography variant="h5" color="red">
          Course not found
        </Typography>
      </div>
    );
  }

  return (
    <div className="w-full p-2">
      {course.isPublic === false && requestId && (
        <div className="flex flex-row justify-end mt-4 space-x-2">
          <Button color="green" onClick={handleApprove}>
            Approve
          </Button>
          <Button color="red" onClick={handleReject}>
            Reject
          </Button>
        </div>
      )}
      {course.isPublic && (
        <Button color="red" onClick={()=>setPopupOpen(true)}>
            Unpublish
        </Button>
      )}
      {alertVisible && <Alert color="blue">Sent email successfully.</Alert>}
      <div className="flex flex-col items-center">
        <div className="w-full">
          <div className="flex w-full justify-center items-center">
            {selectedLesson && (
              <video
                key={selectedLesson.id}
                className="h-[40rem] rounded-lg object-fit"
                controls
                autoPlay
              >
                <source src={selectedLesson.link} type="video/mp4" />
                Your browser does not support the video tag.
              </video>
            )}
          </div>

          <div className="mt-5">
            <Typography variant="h3" color="black" className="mb-4">
              {course.courseName}
            </Typography>
            <Typography variant="h5" color="black" className="mb-2">
              Author: {course.author}
            </Typography>
          </div>

          <div className="flex flex-col gap-2 mb-5 justify-start items-start">
            <Typography variant="h5" color="black">
              Categories:
            </Typography>
            <div className="flex mb-4">
              {course.category.map((category) => (
                <Chip className="mr-2" size="lg" value={category} />
              ))}
            </div>
          </div>

          {/* Render the course description */}
          <div className="w-full mb-5 ">
            <Typography className="text-4xl font-bold mb-2" color="black">
              Description:
            </Typography>
            <ReactQuill
              // Set the value to the Quill JSON data
              value={JSON.parse(course.description)}
              readOnly={true} // Make it read-only
              theme="bubble"

            />
            
          </div>  
        </div>

        <div className="w-full overflow-y-auto">
          <div>
            <Typography
              variant="h6"
              color="black"
              className="mb-4 font-bold text-2xl"
            >
              {course.lessonNum} Lessons ({course.duration})
            </Typography>
          </div>
          <div>
            {course.lessons.map((lesson) => (
              <div
                key={lesson.id}
                className={`cursor-pointer p-4 my-2 rounded-lg  ${
                  selectedLesson?.id === lesson.id
                    ? "bg-[#062137] text-white shadow-lg"
                    : "hover:border border-[#39464B]"
                }`}
                onClick={() => setSelectedLesson(lesson)}
              >
                <div className="flex items-center justify-between">
                  <div className="flex items-center">
                    <PlayCircleIcon
                      className={`h-6 w-6 mr-2 ${
                        selectedLesson?.id === lesson.id
                          ? "text-white"
                          : "text-black"
                      }`}
                    />
                    <Typography
                      className={`font-bold text-xl ${
                        selectedLesson?.id === lesson.id
                          ? "text-white"
                          : "text-black"
                      }`}
                    >
                      {lesson.title}
                    </Typography>
                  </div>
                  <Typography
                    className={`font-bold text-lg ${
                      selectedLesson?.id === lesson.id
                        ? "text-white"
                        : "text-black"
                    }`}
                  >
                    {lesson.duration}
                  </Typography>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
      <UnpublishPopup
      open={popupOpen}
      handleOpen={() => setPopupOpen(!popupOpen)}
      onUnpublish={handleUnpublish}
      setUnpublishContent={setUnpublishContent}
      />
      
    </div>
  );
};

export default CourseDetail;
