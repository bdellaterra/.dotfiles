import { resolve } from 'path'

export default {
  devServer: {
    contentBase: resolve('dist'),
    inline:      true,
    port:        '8080',
    stats:       'errors-only'
  }
}

