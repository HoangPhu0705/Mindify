import React, { useState } from "react";
import axios from "axios";
import { useNavigate } from "react-router-dom";

// @components
import {
  Card,
  Input,
  Button,
  CardBody,
  CardHeader,
  Typography,
} from "@material-tailwind/react";

function Login1() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [errorMessage, setErrorMessage] = useState(""); // state error
  const navigate = useNavigate();

  const handleLogin = async (e) => {
    e.preventDefault();

    try {
      const response = await axios.post(
        "http://localhost:3000/admin/admin-login",

        { email, password }
      );
      localStorage.setItem("token", response.data.token);
      navigate("/");
    } catch (error) {
      console.error("Error logging in: ", error);
      setErrorMessage("Invalid email or password. Please try again.");
    }
  };

  return (
    <section className="px-8">
      <div className="container mx-auto h-screen grid place-items-center">
        <Card
          shadow={false}
          className="md:px-24 md:py-14 py-8 border border-gray-300"
        >
          <CardHeader shadow={false} floated={false} className="text-center">
            <div className="mb-2 p-4">
              <Typography className="text-[#7DD6FF] text-3xl font-bold text-center">
                Mindify for Admin.
              </Typography>
            </div>
            <Typography className="!text-gray-600 text-[18px] font-normal md:max-w-sm">
              Simplify the management of your teaching resources and courses.
            </Typography>
          </CardHeader>
          <CardBody>
            <form
              onSubmit={handleLogin}
              className="flex flex-col gap-4 md:mt-12"
            >

              <div>
                <label htmlFor="email">
                  <Typography
                    variant="small"
                    color="blue-gray"
                    className="block font-medium mb-2"
                  >
                    Your Email
                  </Typography>
                </label>
                <Input
                  id="email"
                  color="gray"
                  size="lg"
                  type="email"
                  name="email"
                  placeholder="name@mail.com"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)} 
                  className="w-full placeholder:opacity-100 focus:border-t-primary border-t-blue-gray-200"
                  labelProps={{
                    className: "before:mr-0 after:ml-0",
                  }}
                />

              </div>
              <div>
                <label htmlFor="password">
                  <Typography
                    variant="small"
                    color="blue-gray"
                    className="block font-medium mb-2"
                  >
                    Your Password
                  </Typography>
                </label>
                <Input
                  id="password"
                  color="gray"
                  size="lg"
                  type="password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="Password"
                  className="w-full placeholder:opacity-100 focus:border-t-primary border-t-blue-gray-200"
                  labelProps={{
                    className: "before:mr-0 after:ml-0",
                  }}
                />
                {errorMessage && (
                  <Typography
                    variant="small"
                    color="red"
                    className="text-center mt-4"
                  >
                    {errorMessage}
                  </Typography>
                )}
              </div>
              <Button size="lg" color="gray" fullWidth type="submit">
                continue
              </Button>

              <Typography
                variant="small"
                className="text-center mx-auto max-w-[19rem]  !text-black font-bold"
              >
                © 2024 Mindify. All rights reserved.
              </Typography>
            </form>
          </CardBody>
        </Card>
      </div>
    </section>
  );
}

export default Login1;
