var fcgi = require('node-fastcgi');

fcgi.createServer(
    function(req, res) {
        res.writeHead(200, { 'Content-Type': 'text/html' });
        res.end("<!DOCTYPE html><html><body><h1>Hello World!</h1></body></html>");
    },
    null,
    null,
    {
        maxConns: 2000,
        maxReqs: 2000,
    }
).listen(process.argv[2]);
