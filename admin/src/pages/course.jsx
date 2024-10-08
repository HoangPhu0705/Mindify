import React, { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import axios from "axios";
import {
  Card,
  Typography,
  Button,
  Select,
  Option,
  Spinner,
  Input,
} from "@material-tailwind/react";

const COURSE_TABLE_HEAD = [
  "Course Name",
  "Author",
  "Lesson",
  "Student",
  "Actions",
];

const CourseManagement = () => {
  const [courses, setCourses] = useState([]);
  const [coursePage, setCoursePage] = useState({ limit: 10, startAfter: null });
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [loading, setLoading] = useState(false);
  const [searchQuery, setSearchQuery] = useState("");

  const navigate = useNavigate();

  useEffect(() => {
    fetchCourses();
  }, [coursePage, currentPage]);

  const fetchCourses = async () => {
    console.log("fetching courses");
    setLoading(true);
    try {
      const token = localStorage.getItem("token");

      const response = await axios.get("/admin/courses-management", {
        params: {
          limit: coursePage.limit,
          startAfter: coursePage.startAfter,
          searchQuery: searchQuery,
        },
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });
      const { courses, totalCount } = response.data;
      setCourses(courses);
      setTotalPages(Math.ceil(totalCount / coursePage.limit));
    } catch (error) {
      console.error("Error fetching courses: ", error);
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



  const handleSearch = () => {
    setCurrentPage(1);
    setCoursePage({ ...coursePage, startAfter: null });
    fetchCourses();
  };


  const renderTable = (headers, data) => (
    <div className="overflow-auto">
      <table className="w-full min-w-max table-auto text-left">
        <thead>
          <tr>
            {headers.map((head) => (
              <th
                key={head}
                className="border-b border-blue-gray-100 bg-blue-gray-50 p-4"
              >
                <Typography
                  variant="small"
                  color="blue-gray"
                  className="font-normal leading-none opacity-70"
                >
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
                <div className="flex items-center justify-between">
                  <img
                    className="h-32 w-32 rounded-lg object-cover"
                    src={item.thumbnail}
                  />
                  <Typography
                    variant="small"
                    color="blue-gray"
                    className="font-normal"
                  >
                    {item.courseName}
                  </Typography>
                  <div></div>
                </div>
              </td>
              <td className="p-4">
                <Typography
                  variant="small"
                  color="blue-gray"
                  className="font-normal"
                >
                  {item.author}
                </Typography>
              </td>
              <td className="p-4">
                <Typography
                  variant="small"
                  color="blue-gray"
                  className="font-normal"
                >
                  {item.lessonNum}
                </Typography>
              </td>
              <td className="p-4">
                <Typography
                  variant="small"
                  color="blue-gray"
                  className="font-normal"
                >
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
      <div className="py-6 px-4 md:px-6 xl:px-7.5">
        <Typography variant="h4" color="black" className="">
          Course Management
        </Typography>
        <div className="flex flex-col md:flex-row justify-between items-center mb-4">
          <div className="flex w-full md:w-auto mt-2 md:mb-0">
            <Input
              type="text"
              color="blue-gray"
              label="Search Course"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
            />
            <Button 
            className="ml-4"
              onClick={() => {
                handleSearch();
              }}
            >
              Search
            </Button>
          </div>
          <div className="flex items-center">
            <Typography variant="h6" color="black" className="mr-2">
              Show
            </Typography>
            <Select
              value={String(coursePage.limit)}
              onChange={(e) => handleLimitChange(e)}
            >
              <Option value="10">10</Option>
              <Option value="20">20</Option>
              <Option value="50">50</Option>
            </Select>
          </div>
        </div>
        {loading ? (
          <div className="flex justify-center items-center">
            <Spinner color="blue" />
          </div>
        ) : (
          renderTable(COURSE_TABLE_HEAD, courses)
        )}
        <div className="flex flex-col md:flex-row justify-center items-center mt-4">
          <Button
            color="black"
            className="hover:bg-black hover:text-white"
            variant="outlined"
            onClick={() => handlePageChange(currentPage - 1)}
            disabled={currentPage === 1}
          >
            Previous
          </Button>
          <Typography
            variant="small"
            color="blue-gray"
            className="font-normal mx-2 my-2 md:my-0"
          >
            Page {currentPage} of {totalPages}
          </Typography>
          <Button
            color="black"
            className="hover:bg-black hover:text-white"
            variant="outlined"
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
