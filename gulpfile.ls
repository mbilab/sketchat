require! <[gulp main-bower-files gulp-concat gulp-filter gulp-jade gulp-livereload gulp-livescript gulp-markdown gulp-print gulp-rename gulp-stylus gulp-util streamqueue tiny-lr]>

port = 9999
tiny-lr-port = 35729

paths =
  app: \app
  build: \public

tiny-lr-server = tiny-lr!
livereload = -> gulp-livereload tiny-lr-server

gulp.task \default <[watch]>
gulp.task \watch <[build server]> ->
  tiny-lr-server.listen tiny-lr-port, -> gulp-util.log it if it
  gulp.watch paths.app+\/**/*.jade, <[html]>
  gulp.watch paths.app+\/**/*.styl, <[css]>
  gulp.watch paths.app+\/**/*.ls, <[js]>
  gulp.watch paths.app+\/**/*.php, <[php]>
  gulp.watch paths.app+\/res/**, <[res]>

gulp.task \build <[html css js php res]>
gulp.task \server ->
  require! \express
  express-server = express!
  express-server.use require(\connect-livereload)!
  express-server.use express.static paths.build
  express-server.listen port
  gulp-util.log "Listening on port: #port"

gulp.task \html ->
  jade = gulp.src paths.app+\/**/*.jade .pipe gulp-jade {+pretty}
  streamqueue {+objectMode}
    .done jade
    .pipe gulp.dest paths.build
    .pipe livereload!

gulp.task \css ->
  css-bower = gulp.src main-bower-files! .pipe gulp-filter \**/*.css
  styl-app = gulp.src paths.app+\/*.styl .pipe gulp-stylus!
  css-app = gulp.src paths.app+\/vendor/*.css
  streamqueue {+objectMode}
    .done css-bower, styl-app, css-app
    .pipe gulp-concat \app.css
    .pipe gulp.dest paths.build
    .pipe livereload!

gulp.task \js ->
  js-bower = gulp.src main-bower-files! .pipe gulp-filter \**/*.js
  js-app = gulp.src paths.app+\/vendor/*.js
  streamqueue {+objectMode}
    .done js-bower, js-app
    .pipe gulp-concat \app.js
    .pipe gulp.dest paths.build
    .pipe livereload!
  gulp.src paths.app+\/*.ls .pipe gulp-livescript {+bare}
    .pipe gulp.dest paths.build
    .pipe livereload!

gulp.task \res ->
  gulp.src \bower_components/semantic-ui/dist/themes/**
    .pipe gulp.dest paths.build+\/themes
  gulp.src paths.app+\/res/**
    .pipe gulp.dest paths.build+\/res
    .pipe livereload!

gulp.task \php ->
  gulp.src paths.app+\/**/*.php
    .pipe gulp.dest paths.build
    .pipe livereload!

# vi:et:ft=ls:nowrap:sw=2:ts=2
