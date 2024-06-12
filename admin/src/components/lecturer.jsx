import React from 'react'
const productData = [
  {
    image: 'ProductOne',
    name: 'Apple Watch Series 7',
    category: 'Electronics',
    price: 296,
    sold: 22,
    profit: 45,
  },
  {
    image: 'ProductTwo',
    name: 'Macbook Pro M1',
    category: 'Electronics',
    price: 546,
    sold: 12,
    profit: 125,
  },
  {
    image: 'ProductThree',
    name: 'Dell Inspiron 15',
    category: 'Electronics',
    price: 443,
    sold: 64,
    profit: 247,
  },
  {
    image: 'ProductFour',
    name: 'HP Probook 450',
    category: 'Electronics',
    price: 499,
    sold: 72,
    profit: 103,
  },
];
export default function Lecturer() {
  return (
    <div className="rounded-lg border border-stroke bg-white shadow-lg dark:border-strokedark dark:bg-boxdark">
      <div className="py-6 px-4 md:px-6 xl:px-7.5 bg-gray-100 dark:bg-gray-800">
        <h4 className="text-xl font-semibold text-black dark:text-white">
          Top Products
        </h4>
      </div>

      <table className="w-full border-collapse">
        <thead className="bg-gray-50 dark:bg-gray-900">
          <tr>
            <th className="px-4 py-3 text-left text-sm font-medium text-black dark:text-white">Product Name</th>
            <th className="px-4 py-3 text-left text-sm font-medium text-black dark:text-white hidden sm:table-cell">Category</th>
            <th className="px-4 py-3 text-left text-sm font-medium text-black dark:text-white">Price</th>
            <th className="px-4 py-3 text-left text-sm font-medium text-black dark:text-white">Sold</th>
            <th className="px-4 py-3 text-left text-sm font-medium text-black dark:text-white">Profit</th>
          </tr>
        </thead>
        <tbody>
          {productData.map((product, key) => (
            <tr
              key={key}
              className="hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors border-t border-stroke dark:border-strokedark"
            >
              <td className="px-4 py-3 flex items-center">
                <div className="flex flex-col gap-4 sm:flex-row sm:items-center">
                  <div className="h-12.5 w-15 rounded-md overflow-hidden">
                    <img
                      src={product.image}
                      alt="Product"
                      className="object-cover h-full w-full"
                    />
                  </div>
                  <p className="text-sm text-black dark:text-white">{product.name}</p>
                </div>
              </td>
              <td className="px-4 py-3 text-sm text-black dark:text-white hidden sm:table-cell">{product.category}</td>
              <td className="px-4 py-3 text-sm text-black dark:text-white">${product.price}</td>
              <td className="px-4 py-3 text-sm text-black dark:text-white">{product.sold}</td>
              <td className="px-4 py-3 text-sm text-meta-3 dark:text-meta-3">${product.profit}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
// import { Product } from '../../types/product';
// import ProductOne from '../../images/product/product-01.png';
// import ProductTwo from '../../images/product/product-02.png';
// import ProductThree from '../../images/product/product-03.png';
// import ProductFour from '../../images/product/product-04.png';

