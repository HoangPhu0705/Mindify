import React, { useEffect, useState } from "react";
import axios from "axios";
import { Card, CardBody, CardHeader, Typography, Select, Option, Button } from "@material-tailwind/react";
import Chart from "react-apexcharts";
import { DateRangePicker } from 'react-date-range';
import { addDays } from 'date-fns';
import DashboardStatsGrid from "../components/statsgrid";
import 'react-date-range/dist/styles.css';
import 'react-date-range/dist/theme/default.css';

const Dashboard = () => {
  const [filterType, setFilterType] = useState("month");
  const [filters, setFilters] = useState({ year: new Date().getFullYear(), startDate: new Date(), endDate: new Date() });
  const [barChartConfig, setBarChartConfig] = useState({
    type: "bar",
    height: 240,
    series: [
      { name: "Enrollments", data: [] },
      { name: "Revenue", data: [], show: false } 
    ],
    options: {
      chart: {
        toolbar: { show: false },
        events: {
          legendClick: (chartContext, seriesIndex, config) => {
            if (seriesIndex === 1) {
              fetchRevenue();
            }
          },
        },
      },
      title: { text: "Revenue and Enrollments", align: 'center' },
      dataLabels: { enabled: false },
      colors: ["#020617", "#28a745"],
      plotOptions: { bar: { columnWidth: "40%", borderRadius: 2 } },
      xaxis: {
        axisTicks: { show: false },
        axisBorder: { show: false },
        labels: {
          style: { colors: "#616161", fontSize: "12px", fontFamily: "inherit", fontWeight: 400 },
        },
        categories: [],
      },
      yaxis: {
        labels: {
          style: { colors: "#616161", fontSize: "12px", fontFamily: "inherit", fontWeight: 400 },
        },
      },
      grid: {
        show: true, borderColor: "#dddddd", strokeDashArray: 5,
        xaxis: { lines: { show: true } },
        padding: { top: 5, right: 20 },
      },
      fill: { opacity: 0.8 },
      tooltip: { theme: "dark" },
      legend: {
        show: true,
        onItemClick: {
          toggleDataSeries: true,
        },
      },
    },
  });

  const handleFilterTypeChange = (val) => setFilterType(val);
  const handleFilterChange = (e) => setFilters({ ...filters, [e.target.name]: e.target.value });
  const handleDateChange = (ranges) => {
    const { selection } = ranges;
    setFilters({
      ...filters,
      startDate: selection.startDate.toISOString().split('T')[0],
      endDate: selection.endDate.toISOString().split('T')[0]
    });
  };

  const fetchEnrollments = async () => {
    let url;
    let params = {};

    if (filterType === "month") {
      url = 'http://localhost:3000/admin/monthly-enrollments';
      params.year = filters.year;
    } else if (filterType === "year") {
      url = 'http://localhost:3000/admin/yearly-enrollments';
    } else if (filterType === "dateRange") {
      url = 'http://localhost:3000/admin/date-range-enrollments';
      params.startDate = filters.startDate;
      params.endDate = filters.endDate;
    }

    try {
      const response = await axios.get(url, { params });
      const { enrollments } = response.data;

      const categories = Object.keys(enrollments).sort();
      const data = categories.map(key => enrollments[key]);

      setBarChartConfig(prevConfig => ({
        ...prevConfig,
        series: [{ name: "Enrollments", data: data }, { name: "Revenue", data: prevConfig.series[1].data, show: false }],
        options: { ...prevConfig.options, xaxis: { ...prevConfig.options.xaxis, categories: categories } },
      }));
    } catch (error) {
      console.error('Error fetching enrollments:', error);
    }
  };

  const fetchRevenue = async () => {
    let url;
    let params = {};

    if (filterType === "month") {
      url = 'http://localhost:3000/admin/monthly-transactions';
      params.year = filters.year;
    } else if (filterType === "year") {
      url = 'http://localhost:3000/admin/yearly-transactions';
    } else if (filterType === "dateRange") {
      url = 'http://localhost:3000/admin/date-range-transactions';
      params.startDate = filters.startDate;
      params.endDate = filters.endDate;
    }

    try {
      const response = await axios.get(url, { params });
      const revenue = response.data;

      const categories = Object.keys(revenue).sort();
      const data = categories.map(key => revenue[key]);

      setBarChartConfig(prevConfig => ({
        ...prevConfig,
        series: [
          { name: "Enrollments", data: prevConfig.series[0].data },
          { name: "Revenue", data: data, show: true }
        ],
        options: { ...prevConfig.options, xaxis: { ...prevConfig.options.xaxis, categories: categories } },
      }));
    } catch (error) {
      console.error('Error fetching revenue:', error);
    }
  };

  useEffect(() => {
    fetchEnrollments();
  }, [filters, filterType]);

  return (
    <div className="flex flex-col gap-4">
      <DashboardStatsGrid />
      <Card>
        <CardHeader floated={false} shadow={false} color="transparent" className="flex flex-col gap-4 rounded-none md:flex-row md:items-center">
          <div>
            <Typography variant="h6" color="blue-gray">Filter Data</Typography>
            <Typography variant="small" color="gray" className="max-w-sm font-normal">
              Select filters to visualize enrollment and revenue data
            </Typography>
          </div>
        </CardHeader>
        <CardBody className="px-2 pb-0">
          <div className="flex flex-wrap gap-4">
            <Select name="filterType" value={filterType} onChange={(e) => handleFilterTypeChange(e)} label="Filter Type">
              <Option value="month">Month</Option>
              <Option value="year">Year</Option>
              <Option value="dateRange">Date Range</Option>
            </Select>
            {filterType === "month" && (
              <Select name="year" value={filters.year} onChange={handleFilterChange} label="Year">
                {[2023, 2024, 2025].map(year => <Option key={year} value={year}>{year}</Option>)}
              </Select>
            )}
            {filterType === "dateRange" && (
              <DateRangePicker
                ranges={[{
                  startDate: new Date(filters.startDate) || new Date(),
                  endDate: new Date(filters.endDate) || addDays(new Date(), 30),
                  key: 'selection'
                }]}
                onChange={handleDateChange}
              />
            )}
            <div>
              <Button className="" onClick={() => { fetchEnrollments(); fetchRevenue(); }}>Apply Filters</Button>
            </div>
          </div>
        </CardBody>
      </Card>

      <Card>
        <CardHeader floated={false} shadow={false} color="transparent" className="flex flex-col gap-4 rounded-none md:flex-row md:items-center">
          <div>
            <Typography variant="h6" color="blue-gray">Bar Chart</Typography>
            <Typography variant="small" color="gray" className="max-w-sm font-normal">
              Visualize your data with bar chart
            </Typography>
          </div>
        </CardHeader>
        <CardBody className="px-2 pb-0">
          <Chart {...barChartConfig} />
        </CardBody>
      </Card>
    </div>
  );
};

export default Dashboard;
