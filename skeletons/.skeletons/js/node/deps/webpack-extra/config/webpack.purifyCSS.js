const webpack = require('webpack');

const PurifyCSSPlugin = require('purifycss-webpack');

exports.purifyCSS = function(paths) {
  return {
    plugins: [
      new PurifyCSSPlugin({ paths: paths }),
    ],
  };
};

