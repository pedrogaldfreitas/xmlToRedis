const fs = require('fs');
const redis = require('redis');
const xml2js = require('xml2js');

const filePath = process.argv[2]; 
console.log("File path received:", filePath);

if (!filePath) {
    console.error("Error: No XML file path provided");
    process.exit(1);
}

if (!fs.existsSync(filePath)) {
    console.error(`Error: The file ${filePath} does not exist inside the container`);
    process.exit(1);
}

/* In this assignment, I am working under the assumption that 
   only config.xml needs a working implementation, and not xml files
   with different element names (e.g, <diffelement></diffelement>, etc.)
*/
xmlToRedis();

async function xmlToRedis() {

    const client = redis.createClient({
        socket: {
            host: "redis",
            port: 6379
        }
    });

    client.on("error", err => console.error("Redis error:", err));
    client.on("connect", () => {console.log("Connected to redis!")});
    
    await client.connect();
    
    
    // 1. Reading and parsing the XML file to JSON format for ease of use
    const xmlFile = fs.readFileSync(filePath, 'utf8');
    
    xml2js.parseString(xmlFile, (err, result) => {
        if (err) {
            console.error("Error parsing XML:", err);
            return;
        }
        
        // 2. Set subdomains in Redis
        let subdomains = JSON.stringify(result.config.subdomains[0].subdomain);
        client.set("subdomains", subdomains);
        console.log("Subdomains:", subdomains);
        
        // 3. Set cookies in redis
        result.config.cookies[0].cookie.map((cookie) => {
            let key = `cookie:${cookie.$.name}:${cookie.$.host}`;
            let value = cookie._;

            client.set(key, value);
        });
    })

    await client.quit();
    return;
}
