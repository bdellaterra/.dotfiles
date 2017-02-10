const CleanWebpackPlugin = require('clean-webpack-plugin');

exports.cleanBuild = function(path) {
  return {
    plugins: [
      new CleanWebpackPlugin([path]),
    ],
  };
};

