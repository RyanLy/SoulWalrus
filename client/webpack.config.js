var path = require('path');
var webpack = require('webpack');
var ExtractTextPlugin = require("extract-text-webpack-plugin");
const CompressionPlugin = require('compression-webpack-plugin');

const environment = process.env.NODE_ENV === 'production'
  ? require('./config/production')
  : require('./config/development');

var webpackConfig = {
  cache: true,
  debug: true,
  silent: true,
  devtool: 'eval',
  entry: [
     './src/app.js'
  ],
  output: {
    path: path.join(__dirname, "build"),
    filename: 'build.min.js'
  },
  module: {
    loaders: [
      {
        test: /.jsx?$/,
        loaders: ['react-hot', 'babel-loader?presets[]=es2015,presets[]=react'],
        exclude: /node_modules/
      },
      {
        test: /\.scss$/,
        loader: ExtractTextPlugin.extract('style-loader', 'css-loader!sass-loader'),
        include: path.join(__dirname, 'styles'),

      },
      // Url loader for bootstrap
      {
        test: /\.(png|woff|woff2|eot|ttf|svg)$/,
        loader: 'url-loader?limit=100000',
      },
    ]
  },
  plugins: [
    new webpack.DefinePlugin({
      'process.env.NODE_ENV': JSON.stringify(process.env.NODE_ENV === 'production' ? 'production' : 'development'),
      'ENVIRONMENT': Object.keys(environment).reduce(function(o, k) {
        o[k] = JSON.stringify(environment[k]);
        return o;
      }, {})
   }),
   new ExtractTextPlugin("build.min.css"),
  ]
};

if (process.env.NODE_ENV !== 'production') {
  webpackConfig.plugins.unshift(new webpack.HotModuleReplacementPlugin());
  webpackConfig.entry.unshift(
    'webpack/hot/dev-server',
    'webpack-dev-server/client?http://localhost:8080/'
  );
  webpackConfig.devtool = "eval-source-map"
}
else {
  webpackConfig.plugins.push(
    new webpack.optimize.UglifyJsPlugin({
      compress: { warnings: false }
    })
  );
  webpackConfig.plugins.push(new CompressionPlugin());
}

module.exports = webpackConfig
