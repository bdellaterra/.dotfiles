import { resolve } from 'path'

export default {
  module: {
    loaders: [
      {
        test:    /\.css$/,
        include: resolve('src', 'styles'),
        use:     ['style-loader', 'css-loader']
      }
    ]
  }
}

