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
  const [filterType, setFilterType] = useState("today");
  const [filters, setFilters] = useState({ year: new Date().getFullYear().toString(), startDate: new Date(), endDate: new Date() });
  const token = localStorage.getItem('token');

  // State for Enrollments chart
  const [enrollmentsChartConfig, setEnrollmentsChartConfig] = useState({
    type: "bar",
    height: 240,
    series: [{ name: "Enrollments", data: [] }],
    options: {
      chart: { toolbar: { show: false } },
      title: { text: "Enrollments", align: 'center' },
      dataLabels: { enabled: false },
      colors: ["#020617"],
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
    },
  });

  // State for Revenue chart
  const [revenueChartConfig, setRevenueChartConfig] = useState({
    type: "bar",
    height: 240,
    series: [{ name: "Revenue", data: [] }],
    options: {
      chart: { toolbar: { show: false } },
      title: { text: "Revenue", align: 'center' },
      dataLabels: { enabled: false },
      colors: ["#28a745"],
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
    },
  });

  const handleFilterTypeChange = (val) => setFilterType(val);

  const handleFilterChange = (e) => {
    const { name, value } = e;
    setFilters((prevFilters) => ({
      ...prevFilters,
      [name]: value,
    }));
  };

  const handleDateChange = (ranges) => {
    const { selection } = ranges;

    const startDateLocal = new Date(selection.startDate.getTime() - selection.startDate.getTimezoneOffset() * 60000);
    const endDateLocal = new Date(selection.endDate.getTime() - selection.endDate.getTimezoneOffset() * 60000);

    setFilters({
      ...filters,
      startDate: startDateLocal.toISOString().split('T')[0],
      endDate: endDateLocal.toISOString().split('T')[0],
    });
  };

  const fetchEnrollments = async () => {
    let url;
    let params = {};
    if (filterType === "today") {
      url = '/admin/enrollments-today';
    } else if (filterType === "month") {
      url = '/admin/monthly-enrollments';
      params.year = filters.year;
    } else if (filterType === "year") {
      url = '/admin/yearly-enrollments';
    } else if (filterType === "dateRange") {
      url = '/admin/date-range-enrollments';
      params.startDate = filters.startDate;
      params.endDate = filters.endDate;
    }

    try {
      const response = await axios.get(url, {
        params,
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });
      const { enrollments } = response.data;
      console.log(response.data);

      const categories = Object.keys(enrollments).sort((a, b) => new Date(a) - new Date(b));
      const data = categories.map(key => enrollments[key]);

      setEnrollmentsChartConfig(prevConfig => ({
        ...prevConfig,
        series: [{ name: "Enrollments", data: data }],
        options: { ...prevConfig.options, xaxis: { ...prevConfig.options.xaxis, categories: categories } },
      }));
    } catch (error) {
      console.error('Error fetching enrollments:', error);
    }
  };

  const fetchRevenue = async () => {
    let url;
    let params = {};

    if (filterType === "today") {
      url = '/admin/revenue-today';
    } else if (filterType === "month") {
      url = '/admin/monthly-transactions';
      params.year = filters.year;
    } else if (filterType === "year") {
      url = '/admin/yearly-transactions';
    } else if (filterType === "dateRange") {
      url = '/admin/date-range-transactions';
      params.startDate = filters.startDate;
      params.endDate = filters.endDate;
    }

    try {
      const response = await axios.get(url, {
        params,
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });
      const revenue = response.data;

      const categories = Object.keys(revenue).sort((a, b) => new Date(a) - new Date(b));
      const data = categories.map(key => revenue[key]);

      setRevenueChartConfig(prevConfig => ({
        ...prevConfig,
        series: [{ name: "Revenue", data: data }],
        options: { ...prevConfig.options, xaxis: { ...prevConfig.options.xaxis, categories: categories } },
      }));
    } catch (error) {
      console.error('Error fetching revenue:', error);
    }
  };

  useEffect(() => {
    fetchEnrollments();
    fetchRevenue();
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
        <CardBody className="px-2 pb-5">
          <div className="flex flex-wrap gap-4">
            <Select name="filterType" value={filterType} onChange={(e) => handleFilterTypeChange(e)} label="Filter Type">
            <Option value="today">Today</Option>
              <Option value="month">Year</Option>
              <Option value="year">All</Option>
              <Option value="dateRange">Date Range</Option>
            </Select>
            {filterType === "month" && (
              <Select name="year" value={filters.year} onChange={handleFilterChange} label="Year">
                {["2023", "2024", "2025"].map(year => <Option key={year} value={year}>{year}</Option>)}
              </Select>
            )}
            {filterType === "dateRange" && (
              <div>
                <DateRangePicker
                  ranges={[{
                    startDate: new Date(filters.startDate) || new Date(),
                    endDate: new Date(filters.endDate) || addDays(new Date(), 30),
                    key: 'selection'
                  }]}
                  onChange={handleDateChange}
                />
                <div className="w-full flex justify-end items-end mb-5">
                  <Button className="" onClick={() => { fetchEnrollments(); fetchRevenue(); }}>Apply Filters</Button>
                </div>

              </div>

            )}

          </div>
        </CardBody>
      </Card>

      <Card>
        <CardBody>
          <div id="chart">
            <Chart {...enrollmentsChartConfig} />
          </div>
        </CardBody>
      </Card>

      <Card>
        <CardBody>
          <div id="chart">
            <Chart {...revenueChartConfig} />
          </div>
        </CardBody>
      </Card>

    </div>
  );
};

export default Dashboard;
