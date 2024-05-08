import express from "express";
import cors from "cors"
import oraDb from "oracledb";
import dbConn from "./model/db.js";
import aprvRouter from "./routes/manageApproval.js"

const app = express();
app.use(express.json());
app.use (cors())
aprvRouter.route

app.use('/approval',aprvRouter);

const port = process.env.PORT || 4000;

app.listen(port, console.log("Listining on port " + port))