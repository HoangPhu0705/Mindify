import React, { useEffect, useState } from "react";
import axios from "axios";
import { Card, Typography } from "@material-tailwind/react";
import { Link } from "react-router-dom";
import { Tabs, TabsHeader, TabsBody, Tab, TabPanel } from "@material-tailwind/react";
import { Chip } from "@material-tailwind/react";

const TABLE_HEAD = ["Full Name", "Email", "Category", "Status", "Detail"];

const Request = () => {
  const [requests, setRequests] = useState([]);
  const [filteredRequests, setFilteredRequests] = useState([]);
  const [error, setError] = useState("");
  const [selectedTab, setSelectedTab] = useState("all");
  const token = localStorage.getItem("token");

  const data = [
    { label: "All", value: "all" },
    { label: "Approved", value: "approved" },
    { label: "Pending", value: "pending" },
    { label: "Declined", value: "declined" },
  ];

  useEffect(() => {
    const fetchRequests = async () => {
      try {
        const response = await axios.get("/api/users/requests/", {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        });
        if (Array.isArray(response.data)) {
          setRequests(response.data);
          setFilteredRequests(response.data);
        } else {
          throw new Error("Invalid data format");
        }
      } catch (err) {
        setError("Error fetching requests");
      }
    };

    fetchRequests();
  }, [token]);

  useEffect(() => {
    if (selectedTab === "all") {
      setFilteredRequests(requests);
    } else {
      setFilteredRequests(requests.filter(request => request.status.toLowerCase() === selectedTab));
    }
  }, [selectedTab, requests]);

  if (error) {
    return <p>{error}</p>;
  }

  return (
    <Card className="h-full w-full overflow-scroll">
      <div className="py-6 px-4 md:px-6 xl:px-7.5 ">
        <Typography variant="h4" color="black" className="dark:text-white">
          Application Requests
        </Typography>
      </div>

        <Tabs value={selectedTab}>
          <TabsHeader>
            {data.map(({ label, value }) => (
              <Tab key={value} value={value} onClick={() => setSelectedTab(value)}>
                {label}
              </Tab>
            ))}
          </TabsHeader>
        </Tabs>

      <table className="w-full min-w-max table-auto text-left">
        <thead>
          <tr>
            {TABLE_HEAD.map((head) => (
              <th key={head} className="border-b border-blue-gray-100 bg-blue-gray-50 p-4">
                <Typography variant="small" color="blue-gray" className="font-bold leading-none text-lg">
                  {head}
                </Typography>
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {filteredRequests.map((request) => (
            <tr key={request.id} className="even:bg-blue-gray-50/50">
              <td className="p-4">
                <Typography variant="small" color="blue-gray" className="font-normal">
                  {request.firstName} {request.lastName}
                </Typography>
              </td>
              <td className="p-4">
                <Typography variant="small" color="blue-gray" className="font-normal">
                  {request.user_email}
                </Typography>
              </td>
              <td className="p-4">
                <Typography variant="small" color="blue-gray" className="font-normal">
                  {request.category}
                </Typography>
              </td>
              <td className="p-4">
                <Chip
                  className="inline-block w-auto"
                  value={request.status}
                  color={
                    request.status === "Pending"
                      ? "blue"
                      : request.status === "Approved"
                      ? "green"
                      : "red"
                  }
                />
              </td>
              <td className="p-4">
                <Link to={`/request/${request.id}`} className="bg-cyan-500 text-white px-3 py-1 rounded">
                  View Details
                </Link>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </Card>
  );
};

export default Request;
