// import React from 'react'
// import { MdOutlineSearch } from "react-icons/md";
// export default function Header() {
//   return (
//     <div className='bg-white h-16 px-4 flex justify-between items-center border-p border-gray-200'>
//         <div className='relative'>
//             <MdOutlineSearch fontSize={20} className="text-gray-400 absolute top-1/2 -translate-y-1/2 left-4"/>
//             <input type="text" placeholder='Search...' name="" id=""
//             className='text-sm focus:outline-none active:outline-none h-12 w-[24rem] border border-gray-300 rounded-sm pl-11 pr-4'/>
//         </div>
//         <div></div>
//     </div>
//   )
// }

import {
  Navbar,
  Typography,
  IconButton,
  Button,
  Input,
} from "@material-tailwind/react";
import { BellIcon, Cog6ToothIcon } from "@heroicons/react/24/solid";

export default function Header() {
  return (
    <Navbar
      fullWidth={true}
      className="w-full bg-white px-4 py-3 "
    >
      <div className="flex flex-wrap items-center justify-between gap-y-4 text-white">
        
        <div className="ml-auto flex gap-1 md:mr-4">
          
          <IconButton variant="text">
            <BellIcon className="h-5 w-5 fill-[#062137]" />
          </IconButton>
        </div>
        <div className="relative flex w-full gap-2 md:w-max">
          <Input
            type="search"
            color="black"
            label="Type here..."
            className="pr-20 border-[#062137]"
            containerProps={{
              className: "min-w-[288px]",
            }}

          />
          <Button
            size="sm"

            className="!absolute right-1 top-1 rounded bg-[#062137]"
          >
            Search
          </Button>
        </div>
      </div>
    </Navbar>
  );
}
