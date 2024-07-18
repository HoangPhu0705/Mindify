import React, { useEffect, useState } from 'react';
import axios from 'axios';
import { Card, Typography, Button, Select, MenuItem, Dialog, DialogHeader, DialogBody, DialogFooter } from "@material-tailwind/react";

const USER_TABLE_HEAD = ["Email", "Display Name", "Role", "Lock Account"];

const UserManagement = () => {
  const [users, setUsers] = useState([]);
  const [userPage, setUserPage] = useState({ limit: 10, startAfter: null });
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [selectedUser, setSelectedUser] = useState(null);
  const [isConfirmOpen, setIsConfirmOpen] = useState(false);

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

  const handleLockUser = (user) => {
    setSelectedUser(user);
    setIsConfirmOpen(true);
  };

  const handleConfirmLockUser = async () => {
    try {
      const action = selectedUser.disabled ? 'unlock-user' : 'lock-user';
      const response = await axios.post(`http://localhost:3000/admin/${action}`, { uid: selectedUser.id });
      console.log(response.data.message);
      setIsConfirmOpen(false);
      fetchUsers();
    } catch (error) {
      console.error(`Error ${selectedUser.disabled ? 'unlocking' : 'locking'} user: `, error);
      setIsConfirmOpen(false);
    }
  };

  const handlePageChange = (event) => {
    setCurrentPage(event.target.value);
    const newStartAfter = users[users.length - 1]?.id || null;
    setUserPage({ ...userPage, startAfter: newStartAfter });
  };

  return (
    <Card className="h-full w-full p-4">
      <Typography variant="h4" color="blue-gray">User Management</Typography>
      <table className="w-full min-w-max table-auto text-left">
        <thead>
          <tr>
            {USER_TABLE_HEAD.map((head) => (
              <th key={head} className="border-b border-blue-gray-100 bg-blue-gray-50 p-4">
                <Typography variant="small" color="blue-gray" className="font-normal leading-none opacity-70">{head}</Typography>
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {users.map((user, index) => (
            <tr key={user.id} className="even:bg-blue-gray-50/50">
              <td className="p-4">{user.email}</td>
              <td className="p-4">{user.displayName}</td>
              <td className="p-4">{user.role}</td>
              <td className="p-4">
                <Button color={user.disabled ? 'green' : 'red'} onClick={() => handleLockUser(user)}>
                  {user.disabled ? 'Unlock' : 'Lock'}
                </Button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
      <div className="flex justify-center items-center mt-4">
        <Button color="blue-gray" onClick={() => handlePageChange(currentPage - 1)} disabled={currentPage === 1}>Previous</Button>
        <span className="mx-4">{`Page ${currentPage} of ${totalPages}`}</span>
        <Button color="blue-gray" onClick={() => handlePageChange(currentPage + 1)} disabled={currentPage === totalPages}>Next</Button>
      </div>
      <Dialog open={isConfirmOpen} handler={() => setIsConfirmOpen(false)}>
        <DialogHeader>{selectedUser?.disabled ? 'Unlock User' : 'Lock User'}</DialogHeader>
        <DialogBody>
          Are you sure you want to {selectedUser?.disabled ? 'unlock' : 'lock'} user {selectedUser?.email}?
        </DialogBody>
        <DialogFooter>
          <Button variant="text" color="blue-gray" onClick={() => setIsConfirmOpen(false)}>Cancel</Button>
          <Button color="blue-gray" onClick={handleConfirmLockUser}>{selectedUser?.disabled ? 'Unlock' : 'Lock'}</Button>
        </DialogFooter>
      </Dialog>
    </Card>
  );
};

export default UserManagement;
