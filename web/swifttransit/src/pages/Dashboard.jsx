import React, { useEffect, useState } from 'react';
import axios from 'axios';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';

const Dashboard = () => {
  const [stats, setStats] = useState({
    total_revenue: 0,
    total_tickets: 0,
    today: { revenue: 0, tickets: 0 },
    weekly: { revenue: 0, tickets: 0 },
    monthly: { revenue: 0, tickets: 0 },
  });

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const token = localStorage.getItem('token');
        const response = await axios.get('http://localhost:8080/bus-owner/analytics', {
          headers: { Authorization: `Bearer ${token}` },
        });
        setStats(response.data);
      } catch (err) {
        console.error('Failed to fetch stats', err);
      }
    };
    fetchStats();
  }, []);

  const chartData = [
    { name: 'Today', Revenue: stats.today.revenue, Tickets: stats.today.tickets },
    { name: 'This Week', Revenue: stats.weekly.revenue, Tickets: stats.weekly.tickets },
    { name: 'This Month', Revenue: stats.monthly.revenue, Tickets: stats.monthly.tickets },
    { name: 'Total', Revenue: stats.total_revenue, Tickets: stats.total_tickets },
  ];

  return (
    <div className="p-6">
      <h1 className="text-3xl font-bold mb-6">Dashboard</h1>
      
      {/* Summary Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        <div className="bg-white p-6 rounded shadow-md">
          <h3 className="text-xl font-semibold mb-2">Total Revenue</h3>
          <p className="text-4xl font-bold text-green-600">${stats.total_revenue}</p>
        </div>
        <div className="bg-white p-6 rounded shadow-md">
          <h3 className="text-xl font-semibold mb-2">Total Tickets</h3>
          <p className="text-4xl font-bold text-blue-600">{stats.total_tickets}</p>
        </div>
        <div className="bg-white p-6 rounded shadow-md">
          <h3 className="text-xl font-semibold mb-2">Today's Revenue</h3>
          <p className="text-4xl font-bold text-green-500">${stats.today.revenue}</p>
        </div>
        <div className="bg-white p-6 rounded shadow-md">
          <h3 className="text-xl font-semibold mb-2">Today's Tickets</h3>
          <p className="text-4xl font-bold text-blue-500">{stats.today.tickets}</p>
        </div>
      </div>

      {/* Detailed Analytics Chart */}
      <div className="bg-white p-6 rounded shadow-md h-96">
        <h3 className="text-xl font-semibold mb-4">Analytics Overview</h3>
        <ResponsiveContainer width="100%" height="100%">
          <BarChart data={chartData}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey="name" />
            <YAxis />
            <Tooltip />
            <Legend />
            <Bar dataKey="Revenue" fill="#82ca9d" />
            <Bar dataKey="Tickets" fill="#8884d8" />
          </BarChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
};

export default Dashboard;
