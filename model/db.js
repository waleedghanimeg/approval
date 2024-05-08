import oraDb from "oracledb";

let clientOption = { libDir: 'node_modules\\instantclient' };

oraDb.initOracleClient(clientOption);

let dbConn;

 dbConn = await oraDb.getConnection({ user: "devdba", password: "devdba", connectString: "obiserver:1523/test" });

export default dbConn ;