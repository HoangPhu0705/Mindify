import React, { useEffect, useState } from 'react';
import axios from 'axios';
import { Card, Typography } from "@material-tailwind/react";
import { Link } from 'react-router-dom';

const TABLE_HEAD = ["Full Name", "Email", "Category", "", "Detail"];

const Request = () => {
  const [requests, setRequests] = useState([]);
  const [error, setError] = useState('');

  useEffect(() => {
    const fetchRequests = async () => {
      try {
        const response = await axios.get('http://localhost:3000/api/users/requests/unapproved');
        if (Array.isArray(response.data)) {
          setRequests(response.data);
        } else {
          throw new Error('Invalid data format');
        }
      } catch (err) {
        setError('Error fetching requests');
      }
    };

    fetchRequests();
  }, []);

  const approveRequest = async (requestId) => {
    try {
      await axios.put(`http://localhost:3000/api/users/requests/${requestId}/approve`);
      setRequests(requests.filter(request => request.id !== requestId));
    } catch (err) {
      console.error('Error approving request', err);
    }
  };

  if (error) {
    return <p>{error}</p>;
  }

  return (
    <Card className="h-full w-full overflow-scroll">
      <div className="py-6 px-4 md:px-6 xl:px-7.5 bg-gray-100 dark:bg-gray-800">
        <Typography variant="h4" color="black" className="dark:text-white">
          Application Requests
        </Typography>
      </div>

      <table className="w-full min-w-max table-auto text-left">
        <thead>
          <tr>
            {TABLE_HEAD.map((head) => (
              <th key={head} className="border-b border-blue-gray-100 bg-blue-gray-50 p-4">
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
          {requests.map((request) => (
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
                <button
                  onClick={() => approveRequest(request.id)}
                  className="bg-blue-500 text-white px-3 py-1 rounded"
                >
                  Approve
                </button>
              </td>
              <td className="p-4">
                <Link
                  to={`/request/${request.id}`}
                  className="bg-gray-500 text-white px-3 py-1 rounded"
                >
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
