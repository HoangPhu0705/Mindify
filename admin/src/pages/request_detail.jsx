import React, { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import axios from 'axios';
import { Card, Typography, Button } from "@material-tailwind/react";

const RequestDetail = () => {
  const { requestId } = useParams();
  const navigate = useNavigate();
  const [details, setDetails] = useState(null);
  const [error, setError] = useState('');
  const [isApproved, setIsApproved] = useState(false);
  const [loading, setLoading] = useState(false); 

  useEffect(() => {
    const fetchDetails = async () => {
      try {
        const response = await axios.get(`http://localhost:3000/api/users/requests/${requestId}`);
        setDetails(response.data);
        setIsApproved(response.data.request.isApproved);
      } catch (err) {
        setError('Error fetching details');
      }
    };

    fetchDetails();
  }, [requestId]);

  const approveRequest = async () => {
    setLoading(true); 
    try {
      await axios.put(`http://localhost:3000/api/users/requests/${requestId}/approve`);
      setIsApproved(true);
      setLoading(false);  
      navigate('/request');  
    } catch (err) {
      setLoading(false);  
      console.error('Error approving request', err);
    }
  };

  if (error) {
    return <p>{error}</p>;
  }

  if (!details) {
    return <p>Loading...</p>;
  }

  return (
    <Card className="h-full w-full p-6 shadow-lg">
      <div className="mb-6">
        <Typography variant="h4" color="black" className="dark:text-white mb-4">
          Request Details
        </Typography>
      </div>
      <div className="p-4 space-y-4">
        <Typography variant="h6" className="text-gray-700">
          <span className="font-bold">Full Name:</span> {details.request.firstName} {details.request.lastName}
        </Typography>
        <Typography variant="h6" className="text-gray-700">
          <span className="font-bold">Email:</span> {details.request.user_email}
        </Typography>
        <Typography variant="h6" className="text-gray-700">
          <span className="font-bold">Category:</span> {details.request.category}
        </Typography>
        <Typography variant="h6" className="text-gray-700">
          <span className="font-bold">Country:</span> {details.request.countryName}
        </Typography>
        <Typography variant="h6" className="text-gray-700">
          <span className="font-bold">Date of Birth:</span> {details.request.dob}
        </Typography>
        <Typography variant="h6" className="text-gray-700">
          <span className="font-bold">Phone Number:</span> {details.request.phoneNumber}
        </Typography>
        <Typography variant="h6" className="text-gray-700">
          <span className="font-bold">Topic Description:</span> {details.request.topicDescription}
        </Typography>
        <Typography variant="h6" className="text-gray-700">
          <span className="font-bold">Is Approved:</span> {isApproved ? "Yes" : "No"}
        </Typography>
        {!isApproved && (
          <Button
            onClick={approveRequest}
            className="bg-blue-500 text-white mt-4"
            disabled={loading} 
          >
            {loading ? 'Approving...' : 'Approve'}
          </Button>
        )}
      </div>
    </Card>
  );
};

export default RequestDetail;
