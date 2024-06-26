import { BrowserRouter as Router, Route, Routes } from "react-router-dom"
import Layout from "./components/layout"
import Dashboard from "./pages/dashboard"
import Lecturer from "./pages/lecturer"
import Request from "./pages/request"
export default function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<Layout/>}>
          <Route index element={<Dashboard/>} />
          <Route path="/lecturer" element={<Lecturer/>} />
          <Route path="/request" element={<Request/>} />
        </Route>
      </Routes>
    </Router>
  )
}