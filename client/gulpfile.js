var envify = require('gulp-envify');
var gulp = require("gulp");
var gutil = require("gulp-util");
var webpack = require("webpack");
var WebpackDevServer = require("webpack-dev-server");
var webpackConfig = require("./webpack.config.js");

if (process.env.NODE_ENV === 'production') {
  environment = require("./config/production");
}
else {
  environment = require("./config/development");
}

gulp.task("webpack", function(callback) {
    // run webpack
    webpack({
        // configuration
    }, function(err, stats) {
        if(err) throw new gutil.PluginError("webpack", err);
        gutil.log("[webpack]", stats.toString({
            // output options
        }));
        callback();
    });
});

gulp.task("webpack-dev-server", function(callback) {
    var myConfig = Object.create(webpackConfig);
    myConfig.devtool = "eval";
    myConfig.debug = true;

    // Start a webpack-dev-server
    new WebpackDevServer(webpack(myConfig), {
        contentBase: "./dist",
        stats: {
            colors: true
        }
    }).listen(8080, "localhost", function(err) {
        if (err) throw new gutil.PluginError("webpack-dev-server", err);
        gutil.log("[webpack-dev-server]", "http://localhost:8080");
    });
});

gulp.task("build", function() {
  gulp.src('index.html', {base: './'}).pipe(gulp.dest('dist'));
  gulp.src('init.js')
  .pipe(envify(environment))
  .pipe(gulp.dest('dist'));
})
