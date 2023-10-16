const dotenv = require('dotenv');
const express = require('express');
const fs = require('fs');
const neo4j = require('neo4j-driver');
const path = require('path');

// Configure environment variables
dotenv.config();

// Connect to Neo4j (database first approach)
(async () => {
    const URI = process.env.URI;
    const NEO4J_USER = process.env.NEO4J_USER;
    const PASSWORD = process.env.PASSWORD;
    let driver = neo4j.driver(URI, neo4j.auth.basic(NEO4J_USER, PASSWORD));

    try {
        const serverInfo = await driver.getServerInfo();
        console.log('Connection established');
        console.log(serverInfo);

        // Server
        const app = express();
        const port = process.env.PORT || 3000;

        // Routes
        const assetsUrl = path.join(__dirname, 'public');
        app.use('/view', express.static(assetsUrl));

        app.get('/getColors', async (req, res) => {
            const { records } = await driver.executeQuery(
                `MATCH (r:Region)
                RETURN r.id AS id, r.region_name AS Region, r.color AS Color`
            );
            
            resDict = {}
            for(record of records) {
                console.log(record.get('id'), '-',
                    record.get('Region'), '-',
                    record.get('Color').toNumber());
                
                resDict[record.get('id')] = {
                    'region': record.get('Region'),
                    'color': record.get('Color').toNumber()
                };
            }

            res.status(200).send(resDict);
        });

        app.get('*', (req, res) => {
            console.log(driver);
            const url = path.join(__dirname, 'public', 'coloring.html');
            res.status(200).sendFile(url);
        });

        app.listen(port, () => {
            console.log(`App is running on port ${port}`);
        });
    } catch(err) {
        console.log(`Connection error\n${err}\nCause: ${err.cause}`);
    }
})();
