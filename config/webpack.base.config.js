var path = require("path");
var webpack = require('webpack');

module.exports = {
	context: __dirname,

	entry: {
		App: '../src/App',
	},

	output: {
		path: path.resolve('./dist'),
		filename: "[name].js",
	},

	resolve: {
		extensions: ['.js'],
	},

	plugins: [
		new webpack.LoaderOptionsPlugin({
			minimize: true,
			debug: false
		}),
	],

	module: {
		loaders: [
			{
				test: /\.(css|scss)$/,
				loaders: [
					'style-loader',
					'css-loader',
				]
			},
			{
				test: /\.html$/,
				exclude: /node_modules/,
				loader: 'file?name=[name].[ext]',
			},
			{
				test: /\.elm$/,
				exclude: [/elm-stuff/, /node_modules/],
				loader: 'elm-webpack'
			},
		],
		noParse: /\.elm$/,
	},

	watchOptions: {
		poll: 500
	},
	devServer: {
		inline: true,
		stats: { colors: true },
	},
}
