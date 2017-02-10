
exports.cssLoader = function(paths) {
  return {
    module: {
      rules: [
        {
          test: /\.css$/,
          // Restrict extraction process to given paths.
          include: paths,
          use: ['style-loader', 'css-loader'],
        },
      ],
    },
  };
};

