import React from "react";
import {
  Button,
  Dialog,
  DialogHeader,
  DialogBody,
  IconButton,
  Typography,
  Input,
} from "@material-tailwind/react";

const RejectPopup = ({ open, handleOpen, onReject, setRejectionContent }) => {
  return (
    <Dialog className="p-4" size="md" open={open} handler={handleOpen}>
      <DialogHeader className="justify-between">
        <img
          src="/image/exclamation.svg"
          alt="exclamation"
          className="w-10 h-10"
        />
        <IconButton
          color="gray"
          size="sm"
          variant="text"
          onClick={handleOpen}
        >
          <svg
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
            strokeWidth={2}
            className="h-4 w-4"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              d="M6 18L18 6M6 6l12 12"
            />
          </svg>
        </IconButton>
      </DialogHeader>
      <DialogBody className="overflow-y-scroll">
        <Typography color="blue-gray" className="mb-1 font-bold">
          Rejection Reason
        </Typography>
        <Typography
          variant="paragraph"
          className="font-normal text-gray-600 max-w-lg"
        >
          Please provide the reason for rejecting this request.
        </Typography>
        <div>
          <Typography
            variant="small"
            className="mt-6 mb-2 text-gray-600 font-normal"
          >
            Enter your reason below:
          </Typography>
          <div className="flex flex-col md:flex-row gap-2">
            <Input
              color="gray"
              label="Rejection Reason"
              size="lg"
              className="w-full md:max-w-lg"
              onChange={(e) => setRejectionContent(e.target.value)}
            />
            <Button color="gray" className="w-full lg:max-w-[15rem]" onClick={onReject}>
              Reject
            </Button>
          </div>
        </div>
      </DialogBody>
    </Dialog>
  );
};

export default RejectPopup;
