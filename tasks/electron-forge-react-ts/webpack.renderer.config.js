const rules = require('./webpack.rules');
const plugins = require('./webpack.plugins');

module.exports = {
  mode: process.env.NODE_ENV,
  module: {
    rules,
  },
  plugins: plugins,
  resolve: {
    mainFields: ['main', 'module', 'browser'],
    extensions: ['.js', '.ts', '.jsx', '.tsx', '.css'],
  },
  devtool: "nosources-source-map",
};
