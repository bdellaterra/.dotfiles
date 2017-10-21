require('marko/node-require').install();

var Koa = require('koa');

var app = new Koa();

app.use(require('./src/pages/home'));

var port = 8080;

app.listen(8080, function() {

    console.log('Server started! Try it out:\nhttp://localhost:' + port + '/');

    if (process.send) {
        process.send('online');
    }
});
