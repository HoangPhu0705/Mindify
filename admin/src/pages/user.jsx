import React, { useEffect, useState } from "react";
import axios from "axios";
import {
  Card,
  Typography,
  Button,
  Select,
  Option,
  Dialog,
  DialogHeader,
  DialogBody,
  DialogFooter,
  Spinner,
  Input,
} from "@material-tailwind/react";

const USER_TABLE_HEAD = ["Email", "Display Name", "Role", "Lock Account"];

const UserManagement = () => {
  const [users, setUsers] = useState([]);
  const [filteredUsers, setFilteredUsers] = useState([]);
  const [searchQuery, setSearchQuery] = useState("");
  const [userPage, setUserPage] = useState({ limit: 10, startAfter: null });
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [selectedUser, setSelectedUser] = useState(null);
  const [isConfirmOpen, setIsConfirmOpen] = useState(false);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    fetchUsers();
  }, [userPage, currentPage]);

  useEffect(() => {
    filterUsers();
  }, [searchQuery, users]);

  const fetchUsers = async () => {
    setLoading(true);
    try {
      const response = await axios.get(
        "http://localhost:3000/admin/users-management",
        {
          params: { limit: userPage.limit, startAfter: userPage.startAfter },
        }
      );
      const { users, totalCount } = response.data;
      setUsers(users);
      setTotalPages(Math.ceil(totalCount / userPage.limit));
    } catch (error) {
      console.error("Error fetching users: ", error);
    } finally {
      setLoading(false);
    }
  };

  const filterUsers = () => {
    const filtered = users.filter((user) =>
      [user.email, user.displayName, user.role]
        .join(" ")
        .toLowerCase()
        .includes(searchQuery.toLowerCase())
    );
    setFilteredUsers(filtered);
  };

  const handleLockUser = (user) => {
    setSelectedUser(user);
    setIsConfirmOpen(true);
  };

  const handleConfirmLockUser = async () => {
    try {
      const action = selectedUser.disabled ? "unlock-user" : "lock-user";
      const response = await axios.post(
        `http://localhost:3000/admin/${action}`,
        { uid: selectedUser.id }
      );
      console.log(response.data.message);
      setIsConfirmOpen(false);
      fetchUsers();
    } catch (error) {
      console.error(
        `Error ${selectedUser.disabled ? "unlocking" : "locking"} user: `,
        error
      );
      setIsConfirmOpen(false);
    }
  };

  const handlePageChange = (newPage) => {
    const startAfter = users[userPage.limit - 1]?.id || null;
    setCurrentPage(newPage);
    setUserPage({ ...userPage, startAfter });
  };

  const handleLimitChange = (val) => {
    setUserPage({ ...userPage, limit: Number(val), startAfter: null });
    setCurrentPage(1);
  };

  const renderTable = (headers, data) => (
    <div className="overflow-auto">
      <table className="min-w-full text-left">
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
          {data.map((user) => (
            <tr key={user.id} className="even:bg-blue-gray-50/50">
              <td className="p-4">
                <Typography
                  variant="small"
                  color="blue-gray"
                  className="font-normal"
                >
                  {user.email}
                </Typography>
              </td>
              <td className="p-4">
                <Typography
                  variant="small"
                  color="blue-gray"
                  className="font-normal"
                >
                  {user.displayName}
                </Typography>
              </td>
              <td className="p-4">
                <Typography
                  variant="small"
                  color="blue-gray"
                  className="font-normal"
                >
                  {user.role}
                </Typography>
              </td>
              <td className="p-4">
                <Button
                  color={user.disabled ? "green" : "red"}
                  onClick={() => handleLockUser(user)}
                >
                  {user.disabled ? "Unlock" : "Lock"}
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
        <Typography variant="h4" color="black">
          User Management
        </Typography>
        <div className="flex justify-between items-end mb-4">
          <div>
            <Typography variant="h6" color="black">
              Show
            </Typography>
            <Select
              value={String(userPage.limit)}
              onChange={(e) => handleLimitChange(e)}
            >
              <Option value="10">10</Option>
              <Option value="20">20</Option>
              <Option value="50">50</Option>
            </Select>
          </div>
          <div>
            <Input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search users..."
            />
          </div>
        </div>
        {loading ? (
          <div className="flex justify-center items-center">
            <Spinner color="blue" />
          </div>
        ) : (
          renderTable(USER_TABLE_HEAD, filteredUsers)
        )}
        <div className="flex justify-center items-center mt-4">
          <Button
            color="blue-gray"
            onClick={() => handlePageChange(currentPage - 1)}
            disabled={currentPage === 1}
          >
            Previous
          </Button>
          <span className="mx-4">{`Page ${currentPage} of ${totalPages}`}</span>
          <Button
            color="blue-gray"
            onClick={() => handlePageChange(currentPage + 1)}
            disabled={currentPage === totalPages}
          >
            Next
          </Button>
        </div>
      </div>
      <Dialog open={isConfirmOpen} handler={() => setIsConfirmOpen(false)}>
        <DialogHeader>
          {selectedUser?.disabled ? "Unlock User" : "Lock User"}
        </DialogHeader>
        <DialogBody>
          Are you sure you want to {selectedUser?.disabled ? "unlock" : "lock"}{" "}
          user {selectedUser?.email}?
        </DialogBody>
        <DialogFooter>
          <Button
            variant="text"
            color="blue-gray"
            onClick={() => setIsConfirmOpen(false)}
          >
            Cancel
          </Button>
          <Button color="blue-gray" onClick={handleConfirmLockUser}>
            {selectedUser?.disabled ? "Unlock" : "Lock"}
          </Button>
        </DialogFooter>
      </Dialog>
    </Card>
  );
};

export default UserManagement;
