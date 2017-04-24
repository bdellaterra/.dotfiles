import webpack from 'webpack'
import { resolve } from 'path'
import merge from 'webpack-merge'

import modules from './conf/webpack'

// Define constants.
const production = (process.env.NODE_ENV === 'production')
const debug = !production

const DefinePlugin = new webpack.DefinePlugin({
  PRODUCTION: JSON.stringify(production),
  VERSION:    JSON.stringify('0.1'),
  DEBUG:      JSON.stringify(debug)
})

const baseConfig = {
  entry: [
    'babel-regenerator-runtime',
    resolve('src', 'js')
  ],
  output: {
    path:     resolve('dist'),
    filename: '[chunkhash].[name].js'
  },
  resolve: {
    modules: [
      resolve('src', 'js'),
      resolve('src'),
      resolve('node_modules')
    ]
  },
  plugins: [
    DefinePlugin
  ]
}

// Use source maps if debugging.
if (debug) { baseConfig.devtool = 'source-map' }

// Minify for production
if (production) {
  baseConfig.plugins.push(
    new webpack.optimize.UglifyJsPlugin({
     sourceMap: false,
     compress:  { warnings: false }
    })
  )
}

export default merge(baseConfig, modules)
