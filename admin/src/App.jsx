import React from "react";
import { BrowserRouter as Router, Route, Routes } from "react-router-dom";
import Layout from "./components/layout";
import Dashboard from "./pages/dashboard";
import Lecturer from "./pages/lecturer";
import Request from "./pages/request";
import RequestDetail from "./pages/request_detail";
import AdminLogin from "./pages/login";
import ProtectedRoute from "./pages/protectedRoute";
import UserManagement from "./pages/user"; 
import CourseManagement from "./pages/course"; 

export default function App() {
  return (
    <Router>
      <Routes>
        <Route path="/admin-login" element={<AdminLogin />} />
        <Route path="/" element={<Layout />}>
          <Route index element={<ProtectedRoute><Dashboard /></ProtectedRoute>} />
          <Route path="/lecturer" element={<ProtectedRoute><Lecturer /></ProtectedRoute>} />
          <Route path="/user-management" element={<ProtectedRoute><UserManagement /></ProtectedRoute>} /> {/* Thêm route cho UserManagement */}
          <Route path="/course-management" element={<ProtectedRoute><CourseManagement /></ProtectedRoute>} /> {/* Thêm route cho CourseManagement */}
          <Route path="/request" element={<ProtectedRoute><Request /></ProtectedRoute>} />
          <Route path="/request/:requestId" element={<ProtectedRoute><RequestDetail /></ProtectedRoute>} />
        </Route>
      </Routes>
    </Router>
  );
}
