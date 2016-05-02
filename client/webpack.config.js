var path = require('path'),
    webpack = require("webpack");

module.exports = {
    cache: true,
    debug: true,
    devtool: 'eval',
    output: {
        path: path.join(__dirname, "build"),
        filename: 'build.min.js'
    },
    resolve: {
        extensions: ['', '.js', '.json', '.coffee']
    }
};
