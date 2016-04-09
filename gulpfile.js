var gulp = require('gulp'),
	cssmin = require('gulp-minify-css'),
	jsmin = require('gulp-uglify'),
	htmlmin = require('gulp-minify-html');



gulp.task("css",function() {
    return gulp.src(["public/**/*.css","!public/**/*.min.css"])
    .pipe(cssmin({compatibility: "ie8"}))
    .pipe(gulp.dest("./dst/"));
});

gulp.task("js",function() {
    return gulp.src(["public/**/*.js","!public/**/*.min.js"])
    .pipe(jsmin())
    .pipe(gulp.dest("./dst/"));
});

gulp.task("html",function() {
    return gulp.src("public/**/*.html")
    .pipe(htmlmin())
    .pipe(gulp.dest("./dst/"));
});

// gulp.task("default",["css","js","html"],function() {
//     console.log("gulp task finished!");
// });

gulp.task("default",["css","js"],function() {
    console.log("gulp task finished!");
});
