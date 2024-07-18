import React from 'react';

const VideoPlayer = ({ videoLink }) => {
  return (
    <video className="h-full w-full rounded-lg object-cover" controls autoPlay>
      <source src={videoLink} type="video/mp4" />
      Your browser does not support the video tag.
    </video>
  );
};

export default VideoPlayer;
