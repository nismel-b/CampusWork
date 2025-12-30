import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import { useState } from "react";

import Login from "./pages/connexion/login";
import CreateProject from "./pages/createProject";
import StudentDashboard from "./pages/dashboard/studentDashboard";
import LecturerDashboard from "./pages/dashboard/lecturerDashboard";
import AdminDashboard from "./pages/dashboard/adminDashboard";
import Projects from "./pages/Projects";

import DashboardLayout from "./components/layout/layout";

function App() {
  const storedUser = JSON.parse(localStorage.getItem("user"));
  const [user, setUser] = useState(storedUser);

  if (!user) {
    return (
      <Login
        onLoginSuccess={(userData) => {
          localStorage.setItem("user", JSON.stringify(userData));
          setUser(userData);
        }}
      />
    );
  }

  return (
    <BrowserRouter>
      <Routes>
        <Route
          element={
            <DashboardLayout
              user={user}
              role={user.role}
              onLogout={() => {
                localStorage.clear();
                setUser(null);
              }}
            />
          }
        >
          <Route path="/" element={<Projects />} />
          <Route path="/projects/new" element={<CreateProject />} />
          <Route path="/student" element={<StudentDashboard />} />
          <Route path="/lecturer" element={<LecturerDashboard />} />
          <Route path="/admin" element={<AdminDashboard />} />
        </Route>

        <Route path="*" element={<Navigate to="/" />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;
