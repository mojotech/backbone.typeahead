var gulp = require('gulp'),
    rs = require('run-sequence'),
    argv = require('yargs').argv,
    bump = require('gulp-bump'),
    clean = require('gulp-clean'),
    coffeelint = require('gulp-coffeelint'),
    rename = require('gulp-rename'),
    coffee = require('gulp-coffee'),
    mocha = require('gulp-mocha'),
    sourcemaps = require('gulp-sourcemaps'),
    uglify = require('gulp-uglify');

require('coffee-script/register');

gulp.task('bump', function() {
  var version = argv.version;
  var type = argv.type || "patch";
  var bumpTo = {};

  if (version !== undefined) {
    bumpTo.version = version;
  } else {
    bumpTo.type = type;
  }

  return gulp.src(['./package.json', './bower.json'])
    .pipe(bump(bumpTo))
    .pipe(gulp.dest('./'));

});

gulp.task('clean', function() {
  return gulp.src('dist', {read: false})
    .pipe(clean());
});

gulp.task('lint', function() {
  return gulp.src(['src/*.coffee'])
    .pipe(coffeelint())
    .pipe(coffeelint.reporter());
});

gulp.task('test', function() {
  return gulp.src('test/*.coffee')
    .pipe(mocha())
});

gulp.task('coffee', function() {
  return gulp.src('src/*.coffee')
    .pipe(sourcemaps.init())
    .pipe(coffee())
    .pipe(sourcemaps.write('./'))
    .pipe(gulp.dest('dist'));
});

gulp.task('uglify', function() {
  return gulp.src(['!dist/*.min.js', 'dist/*.js'])
    .pipe(uglify())
    .pipe(rename({suffix: '.min'}))
    .pipe(gulp.dest('dist'));
});

// Rerun the task when a file changes
gulp.task('watch', function() {
    return gulp.watch(['./src/*.coffee'], ['lint', 'test']);
});

gulp.task('build', function(cb) {
  return rs('coffee', 'uglify', cb);
});

gulp.task('release', function(cb) {
  return rs('clean', 'bump', 'build', cb);
});

gulp.task('default', function() {
    return gulp.start('lint', 'test', 'build');
});
