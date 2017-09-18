import { resolve } from 'path'

export default {
  module: {
    loaders: [
      {
        test:    /\.css$/,
        include: resolve('src'),
        use:     ['style-loader', 'css-loader']
      }
    ]
  }
}

