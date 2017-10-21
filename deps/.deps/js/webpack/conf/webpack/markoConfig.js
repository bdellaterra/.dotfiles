import { resolve } from 'path'

export default {
  module: {
    loaders: [
      {
        test: /\.marko$/,
        include: resolve('src'),
        loader: 'marko-loader'
      }
    ]
  }
}


