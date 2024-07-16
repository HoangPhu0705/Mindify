import { BrowserRouter as Router, Route, Routes } from "react-router-dom"
import Layout from "./components/layout"
import Dashboard from "./pages/dashboard"
import Lecturer from "./pages/lecturer"
import Request from "./pages/request"
import RequestDetail from "./pages/request_detail"
import AdminLogin from "./pages/login";
import ProtectedRoute from "./pages/protectedRoute";

export default function App() {
  return (
    <Router>
      <Routes>
        <Route path="/admin-login" element={<AdminLogin />} />
        <Route path="/" element={<Layout/>}>
          <Route index element={<ProtectedRoute><Dashboard /></ProtectedRoute>} />
          <Route path="/lecturer" element={<ProtectedRoute><Lecturer /></ProtectedRoute>} />
          <Route path="/request" element={<ProtectedRoute><Request /></ProtectedRoute>} />
          <Route path="/request/:requestId" element={<ProtectedRoute><RequestDetail /></ProtectedRoute>} />
        </Route>
      </Routes>
    </Router>
  )
}