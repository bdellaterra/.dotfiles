import webpack from 'webpack'
import { resolve } from 'path'
import merge from 'webpack-merge'

import modules from './conf/webpack'

const DefinePlugin = new webpack.DefinePlugin({
  'PRODUCTION': JSON.stringify(false),
  'VERSION':    JSON.stringify('0.1'),
  'DEBUG':      JSON.stringify(true)
})

const baseConfig = {
  'entry':  resolve('src', 'js'),
  'output': {
    'path':     resolve('dist'),
    'filename': 'bundle.js'
  },
  'plugins': [
    DefinePlugin
  ]
}

export default merge(baseConfig, modules)
