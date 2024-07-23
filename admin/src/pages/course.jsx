import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';
import { Card, Typography, Button, Select, Option, Spinner } from "@material-tailwind/react";

const COURSE_TABLE_HEAD = ["Course Name", "Author", "Lesson Num", "Student Num", "Actions"];

const CourseManagement = () => {
  const [courses, setCourses] = useState([]);
  const [coursePage, setCoursePage] = useState({ limit: 5, startAfter: null });
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [loading, setLoading] = useState(false);

  const navigate = useNavigate();

  useEffect(() => {
    fetchCourses();
  }, [coursePage, currentPage]);

  const fetchCourses = async () => {
    setLoading(true);
    try {
      const response = await axios.get('http://localhost:3000/admin/courses-management', {
        params: { limit: coursePage.limit, startAfter: coursePage.startAfter }
      });
      const { courses, totalCount } = response.data;
      setCourses(courses);
      setTotalPages(Math.ceil(totalCount / coursePage.limit));
    } catch (error) {
      console.error('Error fetching courses: ', error);
    } finally {
      setLoading(false);
    }
  };

  const goToCourseDetail = (courseId) => {
    navigate(`/course/${courseId}`);
  };

  const handlePageChange = (newPage) => {
    const startAfter = courses[coursePage.limit - 1]?.id || null;
    setCurrentPage(newPage);
    setCoursePage({ ...coursePage, startAfter });
  };

  const handleLimitChange = (value) => {
    setCoursePage({ ...coursePage, limit: Number(value), startAfter: null });
    setCurrentPage(1); 
  };

  const renderTable = (headers, data) => (
    <div className="overflow-auto">
      <table className="w-full min-w-max table-auto text-left">
        <thead>
          <tr>
            {headers.map((head) => (
              <th key={head} className="border-b border-blue-gray-100 bg-blue-gray-50 p-4">
                <Typography variant="small" color="blue-gray" className="font-normal leading-none opacity-70">
                  {head}
                </Typography>
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {data.map((item) => (
            <tr key={item.id} className="even:bg-blue-gray-50/50">
              <td className="p-4">
                <Typography variant="small" color="blue-gray" className="font-normal">
                  {item.courseName}
                </Typography>
              </td>
              <td className="p-4">
                <Typography variant="small" color="blue-gray" className="font-normal">
                  {item.author}
                </Typography>
              </td>
              <td className="p-4">
                <Typography variant="small" color="blue-gray" className="font-normal">
                  {item.lessonNum}
                </Typography>
              </td>
              <td className="p-4">
                <Typography variant="small" color="blue-gray" className="font-normal">
                  {item.students}
                </Typography>
              </td>
              <td className="p-4">
                <Button color="cyan" onClick={() => goToCourseDetail(item.id)}>
                  Detail
                </Button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );

  return (
    <Card className="h-full w-full overflow-scroll">
      <div className="py-6 px-4 md:px-6 xl:px-7.5 bg-gray-100 dark:bg-gray-800">
        <Typography variant="h4" color="black" className="dark:text-white">
          Course Management
        </Typography>
        <div className="flex flex-col md:flex-row justify-between items-center mb-4">
          <Typography variant="h6" color="black" className="dark:text-white mb-2 md:mb-0">
            Show
          </Typography>
          <Select
            value={String(coursePage.limit)}
            onChange={(e) => handleLimitChange(e)}
            className="ml-2"
          >
            <Option value="5">5</Option>
            <Option value="10">10</Option>
          </Select>
        </div>
        {loading ? (
          <div className="flex justify-center items-center">
            <Spinner color="blue" />
          </div>
        ) : (
          renderTable(COURSE_TABLE_HEAD, courses)
        )}
        <div className="flex flex-col md:flex-row justify-between items-center mt-4">
          <Button
            color="blue"
            onClick={() => handlePageChange(currentPage - 1)}
            disabled={currentPage === 1}
          >
            Previous
          </Button>
          <Typography variant="small" color="blue-gray" className="font-normal my-2 md:my-0">
            Page {currentPage} of {totalPages}
          </Typography>
          <Button
            color="blue"
            onClick={() => handlePageChange(currentPage + 1)}
            disabled={currentPage === totalPages}
          >
            Next
          </Button>
        </div>
      </div>
    </Card>
  );
};

export default CourseManagement;
