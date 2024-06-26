import React, { useEffect, useState } from 'react';
import axios from 'axios';

const TABLE_HEAD = ["Email", "Role", "Sign up date", ""];



const Request = () => {
  const [requests, setRequests] = useState([]);  // Ensure requests is initialized as an array
  const [error, setError] = useState('');

  useEffect(() => {
    const fetchRequests = async () => {
      try {
        const response = await axios.get('http://localhost:3000/api/users/requests/unapproved');
        if (Array.isArray(response.data)) {
          setRequests(response.data);
          console.log(requests);
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
    <div className="rounded-xl border border-stroke bg-white shadow-lg dark:border-strokedark dark:bg-boxdark">
      <div className="py-6 px-4 md:px-6 xl:px-7.5 bg-gray-100 dark:bg-gray-800">
        <h4 className="text-xl font-semibold text-black dark:text-white">
          Application Requests
        </h4>
      </div>

      <table className="w-full border-collapse">
        <thead className="bg-gray-50 dark:bg-gray-900">
          <tr>
            <th className="px-4 py-3 text-left text-sm font-medium text-black dark:text-white">Full Name</th>
            <th className="px-4 py-3 text-left text-sm font-medium text-black dark:text-white">Email</th>
            <th className="px-4 py-3 text-left text-sm font-medium text-black dark:text-white">Category</th>
            <th className="px-4 py-3 text-left text-sm font-medium text-black dark:text-white">Approve</th>
          </tr>
        </thead>
        <tbody>
          {requests.map((request, key) => (
            <tr
              key={key}
              className="hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors border-t border-stroke dark:border-strokedark"
            >
              <td className="px-4 py-3 text-sm text-black dark:text-black">{request.firstName} {request.lastName}</td>
              <td className="px-4 py-3 text-sm text-black dark:text-black">{request.user_email}</td>
              <td className="px-4 py-3 text-sm text-black dark:text-black">{request.category}</td>
              <td className="px-4 py-3 text-sm text-black dark:text-black">
                <button
                  onClick={() => approveRequest(request.id)}
                  className="bg-blue-500 text-white px-3 py-1 rounded"
                >
                  Approve
                </button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>

    </div>
  );
};

export default Request;
