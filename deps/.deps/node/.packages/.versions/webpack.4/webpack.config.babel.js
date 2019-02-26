import webpack from 'webpack'
import merge from 'webpack-merge'
import { resolve } from 'path'

import modules from './conf/webpack'

const baseConfig = {
  entry: [
    resolve('src')
  ],
  output: {
    path: resolve('dist'),
    filename: 'bundle.js'
  },
  resolve: {
    modules: [
      resolve('src'),
      resolve('node_modules')
    ],
    extensions: [
      '.js',
      '.jsx',
      '.ts',
      '.tsx',
      '.json',
      '.css',
    ],
    mainFiles: ['index']
  },
  ...modules
}

export default merge(baseConfig, modules)
