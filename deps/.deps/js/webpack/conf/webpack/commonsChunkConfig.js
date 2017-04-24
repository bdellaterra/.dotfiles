import webpack from 'webpack'

export default {
  plugins: [
    new webpack.optimize.CommonsChunkPlugin({
      name:      'vendor',
      minChunks: ({ userRequest }) => (
        userRequest
        && userRequest.indexOf('node_modules') >= 0
        && userRequest.match(/\.js$/)
      )
    })
  ]
}

