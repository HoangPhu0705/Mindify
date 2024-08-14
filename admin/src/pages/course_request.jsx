import React, { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import axios from "axios";
import { TrashIcon } from "@heroicons/react/24/solid";

import {
  Card,
  Typography,
  Button,
  Select,
  Option,
  Spinner,
  Chip,
  IconButton,
} from "@material-tailwind/react";
import {
  Tabs,
  TabsHeader,
  TabsBody,
  Tab,
  TabPanel,
  Input,
} from "@material-tailwind/react";

const COURSE_TABLE_HEAD = [
  "Course Name",
  "Author",
  "Email",
  "Price",
  "Status",
  "Detail",
  "Action",
];

const CourseRequestManagement = () => {
  const [requests, setRequests] = useState([]);
  const [requestPage, setRequestPage] = useState({
    limit: 5,
    startAfter: null,
  });
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [selectedTab, setSelectedTab] = useState("all");
  const data = [
    { label: "All", value: "all" },
    { label: "Approved", value: "approved" },
    { label: "Pending", value: "pending" },
  ];
  const [filteredRequests, setFilteredRequests] = useState([]);
  const [loading, setLoading] = useState(false);

  const navigate = useNavigate();

  useEffect(() => {
    fetchRequests();
  }, [requestPage, currentPage]);

  const fetchRequests = async () => {
    setLoading(true);
    try {
      const token = localStorage.getItem("token");

      const response = await axios.get("/api/courseRequest", {
        params: {
          limit: requestPage.limit,
          startAfter: requestPage.startAfter,
        },
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });
      const { requests, totalCount } = response.data;
      setRequests(requests);
      setFilteredRequests(requests);

      setTotalPages(Math.ceil(totalCount / requestPage.limit));
    } catch (error) {
      console.error("Error fetching requests: ", error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (selectedTab === "all") {
      setFilteredRequests(requests);
    } else {
      setFilteredRequests(
        requests.filter(
          (request) => request.status.toLowerCase() === selectedTab
        )
      );
    }
  }, [selectedTab, requests]);

  const goToCourseDetail = (courseId, requestId) => {
    navigate(`/course/${courseId}`, { state: { requestId } });
  };

  const handlePageChange = (newPage) => {
    const startAfter = requests[requestPage.limit - 1]?.id || null;
    setCurrentPage(newPage);
    setRequestPage({ ...requestPage, startAfter });
  };

  const handleLimitChange = (value) => {
    setRequestPage({ ...requestPage, limit: Number(value), startAfter: null });
    setCurrentPage(1);
  };

  const deleteCourseRequest = async (requestId) => {
    try {
      const token = localStorage.getItem("token");
      await axios.delete(`/api/courseRequest/${requestId}`, {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });
    } catch (err) {
      console.error("Error deleting course request", err);
      throw new Error("Error deleting course request");
    }
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
                <Typography
                  variant="small"
                  color="blue-gray"
                  className="font-normal"
                >
                  {item.courseName}
                </Typography>
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
                  {item.email}
                </Typography>
              </td>

              <td className="p-4">
                <Typography
                  variant="small"
                  color="blue-gray"
                  className="font-normal"
                >
                  {item.coursePrice}
                </Typography>
              </td>
              <td className="p-4">
                <Chip
                  className="inline-block w-auto"
                  value={item.status}
                  color={
                    item.status === "Pending"
                      ? "blue"
                      : item.status === "Approved"
                      ? "green"
                      : "red"
                  }
                />
              </td>

              <td className="p-4">
                <Button
                  color="cyan"
                  onClick={() => goToCourseDetail(item.courseId, item.id)}
                >
                  Detail
                </Button>
              </td>
              <td className="p-4">
                <IconButton
                  onClick={async () => {
                    if (
                      item.status === "Approved" ||
                      item.status === "Declined"
                    ) {
                      await deleteCourseRequest(item.id);
                      setRequests(
                        filteredRequests.filter((req) => req.id !== item.id)
                      );
                    } else {
                      alert(
                        "You can only delete requests that are Approved or Declined."
                      );
                    }
                  }}
                >
                  <TrashIcon className="text-white size-6" />
                </IconButton>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );

  return (
    <Card className="h-full w-full overflow-scroll">
      <div className="py-6 px-4 md:px-6 xl:px-7.5 ">
        <Typography variant="h4" color="black" className="dark:text-white">
          Course Request Management
        </Typography>
        <div className="flex flex-col md:flex-row justify-between items-center mb-4">
          <div className="w-full md:w-auto mt-2 md:mb-0">
            <Input
              type="text"
              color="blue-gray"
              label="Search Course"
              fullWidth
            />
          </div>
          <div className="flex items-center">
            <Typography
              variant="h6"
              color="black"
              className="dark:text-white mr-2"
            >
              Show
            </Typography>
            <Select
              value={String(requestPage.limit)}
              onChange={(e) => handleLimitChange(e)}
              className="mr-2"
            >
              <Option value="5">5</Option>
              <Option value="10">10</Option>
            </Select>
          </div>
        </div>
        <div className = "flex">
          <Tabs value={selectedTab} className="mb-2 flex-2">
            <TabsHeader>
              {data.map(({ label, value }) => (
                <Tab
                  key={value}
                  value={value}
                  onClick={() => setSelectedTab(value)}
                >
                  {label}
                </Tab>
              ))}
            </TabsHeader>
          </Tabs>
        </div>

        {loading ? (
          <div className="flex justify-center items-center">
            <Spinner color="blue" />
          </div>
        ) : (
          renderTable(COURSE_TABLE_HEAD, filteredRequests)
        )}
        <div className="flex flex-col md:flex-row justify-between items-center mt-4">
          <Button
            color="blue"
            onClick={() => handlePageChange(currentPage - 1)}
            disabled={currentPage === 1}
          >
            Previous
          </Button>
          <Typography
            variant="small"
            color="blue-gray"
            className="font-normal my-2 md:my-0"
          >
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

export default CourseRequestManagement;
