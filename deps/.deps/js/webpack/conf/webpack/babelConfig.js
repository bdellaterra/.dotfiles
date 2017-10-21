import { resolve } from 'path'

export default {
  module: {
    loaders: [
      {
        test:    /\.jsx?$/,
        include: resolve('src'),
        loader:  'babel-loader'
      }
    ]
  }
}

