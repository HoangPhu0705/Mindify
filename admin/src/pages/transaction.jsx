import React, { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import axios from "axios";
import {
    Card,
    CardBody,
    CardHeader,
    Typography,
    Button,
    Spinner,
    Input,
    Select,
    Option,
} from "@material-tailwind/react";

function BillingCard({ id, amount, currency, confirmedAt, userData }) {
    return (
        <Card shadow={false} className="rounded-lg border border-gray-300 p-4">
            <div className="mb-4 flex items-start justify-between">
                <div className="flex items-center gap-3">
                    <div className="border border-gray-200 rounded-lg w-20 h-10">
                        <img src="src/assets/stripe.png" alt="Stripe Logo" />
                    </div>
                    <div>
                        <Typography variant="small" color="blue-gray" className="mb-1 font-bold">
                            {new Intl.NumberFormat('de-DE').format(amount)} {currency}
                        </Typography>
                        <Typography className="!text-gray-600 text-xs font-normal">
                            {confirmedAt
                                ? new Date(confirmedAt._seconds * 1000).toLocaleDateString('en-GB')
                                : "N/A"}
                        </Typography>
                    </div>
                </div>
            </div>
            <div>
                {userData && (
                    <div className="flex flex-col">
                        <div className="flex gap-1">
                            <Typography className="mb-1 text-xs !font-medium !text-gray-600">
                                VAT number:
                            </Typography>
                            <Typography className="text-xs !font-bold" color="blue-gray">
                                {id}
                            </Typography>
                        </div>
                        {Object.keys(userData).map((label) => (
                            <div key={label} className="flex gap-1">
                                <Typography className="mb-1 text-xs !font-medium !text-gray-600">
                                    {label}:
                                </Typography>
                                <Typography className="text-xs !font-bold" color="blue-gray">
                                    {userData[label]}
                                </Typography>
                            </div>
                        ))}
                    </div>
                )}
            </div>
        </Card>
    );
}

const TransactionManagement = () => {
    const [transactions, setTransactions] = useState([]);
    const [transactionPage, setTransactionPage] = useState({ limit: 10, startAfter: null });
    const [currentPage, setCurrentPage] = useState(1);
    const [totalPages, setTotalPages] = useState(1);
    const [loading, setLoading] = useState(false);
    const [searchQuery, setSearchQuery] = useState("");

    const navigate = useNavigate();

    useEffect(() => {
        fetchTransactions();
    }, [transactionPage, currentPage]);

    const fetchTransactions = async () => {
        console.log("fetching transactions");
        setLoading(true);
        try {
            const token = localStorage.getItem("token");

            const response = await axios.get("/admin/transactions-management", {
                params: {
                    limit: transactionPage.limit,
                    startAfter: transactionPage.startAfter,
                    searchQuery: searchQuery,
                },
                headers: {
                    Authorization: `Bearer ${token}`,
                },
            });
            const { transactions, totalCount } = response.data;
            setTransactions(transactions);
            setTotalPages(Math.ceil(totalCount / transactionPage.limit));
        } catch (error) {
            console.error("Error fetching transactions: ", error);
        } finally {
            setLoading(false);
        }
    };

    const handlePageChange = (newPage) => {
        const startAfter = transactions[transactionPage.limit - 1]?.id || null;
        setCurrentPage(newPage);
        setTransactionPage({ ...transactionPage, startAfter });
    };

    const handleLimitChange = (value) => {
        setTransactionPage({ ...transactionPage, limit: Number(value), startAfter: null });
        setCurrentPage(1);
    };

    const handleSearch = () => {
        setCurrentPage(1);
        setTransactionPage({ ...transactionPage, startAfter: null });
        fetchTransactions();
    };

    return (
        <section className="max-w-4xl !mx-auto py-20 w-full">
            <Card shadow={false}>
                <CardHeader
                    floated={false}
                    shadow={false}
                    className="rounded-none flex gap-2 flex-col md:flex-row items-start !justify-between"
                >
                    <div className="w-full mb-2 flex flex-col">
                        <Typography className="!font-bold" color="blue-gray">
                            Transaction Management
                        </Typography>
                        <Typography
                            className="mt-1 !font-normal !text-gray-600"
                            variant="small"
                        >
                            View transactions quickly and easily.
                        </Typography>
                        <div className="flex flex-row space-x-72">
                            <div className="flex items-center">
                                <Input
                                    type="text"
                                    color="blue-gray"
                                    label="Search Transaction"
                                    value={searchQuery}
                                    onChange={(e) => setSearchQuery(e.target.value)}
                                />
                                <Button
                                    className="ml-4"
                                    onClick={handleSearch}
                                >
                                    Search
                                </Button>
                            </div>

                            <div className="flex items-center mt-2">
                                <Typography variant="h6" color="black" className="mr-2">
                                    Show
                                </Typography>
                                <Select
                                    value={String(transactionPage.limit)}
                                    onChange={(e) => handleLimitChange(e)}
                                >
                                    <Option value="10">10</Option>
                                    <Option value="20">20</Option>
                                    <Option value="50">50</Option>
                                </Select>
                            </div>
                        </div>
                    </div>


                </CardHeader>
                <CardBody className="flex flex-col gap-4 !p-4">
                    {loading ? (
                        <div className="flex justify-center items-center">
                            <Spinner color="blue" />
                        </div>
                    ) : (
                        transactions.map((props, key) => (
                            <BillingCard key={key} {...props} />
                        ))
                    )}
                </CardBody>
            </Card>

            <div className="flex flex-col md:flex-row justify-center items-center mt-4">
                <Button
                    color="black"
                    className="hover:bg-black hover:text-white"
                    variant="outlined"
                    onClick={() => handlePageChange(currentPage - 1)}
                    disabled={currentPage === 1}
                >
                    Previous
                </Button>
                <Typography
                    variant="small"
                    color="blue-gray"
                    className="font-normal mx-2 my-2 md:my-0"
                >
                    Page {currentPage} of {totalPages}
                </Typography>
                <Button
                    color="black"
                    className="hover:bg-black hover:text-white"
                    variant="outlined"
                    onClick={() => handlePageChange(currentPage + 1)}
                    disabled={currentPage === totalPages}
                >
                    Next
                </Button>
            </div>
        </section>
    );
};

export default TransactionManagement;
