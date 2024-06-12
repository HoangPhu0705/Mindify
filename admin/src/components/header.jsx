import React from 'react'
import { MdOutlineSearch } from "react-icons/md";
export default function Header() {
  return (
    <div className='bg-white h-16 px-4 flex justify-between items-center border-p border-gray-200'>
        <div className='relative'>
            <MdOutlineSearch fontSize={20} className="text-gray-400 absolute top-1/2 -translate-y-1/2 left-4"/>
            <input type="text" placeholder='Search...' name="" id="" 
            className='text-sm focus:outline-none active:outline-none h-12 w-[24rem] border border-gray-300 rounded-sm pl-11 pr-4'/>
        </div>
        <div></div>
    </div>
  )
}
