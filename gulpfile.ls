require! <[fs gulp main-bower-files gulp-concat gulp-filter gulp-jade gulp-livereload gulp-livescript gulp-markdown gulp-print gulp-rename gulp-stylus gulp-util streamqueue tiny-lr]>

config = JSON.parse fs.read-file-sync \config.json \utf8
paths =
  app: \app
  lib: \lib
  build: \public

tiny-lr-server = tiny-lr!
livereload = -> gulp-livereload tiny-lr-server

gulp.task \default <[watch]>

gulp.task \watch <[build server]> ->
  tiny-lr-server.listen 35729, -> gulp-util.log it if it
  gulp.watch paths.app+\/**/*.jade, <[html]>
  gulp.watch paths.app+\/**/*.styl, <[css]>
  gulp.watch paths.app+\/**/*.ls, <[js]>
  gulp.watch paths.app+\/res/**, <[res]>

gulp.task \build <[html css js res]>

gulp.task \server ->
  # Web app service start
  require! <[express]>; app = express!
  require(\./lib/router) app, config
  app.use require(\connect-livereload)!
  app.use express.static paths.build
  app.listen config.app.port
  gulp-util.log "Listening on port: #{config.app.port} for app".yellow
  # Socket service start
  socket-app = require \http .create-server! .listen config.socket.port
  io = require \socket.io .listen socket-app
  require(\./lib/socket) io, config
  gulp-util.log "Listening on port: #{config.socket.port} for socket".yellow

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
  ls-app = gulp.src paths.app+\/app.ls .pipe gulp-livescript {+bare}
  streamqueue {+objectMode}
    .done js-bower, js-app, ls-app
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

# vi:et:ft=ls:nowrap:sw=2:ts=2
