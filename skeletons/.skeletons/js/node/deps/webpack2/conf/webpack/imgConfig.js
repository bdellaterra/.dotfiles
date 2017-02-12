import { resolve } from 'path'

export default {
  module: {
    loaders: [
      {
        test: /\.jpe?g$|\.gif$|\.png$|\.svg$|\.woff$|\.ttf$|\.wav$|\.mp3$/,

        // NOTE: Using file-loader instead of url-loader until a way can be
        //       found to load the bin-encoded images as WebGL textures.
        loader: "file-loader",
        options: {
          //limit: 10000,
          name: './images/[name].[hash].[ext]',
        },

      }
    ]
  }
}

