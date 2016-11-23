const path = require("path");
const webpack = require("webpack");

module.exports = {
  entry: {
    app: [
    './src/app.js'
    ]
  },
  output: {
    path: path.resolve(__dirname + '/dist'),
    filename: '[name].js',
  },
  module: {
    loaders: [
      {
        test: /\.html$/,
        exclude: /node_modules/,
        loader: 'file?name=[name].[ext]',
      },
      {
        test: /\.jpe?g$|\.gif$|\.png$|\.svg$|\.woff$|\.ttf$|\.wav$|\.mp3|\.ico$/,
        exclude: /node_modules/,
        loader: "file?name=[name].[ext]",
      },
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        loader: 'elm-webpack',
      },
    ],
    noParse: /\.elm$/,
  },
  plugins: [
    new webpack.optimize.UglifyJsPlugin({
      compress: {
        warnings: false
      }
    })
  ],
  devServer: {
    inline: true,
    stats: { colors: true },
  },
};
