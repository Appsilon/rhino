const { join } = require('path');
const { resolve } = require('path');

const appDir = join(__dirname, '..', 'app');

module.exports = {
  mode: 'production',
  entry: join(appDir, 'js', 'index.js'),
  resolve: {
    alias: {
      js: resolve(appDir, 'js'),
    },
  },
  output: {
    library: 'App',
    path: join(appDir, 'static', 'js'),
    filename: 'app.min.js',
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        use: 'babel-loader',
      },
    ],
  }
};
