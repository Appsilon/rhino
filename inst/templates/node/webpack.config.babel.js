import { join } from 'path';

export default {
  mode: 'production',
  entry: join(__dirname, 'root', 'app', 'js', 'index.js'),
  output: {
    library: 'App',
    path: join(__dirname, 'root', 'app', 'static', 'js'),
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
