import { resolve } from 'path'

import CleanWebpackPlugin from 'clean-webpack-plugin'

export default {
  plugins: [
    new CleanWebpackPlugin(
      [resolve('dist'), resolve('build')],
      {
        root:    resolve('.'),
        verbose: true,
        dry:     false
      }
    )
  ]
}

