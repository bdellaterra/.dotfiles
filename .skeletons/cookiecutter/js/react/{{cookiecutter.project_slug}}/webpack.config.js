var debug = process.env.NODE_ENV !== "production"
var webpack = require('webpack')
var path = require('path')

module.exports = {
  devtool: debug ? "inline-sourcemap" : null,
  context: path.resolve(__dirname, 'src'),
  entry: {
    bundle: './js/main.js',
  },
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'bundle.js',
    publicPath: '/'
  },
  module: {
    loaders: [
      {
        test: /\.jsx?$/,
        include: path.resolve(__dirname, 'src'),
        loader: 'babel',
        query: {
          presets: ['es2015', 'react'],
        }
      },
      {
        test: /\.jpe?g$|\.gif$|\.png$|\.svg$|\.woff$|\.ttf$|\.wav$|\.mp3$/,
        loader: "file"
      }
    ]
  },
  devServer: {
    contentBase: path.resolve(__dirname, 'dist'),
    inline: true,
    port: '8080',
    stats: 'errors-only'
  }
}

