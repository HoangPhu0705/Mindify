const express = require('express')
const app = express()
const port = 3000;
const cors = require('cors');
const route = require("./routes");
const bodyParser = require('body-parser');


//use cors and express.json()
app.use(bodyParser.json());
app.use(cors());
app.use(express.json()); 


route(app);




app.listen(port, () =>
    console.log(`App is listening on : http://localhost:${port}`)
);


