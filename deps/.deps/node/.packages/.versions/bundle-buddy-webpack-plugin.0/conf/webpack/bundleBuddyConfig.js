import BundleBuddyWebpackPlugin from 'bundle-buddy-webpack-plugin'

export default {
  plugins: [
    new BundleBuddyWebpackPlugin({
      sam: true
    })
  ]
}
