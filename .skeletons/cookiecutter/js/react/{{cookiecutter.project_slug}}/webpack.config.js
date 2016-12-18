var debug = process.env.NODE_ENV !== "production"
var webpack = require('webpack')
var path = require('path')
var ExtractTextPlugin = require('extract-text-webpack-plugin')
var HtmlWebpackPlugin = require('html-webpack-plugin')

module.exports = {
  devtool: debug ? "source-map" : null,
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
      },
      {
        test: /\.css$/,
        include: path.resolve(__dirname, 'src'),
        loader: ExtractTextPlugin.extract('style-loader', 'css-loader?modules&importLoaders=1&localIdentName=[name]__[local]___[hash:base64:5]')
      }
    ]
  },
  plugins: [
    new ExtractTextPlugin('styles.css'),
    new HtmlWebpackPlugin({
      template: path.resolve(__dirname, 'src', 'index.html'),
      filename: 'index.html'
    })
  ],
  devServer: {
    contentBase: path.resolve(__dirname, 'dist'),
    inline: true,
    port: '8080',
    stats: 'errors-only'
  }
}

