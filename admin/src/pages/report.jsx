import React, { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import axios from "axios";
import {
  Card,
  CardBody,
  CardHeader,
  Typography,
  Button,
  Spinner,
  Input,
  Select,
  Option,
} from "@material-tailwind/react";
import { ExclamationCircleIcon } from "@heroicons/react/24/solid";
import { PlusIcon } from "@heroicons/react/24/outline";

function BillingCard({ id, courseTitle, timestamp, from, reason, courseId }) {
  const navigate = useNavigate();
  const goToCourseDetail = (courseId, id) => {
    navigate(`/course/${courseId}`, { state: { id } });
  };

//   const goToCourseDetail = (courseId, requestId) => {
//     navigate(`/course/${courseId}`, { state: { requestId } });
//   };
  return (
    
    <Card shadow={false} className="rounded-lg border border-gray-300 p-4">
      <div className="mb-4 flex items-start justify-between">
        {/* <div>${id}</div> */}
        <div className="flex items-center gap-3">
          <ExclamationCircleIcon className="h-12 w-12 text-gray-900" />
          <div>
            <Typography
              variant="small"
              color="blue-gray"
              className="mb-1 text-lg font-bold"
            >
              {courseTitle}
            </Typography>
            <Typography variant="small" color="blue-gray" className="mb-2">
              From {from}
            </Typography>
            <Typography variant="small" color="blue-gray" className="mb-2">
              Reason: {reason}
            </Typography>
            <Typography className="!text-gray-600 text-xs font-normal">
              {timestamp
                ? new Date(timestamp._seconds * 1000).toLocaleDateString(
                    "en-GB"
                  )
                : "N/A"}
            </Typography>
          </div>
        </div>
        <div className="absolute bottom-4 right-4">
          <Button
            color="black"
            className="hover:bg-black hover:text-white"
            variant="outlined"
            onClick={() => goToCourseDetail(courseId, id)}
          >
            Go to course
          </Button>
        </div>
      </div>
    </Card>
  );
}

const Report = () => {
  const [reports, setReports] = useState([]);
  const [reportPage, setReportPage] = useState({ limit: 10, startAfter: null });
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [loading, setLoading] = useState(false);
  const [searchQuery, setSearchQuery] = useState("");

  useEffect(() => {
    fetchReports();
  }, [reportPage, currentPage]);

  const fetchReports = async () => {
    console.log("fetching reports");
    setLoading(true);
    try {
      const token = localStorage.getItem("token");

      const response = await axios.get("/admin/reports", {
        params: {
          limit: reportPage.limit,
          startAfter: reportPage.startAfter,
          searchQuery: searchQuery,
        },
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });
      const { reports, totalCount } = response.data;
      setReports(reports);
      setTotalPages(Math.ceil(totalCount / reportPage.limit));
    } catch (error) {
      console.error("Error fetching reports: ", error);
    } finally {
      setLoading(false);
    }
  };

  const handlePageChange = (newPage) => {
    const startAfter = reports[reportPage.limit - 1]?.id || null;
    setCurrentPage(newPage);
    setReportPage({ ...reportPage, startAfter });
  };

  const handleLimitChange = (value) => {
    setReportPage({ ...reportPage, limit: Number(value), startAfter: null });
    setCurrentPage(1);
  };

  const handleSearch = () => {
    setCurrentPage(1);
    setReportPage({ ...reportPage, startAfter: null });
    fetchReports();
  };

  return (
    <section className="!mx-auto w-full">
      <Card shadow={false}>
        <div className="w-full flex flex-col p-10">
          <Typography className="!font-bold" color="blue-gray">
            Report Management
          </Typography>
          <Typography
            className="mt-1 !font-normal !text-gray-600"
            variant="small"
          >
            View report quickly and easily.
          </Typography>
          <div className="flex flex-row justify-between items-center">
            <div className="flex items-center">
              <Input
                type="text"
                color="blue-gray"
                label="Search Report"
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
              />
              <Button className="ml-4" onClick={handleSearch}>
                Search
              </Button>
            </div>

            <div className="flex items-center mt-2">
              <Typography variant="h6" color="black" className="mr-2">
                Show
              </Typography>
              <Select
                value={String(reportPage.limit)}
                onChange={(e) => handleLimitChange(e)}
              >
                <Option value="10">10</Option>
                <Option value="20">20</Option>
                <Option value="50">50</Option>
              </Select>
            </div>
          </div>
        </div>
        <CardBody className="flex flex-col gap-4 !p-4">
          {loading ? (
            <div className="flex justify-center items-center">
              <Spinner color="blue" />
            </div>
          ) : (
            
            reports.map((props, key) => <BillingCard key={key} {...props} />)
          )}
        </CardBody>
      </Card>

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
    </section>
  );
};

export default Report;
