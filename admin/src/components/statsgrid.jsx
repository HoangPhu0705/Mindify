import React, { useEffect, useState } from 'react';
import { IoBagHandle, IoPeopleCircleOutline, IoPeople, IoCart } from 'react-icons/io5';
import axios from 'axios';

export default function DashboardStatsGrid() {
  const [totalCourses, setTotalCourses] = useState(0);
  const [totalStudents, setTotalStudents] = useState(0);
  const [totalRevenue, setTotalRevenue] = useState(0);

  useEffect(() => {
    axios.get('http://localhost:3000/admin/total-courses')
      .then(response => setTotalCourses(response.data.totalCourses))
      .catch(error => console.error('Error fetching total courses:', error));

    axios.get('http://localhost:3000/admin/total-students')
      .then(response => setTotalStudents(response.data.totalStudents))
      .catch(error => console.error('Error fetching total students:', error));

    axios.get('http://localhost:3000/admin/get-revenue')
      .then(response => setTotalRevenue(response.data.totalRevenue))
      .catch(error => console.error('Error fetching total revenue:', error));
  }, []);

  return (
    <div className="flex gap-4 w-full">
      <BoxWrapper>
        <div className="rounded-full h-12 w-12 flex items-center justify-center bg-cyan-500">
          <IoPeopleCircleOutline className="text-2xl text-white" />
        </div>
        <div className="pl-4">
          <span className="text-sm text-gray-500 font-light">Total Courses</span>
          <div className="flex items-center">
            <strong className="text-xl text-gray-700 font-semibold">{totalCourses}</strong>
          </div>
        </div>
      </BoxWrapper>
      <BoxWrapper>
        <div className="rounded-full h-12 w-12 flex items-center justify-center bg-brown-400">
          <IoPeople className="text-2xl text-white" />
        </div>
        <div className="pl-4">
          <span className="text-sm text-gray-500 font-light">Total Students</span>
          <div className="flex items-center">
            <strong className="text-xl text-gray-700 font-semibold">{totalStudents}</strong>
          </div>
        </div>
      </BoxWrapper>
      <BoxWrapper>
        <div className="rounded-full h-12 w-12 flex items-center justify-center bg-green-600">
          <IoCart className="text-2xl text-white" />
        </div>
        <div className="pl-4">
          <span className="text-sm text-gray-500 font-light">Total Revenue</span>
          <div className="flex items-center">
            <strong className="text-xl text-gray-700 font-semibold">{totalRevenue} VNĐ</strong>
          </div>
        </div>
      </BoxWrapper>
    </div>
  );
}

function BoxWrapper({ children }) {
  return <div className="bg-white rounded-sm p-4 flex-1 border border-gray-200 flex items-center justify-center">{children}</div>;
}
