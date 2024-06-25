import React from 'react';
import { MdDashboardCustomize, MdOutlineMan, MdOutlineLogin } from "react-icons/md";
// import { MdDashboardCustomize, MdOutlineMan } from "react-icons/md";
import { Link, useLocation } from 'react-router-dom';
import classNames from 'classnames'; 
export default function Sidebar() {
  return (
    <div className='flex flex-col bg-black w-60 p-3 min-h-screen'>
      <div className="flex items-center gap-2 px-1 py-3 text-white">
        <span>Mindify Admin</span>
      </div>
      <div className='flex-1 py-8 flex flex-col gap-0.5'>
        {
          sidebarComponents.map((item, index) => {
            return <Components key={index} item={item} />;
          })
        }
      </div>

      <div className='flex flex-col gap-0.5 pt-2 border-t border-neural-700'>
        <div className={classNames('text-red-400',
        'flex items-center gap-2 font-light px-3 py-2 hover:bg-black hover:no-underline text-white'
        )}>
          <span><MdOutlineLogin/></span>Logout
        </div>
      </div>
    </div>
  );
}

function Components({ item }) {
  const location = useLocation();
  const isActive = location.pathname === item.path;

  return (
    <Link to={item.path} className={
      classNames(
        isActive? 'bg-neural-700 text-white' : 'text-neural-400',
        'flex items-center gap-2 font-light px-3 py-2 hover:bg-black hover:no-underline text-white'
      )
    }>
      <span className='text-xl'>{item.icon}</span>
      {item.label}
    </Link>
  );
}


const sidebarComponents = [
  {
    label: 'Dashboard',
    path: '/',
    icon: <MdDashboardCustomize />
  },
  {
    label: 'Lecturer',
    path: '/lecturer',
    icon: <MdOutlineMan />
  },
  {
    label: 'Request',
    path: '/request',
    icon: <MdOutlineMan />
  }
];

