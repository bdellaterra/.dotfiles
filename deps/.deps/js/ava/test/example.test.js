var test = require(process.env.JS_TEST_LIB).test


test('not having tests is a big FAIL', t => {
    t.fail()
})

