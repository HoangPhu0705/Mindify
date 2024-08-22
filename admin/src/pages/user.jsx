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
  Chip,
  Tabs,
  TabsHeader,
  Tab,
} from "@material-tailwind/react";

const USER_TABLE_HEAD = ["Email", "Display Name", "Role", "Lock Account"];

const UserManagement = () => {
  const [users, setUsers] = useState([]);
  const [searchQuery, setSearchQuery] = useState("");
  const [userPage, setUserPage] = useState({ limit: 10, startAfter: null });
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [selectedUser, setSelectedUser] = useState(null);
  const [isConfirmOpen, setIsConfirmOpen] = useState(false);
  const [loading, setLoading] = useState(false);
  const [selectedTab, setSelectedTab] = useState("all");
  const roles = [
    { label: "All", value: "all" },
    { label: "Teacher", value: "teacher" },
    { label: "User", value: "user" },
  ];
  const [filteredUsers, setFilteredUsers] = useState([]);

  useEffect(() => {
    fetchUsers();
  }, [userPage, currentPage]);

  useEffect(() => {
    if (selectedTab === "all") {
      setFilteredUsers(users);
    } else {
      setFilteredUsers(
        users.filter((user) => user.role.toLowerCase() === selectedTab)
      );
    }
  }, [selectedTab, users]);

  const fetchUsers = async () => {
    setLoading(true);
    try {
      const token = localStorage.getItem("token");

      const response = await axios.get("/admin/users-management", {
        params: {
          limit: userPage.limit,
          startAfter: userPage.startAfter,
          searchQuery: searchQuery,
        },
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });

      const { users, totalCount } = response.data;
      setUsers(users);
      setFilteredUsers(users);
      setTotalPages(Math.ceil(totalCount / userPage.limit));
    } catch (error) {
      console.error("Error fetching users: ", error);
    } finally {
      setLoading(false);
    }
  };

  const handleSearch = () => {
    setCurrentPage(1);
    setUserPage({ ...userPage, startAfter: null });
    fetchUsers();
  };

  const handleLockUser = (user) => {
    setSelectedUser(user);
    setIsConfirmOpen(true);
  };

  const handleConfirmLockUser = async () => {
    try {
      const token = localStorage.getItem("token");
      const action = selectedUser.disabled ? "unlock-user" : "lock-user";
      const response = await axios.post(
        `/admin/${action}`,
        { uid: selectedUser.id },
        {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        }
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
                <Chip
                  className="inline-block w-auto"
                  value={user.role}
                  color={
                    user.role === "teacher"
                      ? "blue"
                      : user.role === "user"
                      ? "green"
                      : "red"
                  }
                />
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
          <div className="flex">
            <Input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              label="Search users..."
            />
            <Button className="ml-4" onClick={handleSearch}>
              Search
            </Button>
          </div>

          <div className="flex items-center">
            <Typography variant="h6" color="black" className="mr-2">
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
        </div>
        <Tabs value={selectedTab} className="mb-2 flex-">
          <TabsHeader>
            {roles.map(({ label, value }) => (
              <Tab
                key={value}
                value={value}
                onClick={() => setSelectedTab(value)}
              >
                <div className="px-4">{label}</div>
              </Tab>
            ))}
          </TabsHeader>
        </Tabs>
        {loading ? (
          <div className="flex justify-center items-center">
            <Spinner color="blue" />
          </div>
        ) : (
          renderTable(USER_TABLE_HEAD, filteredUsers)
        )}
        <div className="flex justify-center items-center mt-4">
          <Button
            color="black"
            className="hover:bg-black hover:text-white"
            variant="outlined"
            onClick={() => handlePageChange(currentPage - 1)}
            disabled={currentPage === 1}
          >
            Previous
          </Button>
          <span className="mx-4">{`Page ${currentPage} of ${totalPages}`}</span>
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
      <Dialog open={isConfirmOpen} handler={() => setIsConfirmOpen(false)}>
        <DialogHeader>
          {selectedUser?.disabled ? "Unlock User" : "Lock User"}
        </DialogHeader>
        <DialogBody>
          Are you sure you want to{" "}
          {selectedUser?.disabled ? "unlock" : "lock"} user{" "}
          {selectedUser?.email}?
        </DialogBody>
        <DialogFooter>
          <Button
            color="black"
            className="hover:bg-black hover:text-white mr-2"
            variant="outlined"
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
