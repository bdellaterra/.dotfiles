import { resolve } from 'path'

export default {
  module: {
    rules: [
      {
        enforce: 'pre',
        test: /\.(jsx?|tsx?)$/,
        exclude: resolve('node_modules'),
        loader: 'eslint-loader',
        options: {
          fix: true
        }
      }
    ]
  }
}
