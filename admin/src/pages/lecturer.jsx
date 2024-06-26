import { MagnifyingGlassIcon } from "@heroicons/react/24/outline";
import { PencilIcon, UserPlusIcon } from "@heroicons/react/24/solid";
import {
  Card,
  CardHeader,
  Input,
  Typography,
  Button,
  CardBody,
  Chip,
  CardFooter,
  Tabs,
  TabsHeader,
  Tab,
  Avatar,
  IconButton,
  Tooltip,
} from "@material-tailwind/react";
 
const TABS = [
  {
    label: "All",
    value: "all",
  },
  {
    label: "Monitored",
    value: "monitored",
  },
  {
    label: "Unmonitored",
    value: "unmonitored",
  },
];
 
const TABLE_HEAD = ["Member", "Role", "Sign up date", ""];
 
const TABLE_ROWS = [
  {
    img: "https://demos.creative-tim.com/test/corporate-ui-dashboard/assets/img/team-3.jpg",
    name: "John Michael",
    email: "john@creative-tim.com",
    role: "Member",
    
    date: "23/04/18",
  },
  {
    img: "https://demos.creative-tim.com/test/corporate-ui-dashboard/assets/img/team-2.jpg",
    name: "Alexa Liras",
    email: "alexa@creative-tim.com",
    role: "Lecturer",
    
    date: "23/04/18",
  },
  {
    img: "https://demos.creative-tim.com/test/corporate-ui-dashboard/assets/img/team-1.jpg",
    name: "Laurent Perrier",
    email: "laurent@creative-tim.com",
    role: "Lecturer",
    date: "19/09/17",
  },
  {
    img: "https://demos.creative-tim.com/test/corporate-ui-dashboard/assets/img/team-4.jpg",
    name: "Michael Levi",
    email: "michael@creative-tim.com",
    role: "Member",
    
    date: "24/12/08",
  },
  {
    img: "https://demos.creative-tim.com/test/corporate-ui-dashboard/assets/img/team-5.jpg",
    name: "Richard Gran",
    email: "richard@creative-tim.com",
    role: "Member",
    date: "04/10/21",
  },
];
 
export default function Lecturer() {
  return (
    <Card className="h-full w-full">
      <CardHeader floated={false} shadow={false} className="rounded-none">
        <div className="mb-8 flex items-center justify-between gap-8">
          <div> 
            <Typography variant="h5" color="blue-gray">
              Members list
            </Typography>
            <Typography color="gray" className="mt-1 font-normal">
              See information about all members
            </Typography>
          </div>
         
        </div>
        <div className="flex flex-col items-center justify-between gap-4 md:flex-row">
          <Tabs value="all" className="w-full md:w-max">
            <TabsHeader>
              {TABS.map(({ label, value }) => (
                <Tab key={value} value={value}>
                  &nbsp;&nbsp;{label}&nbsp;&nbsp;
                </Tab>
              ))}
            </TabsHeader>
          </Tabs>
          <div className="w-full md:w-72">
            <Input
              label="Search"
              icon={<MagnifyingGlassIcon className="h-5 w-5" />}
            />
          </div>
        </div>
      </CardHeader>
      <CardBody className="overflow-scroll px-0">
        <table className="mt-4 w-full min-w-max table-auto text-left">
          <thead>
            <tr>
              {TABLE_HEAD.map((head) => (
                <th
                  key={head}
                  className="border-y border-blue-gray-100 bg-blue-gray-50/50 p-4"
                >
                  <Typography
                    variant="small"
                    color="blue-gray"
                    className="font-normal leading-none opacity-70"
                  >
                    {head}
                  </Typography>
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {TABLE_ROWS.map(
              ({ img, name, email, role, date }, index) => {
                const isLast = index === TABLE_ROWS.length - 1;
                const classes = isLast
                  ? "p-4"
                  : "p-4 border-b border-blue-gray-50";
 
                return (
                  <tr key={name}>
                    <td className={classes}>
                      <div className="flex items-center gap-3">
                        <Avatar src={img} alt={name} size="sm" />
                        <div className="flex flex-col">
                          <Typography
                            variant="small"
                            color="blue-gray"
                            className="font-normal"
                          >
                            {name}
                          </Typography>
                          <Typography
                            variant="small"
                            color="blue-gray"
                            className="font-normal opacity-70"
                          >
                            {email}
                          </Typography>
                        </div>
                      </div>
                    </td>
                    <td className={classes}>
                      <div className="flex flex-col">
                        <Typography
                          variant="small"
                          color="blue-gray"
                          className="font-normal"
                        >
                          {role}
                        </Typography>
                      </div>
                    </td>
                    
                    <td className={classes}>
                      <Typography
                        variant="small"
                        color="blue-gray"
                        className="font-normal"
                      >
                        {date}
                      </Typography>
                    </td>
                    <td className={classes}>
                      <Tooltip content="See detail">
                        <IconButton variant="text">
                          <PencilIcon className="h-4 w-4" />
                        </IconButton>
                      </Tooltip>
                    </td>
                  </tr>
                );
              },
            )}
          </tbody>
        </table>
      </CardBody>
      <CardFooter className="flex items-center justify-between border-t border-blue-gray-50 p-4">
        <Typography variant="small" color="blue-gray" className="font-normal">
          Page 1 of 10
        </Typography>
        <div className="flex gap-2">
          <Button variant="outlined" size="sm">
            Previous
          </Button>
          <Button variant="outlined" size="sm">
            Next
          </Button>
        </div>
      </CardFooter>
    </Card>
  );
}



// import React from 'react'
// const productData = [
//   {
//     image: 'ProductOne',
//     name: 'Apple Watch Series 7',
//     category: 'Electronics',
//     price: 296,
//     sold: 22,
//     profit: 45,
//   },
//   {
//     image: 'ProductTwo',
//     name: 'Macbook Pro M1',
//     category: 'Electronics',
//     price: 546,
//     sold: 12,
//     profit: 125,
//   },
//   {
//     image: 'ProductThree',
//     name: 'Dell Inspiron 15',
//     category: 'Electronics',
//     price: 443,
//     sold: 64,
//     profit: 247,
//   },
//   {
//     image: 'ProductFour',
//     name: 'HP Probook 450',
//     category: 'Electronics',
//     price: 499,
//     sold: 72,
//     profit: 103,
//   },
// ];
// export default function Lecturer() {
//   return (
//     <div className="rounded-lg border border-stroke bg-white shadow-lg dark:border-strokedark dark:bg-boxdark">
//       <div className="py-6 px-4 md:px-6 xl:px-7.5 bg-gray-100 dark:bg-gray-800">
//         <h4 className="text-xl font-semibold text-black dark:text-white">
//           Top Products
//         </h4>
//       </div>

//       <table className="w-full border-collapse">
//         <thead className="bg-gray-50 dark:bg-gray-900">
//           <tr>
//             <th className="px-4 py-3 text-left text-sm font-medium text-black dark:text-white">Product Name</th>
//             <th className="px-4 py-3 text-left text-sm font-medium text-black dark:text-white hidden sm:table-cell">Category</th>
//             <th className="px-4 py-3 text-left text-sm font-medium text-black dark:text-white">Price</th>
//             <th className="px-4 py-3 text-left text-sm font-medium text-black dark:text-white">Sold</th>
//             <th className="px-4 py-3 text-left text-sm font-medium text-black dark:text-white">Profit</th>
//           </tr>
//         </thead>
//         <tbody>
//           {productData.map((product, key) => (
//             <tr
//               key={key}
//               className="hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors border-t border-stroke dark:border-strokedark"
//             >
//               <td className="px-4 py-3 flex items-center">
//                 <div className="flex flex-col gap-4 sm:flex-row sm:items-center">
//                   <div className="h-12.5 w-15 rounded-md overflow-hidden">
//                     <img
//                       src={product.image}
//                       alt="Product"
//                       className="object-cover h-full w-full"
//                     />
//                   </div>
//                   <p className="text-sm text-black dark:text-white">{product.name}</p>
//                 </div>
//               </td>
//               <td className="px-4 py-3 text-sm text-black dark:text-white hidden sm:table-cell">{product.category}</td>
//               <td className="px-4 py-3 text-sm text-black dark:text-white">${product.price}</td>
//               <td className="px-4 py-3 text-sm text-black dark:text-white">{product.sold}</td>
//               <td className="px-4 py-3 text-sm text-meta-3 dark:text-meta-3">${product.profit}</td>
//             </tr>
//           ))}
//         </tbody>
//       </table>
//     </div>
//   );
// }
// import { Product } from '../../types/product';
// import ProductOne from '../../images/product/product-01.png';
// import ProductTwo from '../../images/product/product-02.png';
// import ProductThree from '../../images/product/product-03.png';
// import ProductFour from '../../images/product/product-04.png';

