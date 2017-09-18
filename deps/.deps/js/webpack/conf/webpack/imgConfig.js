import { resolve } from 'path'

export default {
  module: {
    loaders: [
      {
        test: /\.jpe?g$|\.gif$|\.png$|\.svg$|\.woff$|\.ttf$|\.wav$|\.mp3$/,
        loader:  'file-loader',
        options: {
          name: './images/[name].[hash].[ext]'
        }
      }
    ]
  }
}

