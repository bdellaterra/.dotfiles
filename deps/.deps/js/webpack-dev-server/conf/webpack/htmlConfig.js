import { resolve } from 'path'

import HtmlWebpackPlugin from 'html-webpack-plugin'

export default {
  plugins: [
    new HtmlWebpackPlugin({
      hash:     true,
      filename: 'index.html',
      template: resolve('src', 'html', 'index.tmpl.html')
    })
  ]
}

