import WorkboxWebpackPlugin from 'workbox-webpack-plugin'

export default {
  plugins: [
    new WorkboxWebpackPlugin.GenerateSW({
      clientsClaim: true,
      skipWaiting: false,
    })
  ]
}
