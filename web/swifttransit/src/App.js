import React from 'react';
import { BrowserRouter as Router, Routes, Route, Link, Navigate } from 'react-router-dom';
import Login from './pages/Login';
import Dashboard from './pages/Dashboard';
import BusManagement from './pages/BusManagement';

const PrivateRoute = ({ children }) => {
  const token = localStorage.getItem('token');
  return token ? children : <Navigate to="/login" />;
};

function App() {
  return (
    <Router>
      <div className="min-h-screen bg-gray-50">
        <Routes>
          <Route path="/login" element={<Login />} />
          <Route
            path="/*"
            element={
              <PrivateRoute>
                <div className="flex h-screen">
                  {/* Sidebar */}
                  <div className="w-64 bg-gray-800 text-white p-6">
                    <h1 className="text-2xl font-bold mb-8">SwiftTransit</h1>
                    <nav>
                      <ul className="space-y-4">
                        <li>
                          <Link to="/dashboard" className="block hover:text-blue-400">Dashboard</Link>
                        </li>
                        <li>
                          <Link to="/buses" className="block hover:text-blue-400">Bus Management</Link>
                        </li>
                        <li>
                          <button
                            onClick={() => {
                              localStorage.removeItem('token');
                              window.location.href = '/login';
                            }}
                            className="text-red-400 hover:text-red-300"
                          >
                            Logout
                          </button>
                        </li>
                      </ul>
                    </nav>
                  </div>
                  
                  {/* Main Content */}
                  <div className="flex-1 overflow-y-auto">
                    <Routes>
                      <Route path="/dashboard" element={<Dashboard />} />
                      <Route path="/buses" element={<BusManagement />} />
                      <Route path="/" element={<Navigate to="/dashboard" />} />
                    </Routes>
                  </div>
                </div>
              </PrivateRoute>
            }
          />
        </Routes>
      </div>
    </Router>
  );
}

export default App;
