import { resolve } from 'path'

export default {
  module: {
    loaders: [
      {
        test: /\.bson$|\.csv$|\.json$|\.tsv$|\.xml|\.yaml$/,
        loader:  'file-loader',
        options: {
          name: './data/[name].[hash].[ext]'
        }
      }
    ]
  }
}

