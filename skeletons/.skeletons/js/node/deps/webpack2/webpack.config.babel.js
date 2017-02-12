import webpack from 'webpack'
import {resolve} from 'path'
import merge from 'webpack-merge'

import htmlConfig from './conf/webpack/htmlConfig'
import imgConfig from './conf/webpack/imgConfig'
import devServerConfig from './conf/webpack/devServerConfig'

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

export default merge(
  baseConfig,
  htmlConfig,
  imgConfig,
)

