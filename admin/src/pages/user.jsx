import React, { useEffect, useState } from 'react';
import axios from 'axios';
import { Card, Typography, Button, Select, MenuItem } from "@material-tailwind/react";


const USER_TABLE_HEAD = ["Email", "Display Name", "Role", "Lock Account"];

const UserManagement = () => {
  const [users, setUsers] = useState([]);
  const [userPage, setUserPage] = useState({ limit: 10, startAfter: null });
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);

  useEffect(() => {
    fetchUsers();
  }, [userPage, currentPage]);

  const fetchUsers = async () => {
    try {
      const response = await axios.get('http://localhost:3000/admin/users-management', {
        params: { limit: userPage.limit, startAfter: userPage.startAfter }
      });
      setUsers(response.data);
    } catch (error) {
      console.error('Error fetching users: ', error);
    }
  };

  const handleLockUser = (userId) => {
    
  };

  const handlePageChange = (newPage) => {
    setCurrentPage(newPage);
    const startAfter = (newPage - 1) * userPage.limit;
    setCoursePage({ ...userPage, startAfter });
  };

  const handleLimitChange = (event) => {
    setCoursePage({ ...userPage, limit: event.target.value, startAfter: null });
    setCurrentPage(1); 
  };

  const renderTable = (headers, data) => (
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
                {item.email}
              </Typography>
            </td>
            <td className="p-4">
              <Typography variant="small" color="blue-gray" className="font-normal">
                {item.displayName}
              </Typography>
            </td>
            <td className="p-4">
              <Typography variant="small" color="blue-gray" className="font-normal">
                {item.role}
              </Typography>
            </td>
            <td className="p-4">
              <Button color="red" onClick={() => handleLockUser(item.id)}>
                Lock
              </Button>
            </td>
          </tr>
        ))}
      </tbody>
    </table>
  );

  return (
    <Card className="h-full w-full overflow-scroll">
      <div className="py-6 px-4 md:px-6 xl:px-7.5 bg-gray-100 dark:bg-gray-800">
        <Typography variant="h4" color="black" className="dark:text-white">
          User Management
        </Typography>
        <div className="flex justify-between items-center mb-4">
          <Typography variant="h6" color="black" className="dark:text-white">
            Show
          </Typography>
          <Select
            value={userPage.limit}
            onChange={handleLimitChange}
            className="ml-2"
          >
            <MenuItem value={10}>10</MenuItem>
            <MenuItem value={20}>20</MenuItem>
            <MenuItem value={50}>50</MenuItem>
          </Select>
        </div>
        {renderTable(USER_TABLE_HEAD, users)}
        <div className="flex justify-between items-center mt-4">
          <Button
            color="blue"
            onClick={() => handlePageChange(currentPage - 1)}
            disabled={currentPage === 1}
          >
            Previous
          </Button>
          <Typography variant="small" color="blue-gray" className="font-normal">
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

export default UserManagement;
