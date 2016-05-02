var path = require('path'),
    webpack = require("webpack");

module.exports = {
    context: path.join(__dirname, 'dist'),
    devtool: 'eval',
    entry: [
      './init.js',
      'webpack/hot/dev-server',
      'webpack-dev-server/client?http://localhost:8080/',
    ],
    output: {
        path: path.join(__dirname, 'dist'),
        filename: 'bundle.js'
    },
    plugins: [
      new webpack.HotModuleReplacementPlugin(),
    ]
};
