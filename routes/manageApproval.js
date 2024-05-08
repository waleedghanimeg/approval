import express from "express";
import oraDb from "oracledb";
import dbConn from "../model/db.js";
import fs from "fs/promises";

const router = express.Router();

router.get("/master", async (req, res) => {
    let sqlStr
    try {
        sqlStr = await fs.readFile('D:/Workspace/git/Approval/model/sql/approval_header.sql', { encoding: 'utf8' })
    } catch (err) {
        console.log(err);
    }
    let result
    try {
        result = await dbConn.execute(sqlStr, {
            P_POSTED_OFFSET: null,
            P_SENT_OFFSET: null,
            P_fROM_DATE: new Date(req.query.p_from_date),
            P_TO_DATE: new Date(req.query.p_to_date),
            P_STATUS: null,
            p_authorised_flag: null,
            P_Right_filter: null,
            pIsFacility: null,
            pCurrentFacility: null,
            pFACILITY_ID: null
        }, { outFormat: oraDb.OUT_FORMAT_OBJECT });
        res.json(result.rows);
    } catch (error) {
        res.send('Error ' + error)
    }
})

export default router;




