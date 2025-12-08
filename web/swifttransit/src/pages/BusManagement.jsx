import React, { useState, useEffect } from 'react';
import axios from 'axios';

const BusManagement = () => {
  const [buses, setBuses] = useState([]);
  const [routes, setRoutes] = useState([]);
  const [formData, setFormData] = useState({
    registration_number: '',
    password: '',
    route_id_up: '',
    route_id_down: '',
  });
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  const fetchBuses = async () => {
    try {
      const token = localStorage.getItem('token');
      const response = await axios.get('http://localhost:8080/bus-owner/buses', {
        headers: { Authorization: `Bearer ${token}` },
      });
      setBuses(response.data || []);
    } catch (err) {
      console.error('Failed to fetch buses', err);
    }
  };

  const fetchRoutes = async () => {
    try {
      const token = localStorage.getItem('token');
      const response = await axios.get('http://localhost:8080/bus-owner/routes', {
        headers: { Authorization: `Bearer ${token}` },
      });
      setRoutes(response.data || []);
    } catch (err) {
      console.error('Failed to fetch routes', err);
    }
  };

  useEffect(() => {
    fetchBuses();
    fetchRoutes();
  }, []);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setSuccess('');
    try {
      const token = localStorage.getItem('token');
      await axios.post('http://localhost:8080/bus-owner/buses', {
        ...formData,
        route_id_up: parseInt(formData.route_id_up),
        route_id_down: parseInt(formData.route_id_down),
      }, {
        headers: { Authorization: `Bearer ${token}` },
      });
      setSuccess('Bus registered successfully');
      fetchBuses();
      setFormData({ registration_number: '', password: '', route_id_up: '', route_id_down: '' });
    } catch (err) {
      setError(err.response?.data?.message || 'Failed to register bus');
    }
  };

  return (
    <div className="p-6">
      <h1 className="text-3xl font-bold mb-6">Bus Management</h1>
      
      <div className="bg-white p-6 rounded shadow-md mb-8">
        <h2 className="text-xl font-semibold mb-4">Register New Bus</h2>
        {error && <p className="text-red-500 mb-4">{error}</p>}
        {success && <p className="text-green-500 mb-4">{success}</p>}
        <form onSubmit={handleSubmit} className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <input
            type="text"
            placeholder="Registration Number"
            value={formData.registration_number}
            onChange={(e) => setFormData({ ...formData, registration_number: e.target.value })}
            className="p-2 border rounded"
            required
          />
          <input
            type="password"
            placeholder="Password"
            value={formData.password}
            onChange={(e) => setFormData({ ...formData, password: e.target.value })}
            className="p-2 border rounded"
            required
          />
          <select
            value={formData.route_id_up}
            onChange={(e) => setFormData({ ...formData, route_id_up: e.target.value })}
            className="p-2 border rounded"
            required
          >
            <option value="">Select Route Up</option>
            {routes.map((route) => (
              <option key={route.id} value={route.id}>
                {route.name} (ID: {route.id})
              </option>
            ))}
          </select>
          <select
            value={formData.route_id_down}
            onChange={(e) => setFormData({ ...formData, route_id_down: e.target.value })}
            className="p-2 border rounded"
            required
          >
            <option value="">Select Route Down</option>
            {routes.map((route) => (
              <option key={route.id} value={route.id}>
                {route.name} (ID: {route.id})
              </option>
            ))}
          </select>
          <button
            type="submit"
            className="bg-blue-500 text-white font-bold py-2 px-4 rounded hover:bg-blue-700 transition duration-200 md:col-span-2"
          >
            Register Bus
          </button>
        </form>
      </div>

      <div className="bg-white p-6 rounded shadow-md mb-8">
        <h2 className="text-xl font-semibold mb-4">Available Routes</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {routes.map((route) => (
            <div key={route.id} className="border p-4 rounded hover:bg-gray-50">
              <h3 className="font-bold text-lg mb-2">{route.name}</h3>
              <p className="text-sm text-gray-600 mb-2">ID: {route.id}</p>
              <div className="text-sm">
                <strong>Stops:</strong>
                <ul className="list-disc list-inside ml-2 max-h-32 overflow-y-auto">
                  {route.stops && route.stops.map((stop) => (
                    <li key={stop.id}>{stop.name}</li>
                  ))}
                </ul>
              </div>
            </div>
          ))}
        </div>
      </div>

      <div className="bg-white p-6 rounded shadow-md">
        <h2 className="text-xl font-semibold mb-4">Registered Buses</h2>
        <div className="overflow-x-auto">
          <table className="min-w-full table-auto">
            <thead>
              <tr className="bg-gray-200">
                <th className="px-4 py-2 text-left">ID</th>
                <th className="px-4 py-2 text-left">Registration No</th>
                <th className="px-4 py-2 text-left">Route Up</th>
                <th className="px-4 py-2 text-left">Route Down</th>
              </tr>
            </thead>
            <tbody>
              {buses.map((bus) => (
                <tr key={bus.id} className="border-b">
                  <td className="px-4 py-2">{bus.id}</td>
                  <td className="px-4 py-2">{bus.registration_number}</td>
                  <td className="px-4 py-2">{bus.route_id_up}</td>
                  <td className="px-4 py-2">{bus.route_id_down}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

export default BusManagement;
