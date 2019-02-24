import HtmlWebpackPlugin from 'html-webpack-plugin'

export default {
  plugins: [
    new HtmlWebpackPlugin({
      hash:     true,
      filename: './index.html',
      template: './src/index.template.html'
    })
  ]
}

