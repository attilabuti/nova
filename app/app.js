const fs = require('fs');
const http = require('http');
const path = require('path');
const spawn = require('child_process').spawnSync;

const port = 3000;

String.prototype.fmt = function(hash) {
    let string = this;

    for (key in hash) {
        string = string.replace(new RegExp('\\{{' + key + '\\}}', 'gm'), hash[key]);
    }

    return string;
}

http.createServer((req, res) => {
    fs.readFile(path.join(__dirname, 'app.html'), 'utf8', (err, data) => {
        data = data.toString().fmt({
            nodeVersion: spawn('node', ['-v']).stdout.toString().replace('v', ''),
            nginxVersion: spawn('nginx', ['-v']).stderr.toString().replace('nginx version: nginx/', ''),
            pm2Version: spawn('pm2', ['-v']).stdout.toString(),

            maildevVersion: spawn('maildev', ['--version']).stdout.toString(),
            maildevRunning: ((spawn('pm2', ['show', 'maildev']).stdout.toString().indexOf('online') > -1) ? 'check' : 'times'),

            mongoVersion: spawn('mongod', ['--version', '| grep "db version"']).stdout.toString().match(/\d+(\.\d+)+/)[0],
            mongoRunning: ((spawn('service', ['mongod', 'status']).stdout.toString().indexOf('start/running') > -1) ? 'check' : 'times'),

            host: req.headers.host
        });

        res.writeHead(200, { 'Content-Type': 'text/html', 'Content-Length': data.length });
        res.write(data);
        res.end();
    });
}).listen(port);