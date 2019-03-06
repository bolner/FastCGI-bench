var fcgi = require('node-fastcgi');

fcgi.createServer(
    function(req, res) {
        res.writeHead(200, { 'Content-Type': 'text/plain' });
        res.end("It's working");

        /*setTimeout(function() {
            res.writeHead(200, { 'Content-Type': 'text/plain' });
            res.end("It's working");
        }, 20);*/
    },
    null,
    null,
    {
        maxConns: 2000,
        maxReqs: 2000,
    }
).listen(process.argv[2]);
