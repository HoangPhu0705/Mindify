const express = require('express');
const app = express();
const cors = require('cors');
const route = require("./routes");
const bodyParser = require('body-parser');

// use cors and express.json()
app.use(bodyParser.json());
app.use(cors());
app.use(express.json()); 

route(app);

module.exports = app;
