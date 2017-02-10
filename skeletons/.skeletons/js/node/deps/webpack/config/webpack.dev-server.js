const webpack = require('webpack');

exports.devServer = function(options) {
  return {
    devServer: {
      // Enable HTML5 History API based routing.
      historyApiFallback: true,

      // Don't refresh if hot loading fails.
      hotOnly: true,

      // Display only errors to reduce the amount of output.
      stats: 'errors-only',

      // Parse host and port from env to allow customization.
      host: process.env.HOST, // Defaults to `localhost`
      port: process.env.PORT, // Defaults to 8080
    },
    plugins: [
      // Enable multi-pass compilation for enhanced performance.
      new webpack.HotModuleReplacementPlugin({
        // Disabled as this won't work with html-webpack-template
        //multiStep: true
      }),
    ],
  };
};

