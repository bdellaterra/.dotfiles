import { resolve } from 'path'

export default {
  module: {
    rules: [
      {
        enforce: 'post',
        test: /\.(jsx?|tsx?)$/,
        exclude: resolve('node_modules'),
        loader: "babel-loader"
      }
    ]
  }
}

