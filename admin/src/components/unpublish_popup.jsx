import React from "react";
import {
  Button,
  Dialog,
  DialogHeader,
  DialogBody,
  IconButton,
  Typography,
  Input,
  Textarea,
} from "@material-tailwind/react";

const UnpublishPopup = ({ open, handleOpen, onUnpublish, setUnpublishContent }) => {
  return (
    <Dialog className="p-4" size="md" open={open} handler={handleOpen}>
      <DialogHeader className="justify-between">
      <Typography color="blue-gray" className="mb-1 text-2xl font-bold">
          Unpublish Reason
        </Typography>
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
      <DialogBody >
        
        <Typography
          variant="paragraph"
          className="font-normal text-gray-600 max-w-lg"
        >
          Please provide the reason for unpublishing this course.
        </Typography>
        <div>
          <Typography
            variant="small"
            className="mt-6 mb-2 text-gray-600 font-normal"
          >
            Enter your reason below:
          </Typography>
          <div className="flex flex-col md:flex-row gap-2">
            <Textarea
              color="gray"
              label="Rejection Reason"
              size="lg"
              className="w-full line-clamp-3 " 
              onChange={(e) => setUnpublishContent(e.target.value)}
            />
            
          </div>
          <Button color="gray" className="w-full mt-2" onClick={onUnpublish}>
              Send
          </Button>
        </div>
      </DialogBody>
    </Dialog>
  );
};

export default UnpublishPopup;
