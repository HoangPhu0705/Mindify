import React, { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import axios from "axios";
import {
  Card,
  Typography,
  Button,
  Textarea,
  Input,
} from "@material-tailwind/react";
import {
  EnvelopeOpenIcon,
  GlobeAltIcon,
  TagIcon,
  CalendarDaysIcon,
  PhoneIcon,
} from "@heroicons/react/24/solid";
const RequestDetail = () => {
  const { requestId } = useParams();
  const navigate = useNavigate();
  const [details, setDetails] = useState(null);
  const [error, setError] = useState("");
  const [isApproved, setIsApproved] = useState(false);
  const [isRejected, setIsRejected] = useState(false);
  const [loading, setLoading] = useState(false);
  const [rejectionContent, setRejectionContent] = useState("");

  useEffect(() => {
    const fetchDetails = async () => {
      try {
        const response = await axios.get(
          `http://localhost:3000/api/users/requests/${requestId}`
        );
        setDetails(response.data);
        setIsApproved(response.data.request.isApproved);
        setIsRejected(response.data.request.isRejected);
      } catch (err) {
        setError("Error fetching details");
      }
    };

    fetchDetails();
  }, [requestId]);

  const approveRequest = async () => {
    setLoading(true);
    try {
      await axios.put(
        `http://localhost:3000/api/users/requests/${requestId}/approve`
      );
      setIsApproved(true);
      setLoading(false);
      navigate("/request");
    } catch (err) {
      setLoading(false);
      console.error("Error approving request", err);
    }
  };

  const rejectRequest = async () => {
    setLoading(true);
    try {
      await axios.put(
        `http://localhost:3000/api/users/requests/${requestId}/reject`,
        { content: rejectionContent }
      );
      setIsRejected(true);
      setLoading(false);
      navigate("/request");
    } catch (err) {
      setLoading(false);
      console.error("Error rejecting request", err);
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
      <Typography variant="h4" color="black" className="dark:text-white mb-4">
        Request Details
      </Typography>

      <div className="flex flex-col mt-8">
        <div className="mb-6 flex flex-col items-end gap-4 md:flex-row">
          <div className="w-full">
            <Typography
              variant="small"
              color="blue-gray"
              className="mb-2 font-medium"
            >
              First Name
            </Typography>
            <Input
              readOnly={true}
              size="lg"
              placeholder={details.request.firstName}
              labelProps={{
                className: "hidden",
              }}
              className="w-full placeholder:opacity-100 placeholder:text-black focus:border-t-black border-t-blue-gray-200"
            />
          </div>
          <div className="w-full">
            <Typography
              variant="small"
              color="blue-gray"
              className="mb-2 font-medium"
            >
              Last Name
            </Typography>
            <Input
              readOnly={true}
              size="lg"
              placeholder={details.request.lastName}
              labelProps={{
                className: "hidden",
              }}
              className="w-full placeholder:opacity-100 placeholder:text-black focus:border-t-black border-t-blue-gray-200"
            />
          </div>
        </div>
        <div className="mb-6 flex flex-col items-end gap-4 md:flex-row">
          <div className="w-full">
            <Typography
              variant="small"
              color="blue-gray"
              className="mb-2 font-medium"
            >
              Category
            </Typography>
            <Input
              readOnly={true}
              size="lg"
              icon={<TagIcon className="h-5 w-5 text-gray-500" />}
              placeholder={details.request.category}
              labelProps={{
                className: "hidden",
              }}
              className="w-full placeholder:opacity-100 placeholder:text-black focus:border-t-black border-t-blue-gray-200"
            />
          </div>
          <div className="w-full">
            <Typography
              variant="small"
              color="blue-gray"
              className="mb-2 font-medium"
            >
              Country
            </Typography>
            <Input
              readOnly={true}
              icon={<GlobeAltIcon className="h-5 w-5 text-gray-500" />}
              size="lg"
              placeholder={details.request.countryName}
              labelProps={{
                className: "hidden",
              }}
              className="w-full placeholder:opacity-100 placeholder:text-black focus:border-t-black border-t-blue-gray-200"
            />
          </div>
        </div>
        <div className="mb-6 flex flex-col items-end gap-4 md:flex-row">
          <div className="w-full">
            <Typography
              variant="small"
              color="blue-gray"
              className="mb-2 font-medium"
            >
              Email
            </Typography>
            <Input
              icon={<EnvelopeOpenIcon className="h-5 w-5 text-gray-500" />}
              readOnly={true}
              size="lg"
              placeholder={details.request.user_email}
              labelProps={{
                className: "hidden",
              }}
              className="w-full placeholder:opacity-100 placeholder:text-black focus:border-t-black border-t-blue-gray-200"
            />
          </div>
        </div>
        <div className="mb-6 flex flex-col items-end gap-4 md:flex-row">
          <div className="w-full">
            <Typography
              variant="small"
              color="blue-gray"
              className="mb-2 font-medium"
            >
              Birth date
            </Typography>
            <Input
              icon={<CalendarDaysIcon className="h-5 w-5 text-gray-500" />}
              readOnly={true}
              size="lg"
              placeholder={details.request.dob}
              labelProps={{
                className: "hidden",
              }}
              className="w-full placeholder:opacity-100 placeholder:text-black focus:border-t-black border-t-blue-gray-200"
            />
          </div>
          <div className="w-full">
            <Typography
              variant="small"
              color="blue-gray"
              className="mb-2 font-medium"
            >
              Phone Number
            </Typography>
            <Input
              icon={<PhoneIcon className="h-5 w-5 text-gray-500" />}
              readOnly={true}
              size="lg"
              placeholder={details.request.phoneNumber}
              labelProps={{
                className: "hidden",
              }}
              className="w-full placeholder:opacity-100 placeholder:text-black focus:border-t-black border-t-blue-gray-200"
            />
          </div>
        </div>

          <form className="mb-6 flex flex-col items-end gap-4 ">
            <Textarea
              value={rejectionContent}
              onChange={(e) => setRejectionContent(e.target.value)}
              label="Rejection Reason"
              required = {true}
            />

            <div className="flex space-x-4 w-full">
              <Button
                onClick={approveRequest}
                color="green"
                size="sm"
                disabled={isApproved || isRejected || loading}
              >
                {loading ? "Processing..." : "Approve"}
              </Button>
              <Button
                onClick={rejectRequest}
                type="submit"
                color="red"
                size="sm"
                disabled={isApproved || isRejected || loading}
              >
                {loading ? "Processing..." : "Reject"}
              </Button>
            </div>
          </form>
        </div>

      {/* <div className="p-4 space-y-4">
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

        <Textarea
          value={rejectionContent}
          onChange={(e) => setRejectionContent(e.target.value)}
          label="Rejection Reason"
        />

        <div className="flex space-x-4">
          <Button
            onClick={approveRequest}
            color="green"
            size="sm"
            disabled={isApproved || isRejected || loading} 
          >
            {loading ? 'Processing...' : 'Approve'}
          </Button>
          <Button
            onClick={rejectRequest}
            color="red"
            size="sm"
            disabled={isApproved || isRejected || loading} 
          >
            {loading ? 'Processing...' : 'Reject'}
          </Button>
        </div>
      </div> */}
    </Card>
  );
};

export default RequestDetail;
