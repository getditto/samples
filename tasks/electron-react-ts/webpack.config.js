const path = require('path')
const HtmlWebpackPlugin = require('html-webpack-plugin')

if (!process.env.NODE_ENV) {
  process.env.NODE_ENV = 'development'
}

const common = {
  mode: process.env.NODE_ENV,
  output: { path: path.resolve(__dirname, 'build') },
  resolve: {
    extensions: ['.tsx', '.ts', '.js'],
    mainFields: ['main', 'module', 'browser'],
  },
  module: {
    rules: [
      {
        test: /\.tsx?$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: [['react-app', { flow: false, typescript: true }]],
          },
        },
      },
      {
        test: /\.css$/,
        use: ['style-loader', 'css-loader'],
      },
      {
        test: /\.node$/,
        loader: 'native-ext-loader',
      },
    ],
  },
}

module.exports = [
  {
    target: 'electron-main',
    entry: {
      main: './src/electron/main.ts',
      preload: './src/electron/preload.ts',
    },
    ...common,
  },
  {
    target: 'electron-renderer',
    entry: { index: './src/index.tsx' },
    plugins: [
      new HtmlWebpackPlugin({
        template: path.resolve(__dirname, 'public/index.html'),
      }),
    ],
    ...common,
  },
]
