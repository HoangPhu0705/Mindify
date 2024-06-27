import { BrowserRouter as Router, Route, Routes } from "react-router-dom"
import Layout from "./components/layout"
import Dashboard from "./pages/dashboard"
import Lecturer from "./pages/lecturer"
import Request from "./pages/request"
import RequestDetail from "./pages/request_detail"
export default function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<Layout/>}>
          <Route index element={<Dashboard/>} />
          <Route path="/lecturer" element={<Lecturer/>} />
          <Route path="/request" element={<Request/>} />
          <Route path="/request/:requestId" element={<RequestDetail/>} />
        </Route>
      </Routes>
    </Router>
  )
}