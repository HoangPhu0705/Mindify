import {
  Card,
  Typography,
  List,
  ListItem,
  ListItemPrefix,
  ListItemSuffix,
  Chip,
} from "@material-tailwind/react";
import {
  PresentationChartBarIcon,
  ShoppingBagIcon,
  UserCircleIcon,
  Cog6ToothIcon,
  InboxIcon,
  PowerIcon,
  UserGroupIcon,
  PaperAirplaneIcon,
} from "@heroicons/react/24/solid";
import { Link, useLocation } from "react-router-dom";
import React, { useState}from 'react';

export default function Sidebar() {


  return (
      <Card className="h-[calc(100vh-2rem)] w-full max-w-[20rem] p-4 shadow-xl shadow-blue-gray-900/5">
        <div className="mb-2 p-4">
          <Typography  className = "text-[#7DD6FF] text-3xl font-bold text-center">
            Mindify. 
          </Typography>
        </div>
        <List>
          <Link to="/" >
            <ListItem className={`hover:bg-[#062137] hover:text-white  `}>
              <ListItemPrefix>
                <PresentationChartBarIcon className="h-5 w-5"  />
              </ListItemPrefix>
              Dashboard 
            </ListItem>
          </Link>

          <Link to="/lecturer">
            <ListItem className={`hover:bg-[#062137] hover:text-white`}>
              <ListItemPrefix>
                <UserGroupIcon className="h-5 w-5" />
              </ListItemPrefix>
              User Management
            </ListItem>
          </Link>

          <Link to="/request">
            <ListItem className={`hover:bg-[#062137] hover:text-white`}>
              <ListItemPrefix>
                <PaperAirplaneIcon className="h-5 w-5" />
              </ListItemPrefix>
              Requests
            </ListItem>
          </Link>

          <ListItem className={`hover:bg-[#062137] hover:text-white`}>
            <ListItemPrefix>
              <UserCircleIcon className="h-5 w-5" />
            </ListItemPrefix>
            Profile
          </ListItem>
          <ListItem className={`hover:bg-[#062137] hover:text-white`}>
            <ListItemPrefix>
              <Cog6ToothIcon className="h-5 w-5" />
            </ListItemPrefix>
            Settings
          </ListItem>
          <ListItem className={`hover:bg-[#062137] hover:text-white`}>
            <ListItemPrefix>
              <PowerIcon className="h-5 w-5" />
            </ListItemPrefix>
            Log Out
          </ListItem>
        </List>
      </Card>
  );
}


// import React from 'react';
// import { MdDashboardCustomize, MdOutlineMan, MdOutlineLogin } from "react-icons/md";
// // import { MdDashboardCustomize, MdOutlineMan } from "react-icons/md";
// import { Link, useLocation } from 'react-router-dom';
// import classNames from 'classnames';
// export default function Sidebar() {
//   return (
//     <div className='flex flex-col bg-black w-60 p-3 min-h-screen'>
//       <div className="flex items-center gap-2 px-1 py-3 text-white">
//         <span>Mindify Admin</span>
//       </div>
//       <div className='flex-1 py-8 flex flex-col gap-0.5'>
//         {
//           sidebarComponents.map((item, index) => {
//             return <Components key={index} item={item} />;
//           })
//         }
//       </div>

//       <div className='flex flex-col gap-0.5 pt-2 border-t border-neural-700'>
//         <div className={classNames('text-red-400',
//         'flex items-center gap-2 font-light px-3 py-2 hover:bg-black hover:no-underline text-white'
//         )}>
//           <span><MdOutlineLogin/></span>Logout
//         </div>
//       </div>
//     </div>
//   );
// }

// function Components({ item }) {
//   const location = useLocation();
//   const isActive = location.pathname === item.path;

//   return (
//     <Link to={item.path} className={
//       classNames(
//         isActive? 'bg-neural-700 text-white' : 'text-neural-400',
//         'flex items-center gap-2 font-light px-3 py-2 hover:bg-black hover:no-underline text-white'
//       )
//     }>
//       <span className='text-xl'>{item.icon}</span>
//       {item.label}
//     </Link>
//   );
// }

// const sidebarComponents = [
//   {
//     label: 'Dashboard',
//     path: '/',
//     icon: <MdDashboardCustomize />
//   },
//   {
//     label: 'Lecturer',
//     path: '/lecturer',
//     icon: <MdOutlineMan />
//   },
//   {
//     label: 'Requests',
//     path: '/request',
//     icon: <MdOutlineMan />
//   }
// ];