import { resolve } from 'path'
import HtmlWebpackPlugin from 'html-webpack-plugin'

export default {
  plugins: [
    new HtmlWebpackPlugin({
      template: resolve('src/index.template.html'),
    })
  ],
}

