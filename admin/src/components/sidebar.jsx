import React from "react";
import { Link, useNavigate } from "react-router-dom";
import axios from "axios";
import { Card, Typography, List, ListItem, ListItemPrefix } from "@material-tailwind/react";
import {
  PresentationChartBarIcon,
  UserGroupIcon,
  PaperAirplaneIcon,
  UserCircleIcon,
  Cog6ToothIcon,
  ClipboardDocumentListIcon,
  PowerIcon,
  ComputerDesktopIcon,
  ExclamationCircleIcon,
  AcademicCapIcon // Icon cho Course Management
} from "@heroicons/react/24/solid";

export default function Sidebar() {
  const navigate = useNavigate();

  const handleLogout = async () => {
    try {
      await axios.get("/admin/admin-logout");
      localStorage.removeItem("token");
      navigate("/admin-login");
    } catch (error) {
      console.error("Error logging out: ", error);
    }
  };

  return (
    <Card className="h-[calc(100vh-2rem)] w-full max-w-[20rem] p-4 shadow-xl shadow-blue-gray-900/5">
      <div className="mb-2 p-4">
        <Typography className="text-[#7DD6FF] text-3xl font-bold text-center">
          Mindify.
        </Typography>
      </div>
      <List>
        <Link to="/">
          <ListItem className={`hover:bg-[#062137] hover:text-white`}>
            <ListItemPrefix>
              <PresentationChartBarIcon className="h-5 w-5" />
            </ListItemPrefix>
            Dashboard
          </ListItem>
        </Link>

        <Link to="/user-management">
          <ListItem className={`hover:bg-[#062137] hover:text-white`}>
            <ListItemPrefix>
              <UserGroupIcon className="h-5 w-5" />
            </ListItemPrefix>
            User Management
          </ListItem>
        </Link>

        <Link to="/course-management">
          <ListItem className={`hover:bg-[#062137] hover:text-white`}>
            <ListItemPrefix>
              <AcademicCapIcon className="h-5 w-5" />
            </ListItemPrefix>
            Course Management
          </ListItem>
        </Link>

        <Link to="/transaction-management">
          <ListItem className={`hover:bg-[#062137] hover:text-white`}>
            <ListItemPrefix>
              <ClipboardDocumentListIcon className="h-5 w-5" />
            </ListItemPrefix>
            Transaction Management
          </ListItem>
        </Link>

        <Link to="/report">
          <ListItem className={`hover:bg-[#062137] hover:text-white`}>
            <ListItemPrefix>
              <ExclamationCircleIcon className="h-5 w-5" />
            </ListItemPrefix>
            Reports
          </ListItem>
        </Link>

        <Link to="/request">
          <ListItem className={`hover:bg-[#062137] hover:text-white`}>
            <ListItemPrefix>
              <PaperAirplaneIcon className="h-5 w-5" />
            </ListItemPrefix>
            Requests
          </ListItem>
        </Link>

        <Link to="/courseRequest">
          <ListItem className={`hover:bg-[#062137] hover:text-white`}>
            <ListItemPrefix>
              <ComputerDesktopIcon className="h-5 w-5" />
            </ListItemPrefix>
            Course Request
          </ListItem>
        </Link>

       
        <ListItem onClick={handleLogout} className={`hover:bg-[#062137] hover:text-white cursor-pointer`}>
          <ListItemPrefix>
            <PowerIcon className="h-5 w-5" />
          </ListItemPrefix>
          Log Out
        </ListItem>
      </List>
    </Card>
  );
}
