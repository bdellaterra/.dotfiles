const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const webpack = require('webpack');
const merge = require('webpack-merge');

const devServer = require('./config/webpack.devServer');
// const cleanBuild = require('./config/webpack.cleanBuild');
// const loadJS = require('./config/webpack.loadJS');
const lintJS = require('./config/webpack.lintJS');
// const minifyJS = require('./config/webpack.minifyJS');
// const extractBundles = require('./config/webpack.extractBundles');
const genSourcemaps = require('./config/webpack.genSourcemaps');
// const loadCSS = require('./config/webpack.loadCSS');
// const extractCSS = require('./config/webpack.extractCSS');
// const purifyCSS = require('./config/webpack.purifyCSS');

const PATHS = {
  app: path.join(__dirname, 'app'),
  build: path.join(__dirname, 'build'),
};

const common = merge([
  {
    entry: {
      app: PATHS.app,
    },
    output: {
      path: PATHS.build,
      filename: '[name].js',
    },
    plugins: [
      new HtmlWebpackPlugin({
        title: 'Webpack demo',
      }),
    ],
  },
]);

module.exports = function(env) {
  if (env === 'production') {
    return merge([
      common,

      // clean(PATHS.build),
      
      // loadJS(PATHS.app),

      // minifyJS({ useSourceMap: true }),
      
      // extractBundles([
      //   {
      //     name: 'vendor',
      //     entries: ['react'],
      //   },
      // ]),
      
      lintJS({ paths: PATHS.app }),

      // If using ExtractText plugin... 
      // extractCSS(),

      // If using PurifyCSS plugin... 
      // purifyCSS(
      //   glob.sync(path.join(PATHS.app, '*'))
      // ),

    ]);
  }

  return merge([
    common,
    {
      plugins: [
        new webpack.NamedModulesPlugin(),
      ],
    },

    generateSourcemaps('eval-source-map'),
    
    devServer({
      // Customize host/port here if needed
      host: process.env.HOST,
      port: process.env.PORT,
    }),
    lintJS({
      paths: PATHS.app,
      options: {
        // Emit warnings to avoid crashing HMR on error.
        emitWarning: true,
      },
    }),
  ]);
};
