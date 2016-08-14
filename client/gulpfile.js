var gulp = require('gulp');
var concat = require('gulp-concat');
var uglify = require('gulp-uglify');
var sourcemaps = require('gulp-sourcemaps');
var gutil = require("gulp-util");
var webpack = require("webpack");
var WebpackDevServer = require("webpack-dev-server");
var webpackConfig = require("./webpack.config.js");
var stream = require('webpack-stream');
var sass = require('gulp-sass');

if (process.env.NODE_ENV === 'production') {
  environment = require("./config/production");
}
else {
  environment = require("./config/development");
}

var path = {
  ALL: ['src/**/*.jsx', 'src/**/*.js'],
  CSS: ['styles/**/*.sass'],
  DEST_BUILD: 'dist/build',
};

gulp.task('styles', [], function () {
  gulp.src('styles/**/*.sass')
    .pipe(sass())
    // .pipe(gulp.dest('./tmp'))
    .pipe(concat('build.min.css'))
    // .pipe(autoprefixer())
    .pipe(gulp.dest(path.DEST_BUILD));
});

gulp.task('webpack', [], function() {
  return gulp.src(path.ALL) // gulp looks for all source files under specified path
             .pipe(sourcemaps.init()) // creates a source map which would be very helpful for debugging by maintaining the actual source code structure
             .pipe(stream(webpackConfig)) // blend in the webpack config into the source files
             .pipe(uglify()) // minifies the code for better compression
             .pipe(sourcemaps.write())
             .pipe(gulp.dest(path.DEST_BUILD))
});

gulp.task('index', function() {
  return gulp.src('index.html')
             .pipe(gulp.dest(path.DEST_BUILD))
});
 
gulp.task("webpack-dev-server", function(callback) {
  // modify some webpack config options
  var myConfig = Object.create(webpackConfig);
  new WebpackDevServer(webpack(myConfig), {
    publicPath: "/",
    hot: true,
    inline: true,
    stats: {
      colors: true
    },
    proxy: {
      '/v1/*': {
        target: environment.API_SERVER,
        secure: false,
        bypass: function(req, res, proxyOptions) {
          if (req.headers.accept.indexOf('html') !== -1) {
            console.log('Skipping proxy for browser request.');
            return '/index.html';
          }
        }
      }
    },
    historyApiFallback: {
      index: 'index.html'
    },
  }).listen(8080, "localhost", function(err) {
  if (err) throw new gutil.PluginError("webpack-dev-server", err);
    gutil.log("[webpack-dev-server]", "http://localhost:8080/webpack-dev-server/index.html");
  });
});

gulp.task('watch', function() {
  // gulp.watch(path.ALL, ['webpack']);
  gulp.watch(path.CSS, ['styles']);
});

gulp.task('build', ['webpack', 'styles', 'index']);

gulp.task('default', ['webpack-dev-server', 'watch']);
