var test = require(process.env.JS_TEST_LIB).test

test('my passing test', t => {
    t.pass()
    t.end()
})

