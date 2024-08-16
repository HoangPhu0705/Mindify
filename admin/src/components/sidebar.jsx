import React, { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import axios from "axios";
import {
  PresentationChartBarIcon,
  UserGroupIcon,
  PaperAirplaneIcon,
  ComputerDesktopIcon,
  ExclamationCircleIcon,
  AcademicCapIcon,
  ClipboardDocumentListIcon,
  PowerIcon
} from "@heroicons/react/24/solid";

export default function Sidebar() {
  const [activeItem, setActiveItem] = useState(window.location.pathname); // Set initial active item based on current path
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

  // Function to handle item click
  const handleClick = (path) => {
    setActiveItem(path);
    navigate(path);
  };

  return (
    <div className="h-[calc(100vh-2rem)] w-64 p-4 shadow-xl shadow-blue-gray-900/5 bg-white">
      <div className="mb-2 p-4">
        <h1 className="text-[#7DD6FF] text-3xl font-bold text-center">
          Mindify.
        </h1>
      </div>
      <div className="flex flex-col">
        <div 
          onClick={() => handleClick("/")}
          className={`flex items-center p-3 mb-4 rounded-lg transition-colors duration-300 ease-in-out cursor-pointer ${
            activeItem === "/" ? "bg-[#062137] text-white" : "hover:bg-[#062137] hover:text-white"
          }`}
        >
          <PresentationChartBarIcon className="h-5 w-5 mr-2" />
          <span>Dashboard</span>
        </div>

        <div 
          onClick={() => handleClick("/user-management")}
          className={`flex items-center p-3 mb-4 rounded-lg transition-colors duration-300 ease-in-out cursor-pointer ${
            activeItem === "/user-management" ? "bg-[#062137] text-white" : "hover:bg-[#062137] hover:text-white"
          }`}
        >
          <UserGroupIcon className="h-5 w-5 mr-2" />
          <span>User Management</span>
        </div>

        <div 
          onClick={() => handleClick("/course-management")}
          className={`flex items-center p-3 mb-4 rounded-lg transition-colors duration-300 ease-in-out cursor-pointer ${
            activeItem === "/course-management" ? "bg-[#062137] text-white" : "hover:bg-[#062137] hover:text-white"
          }`}
        >
          <AcademicCapIcon className="h-5 w-5 mr-2" />
          <span>Course Management</span>
        </div>

        <div 
          onClick={() => handleClick("/transaction-management")}
          className={`flex items-center p-3 mb-4 rounded-lg transition-colors duration-300 ease-in-out cursor-pointer ${
            activeItem === "/transaction-management" ? "bg-[#062137] text-white" : "hover:bg-[#062137] hover:text-white"
          }`}
        >
          <ClipboardDocumentListIcon className="h-5 w-5 mr-2" />
          <span>Transaction</span>
        </div>

        <div 
          onClick={() => handleClick("/request")}
          className={`flex items-center p-3 mb-4 rounded-lg transition-colors duration-300 ease-in-out cursor-pointer ${
            activeItem === "/request" ? "bg-[#062137] text-white" : "hover:bg-[#062137] hover:text-white"
          }`}
        >
          <PaperAirplaneIcon className="h-5 w-5 mr-2" />
          <span>Requests</span>
        </div>

        <div 
          onClick={() => handleClick("/courseRequest")}
          className={`flex items-center p-3 mb-4 rounded-lg transition-colors duration-300 ease-in-out cursor-pointer ${
            activeItem === "/courseRequest" ? "bg-[#062137] text-white" : "hover:bg-[#062137] hover:text-white"
          }`}
        >
          <ComputerDesktopIcon className="h-5 w-5 mr-2" />
          <span>Course Request</span>
        </div>

        <div 
          onClick={() => handleClick("/report")}
          className={`flex items-center p-3 mb-4 rounded-lg transition-colors duration-300 ease-in-out cursor-pointer ${
            activeItem === "/report" ? "bg-[#062137] text-white" : "hover:bg-[#062137] hover:text-white"
          }`}
        >
          <ExclamationCircleIcon className="h-5 w-5 mr-2" />
          <span>Reports</span>
        </div>

        <div 
          onClick={handleLogout} 
          className="flex items-center p-3 mb-4 rounded-lg transition-colors duration-300 ease-in-out hover:bg-[#062137] hover:text-white cursor-pointer"
        >
          <PowerIcon className="h-5 w-5 mr-2" />
          <span>Log Out</span>
        </div>
      </div>
    </div>
  );
}
