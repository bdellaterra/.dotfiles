var template = require('./template.marko');

module.exports = (ctx, next) => {
    ctx.type = 'html';
    ctx.body = template.stream({});
};
