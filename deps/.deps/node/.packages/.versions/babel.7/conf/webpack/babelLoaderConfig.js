import { resolve } from 'path'

export default {
  module: {
    rules: [
      {
        test: /\.(jsx?|tsx?)$/,
        exclude: resolve('node_modules'),
        use: {
          loader: "babel-loader",
        }
      }
    ]
  }
}

