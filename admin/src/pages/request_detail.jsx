import React, { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import axios from "axios";
import { ToastContainer, toast } from "react-toastify";
import "react-toastify/dist/ReactToastify.css";
import {
  Card,
  Typography,
  Button,
  Textarea,
  Alert,
  Input,
} from "@material-tailwind/react";
import {
  EnvelopeOpenIcon,
  GlobeAltIcon,
  TagIcon,
  CalendarDaysIcon,
  PhoneIcon,
} from "@heroicons/react/24/solid";
import RejectPopup from "../components/rejection_popup";

const RequestDetail = () => {
  const { requestId } = useParams();
  const navigate = useNavigate();
  const [details, setDetails] = useState(null);
  const [error, setError] = useState("");
  const [isApproved, setIsApproved] = useState(false);
  const [isRejected, setIsRejected] = useState(false);
  const [loading, setLoading] = useState(false);
  const [popupOpen, setPopupOpen] = useState(false);
  const [rejectionContent, setRejectionContent] = useState("");
  const token = localStorage.getItem("token");
  const notify = () =>
    toast("Email sent!", {
      position: "top-center",
      autoClose: 2000,
      hideProgressBar: true,
      closeOnClick: true,
      pauseOnHover: true,
      draggable: true,
      progress: undefined,
      theme: "light",
    });

  useEffect(() => {
    const fetchDetails = async () => {
      try {
        const response = await axios.get(`/api/users/requests/${requestId}`, {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        });
        setDetails(response.data);
        setIsApproved(response.data.request.status == "Approved");
        setIsRejected(response.data.request.status == "Declined");
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
        `/api/users/requests/${requestId}/approve`,
        { content: rejectionContent },
        {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        }
      );
      setIsApproved(true);
      setLoading(false);
      notify();
     
    } catch (err) {
      setLoading(false);
      console.error("Error approving request", err);
    }
  };

  const rejectRequest = async () => {
    setLoading(true);
    setPopupOpen(false);


    try {
      await axios.put(
        `/api/users/requests/${requestId}/reject`,
        { content: rejectionContent },
        {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        }
      );

      setIsRejected(true);
      setLoading(false);
      notify();
    
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

  const handleOpenPopup = () => {
    setPopupOpen(true);
  };

  return (
    <div className="h-full w-full p-6">
          <ToastContainer />

      <div className="flex flex-row justify-between">
        <Typography variant="h4" color="black" className="dark:text-white mb-4">
          Request Details
        </Typography>
        <div className="">
          <Button
            onClick={approveRequest}
            color="green"
            size="sm"
            disabled={isApproved || isRejected || loading}
            className="mr-5"
          >
            {loading ? "Processing..." : "Approve"}
          </Button>
          <Button
            onClick={handleOpenPopup}
            color="red"
            size="sm"
            disabled={isApproved || isRejected || loading}
          >
            {loading ? "Processing..." : "Reject"}
          </Button>
        </div>
      </div>
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
        <div className="w-full">
          <Typography
            variant="small"
            color="blue-gray"
            className="mb-2 font-medium"
          >
            Class description
          </Typography>
          <Textarea
            readOnly={true}
            placeholder={details.request.topicDescription}
            className="placeholder:opacity-100 placeholder:text-black focus:border-t-black border-t-blue-gray-200"
          />
        </div>
        <div className="w-full">
          <Typography
            variant="small"
            color="blue-gray"
            className="mb-2 font-medium"
          >
            ID Card
          </Typography>
          <div className="flex justify-center mb-8">
            <img
              className="h-96 w-1/2 rounded-lg object-contain object-center"
              src={details.request.idCard}
              alt="User Id"
            />
          </div>
        </div>
        <RejectPopup
          open={popupOpen}
          handleOpen={() => setPopupOpen(!popupOpen)}
          onReject={rejectRequest}
          setRejectionContent={setRejectionContent}
        />
      </div>
    </div>
  );
};

export default RequestDetail;
