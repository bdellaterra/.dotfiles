import { resolve } from 'path'

export default {
  'module': {
    'loaders': [
      {
        'test':    /\.css$/,
        'include': resolve('src', 'css'),
        'use':     ['style-loader', 'css-loader']
      }
    ]
  }
}

