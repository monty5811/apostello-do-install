const path = require("path");
const webpack = require("webpack");

if (process.env.WATCH) {
  elmLoader = 'elm-webpack-loader?debug=true';
  plugins = [];
} else {
  elmLoader = 'elm-webpack-loader';
  plugins = [
    new webpack.optimize.UglifyJsPlugin({
      compress: {
        warnings: false
      }
    })
  ];
}

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
        loader: 'file-loader?name=[name].[ext]',
      },
      {
        test: /\.jpe?g$|\.gif$|\.png$|\.svg$|\.woff$|\.ttf$|\.wav$|\.mp3|\.ico$/,
        exclude: /node_modules/,
        loader: "file-loader?name=[name].[ext]",
      },
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        loader: elmLoader,
      },
    ],
    noParse: /\.elm$/,
  },
  plugins: plugins,
  devServer: {
    inline: true,
    stats: { colors: true },
  },
};
