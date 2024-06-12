import React from 'react'
import { MdShoppingBag } from "react-icons/md";
import DashboardStatsGrid from './statsgrid';

export default function Dashboard() {
  return (
    <div className='flex flex-col gap-4'>
      <DashboardStatsGrid/>

    </div>
  )
}

