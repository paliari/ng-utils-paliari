gulp         = require 'gulp'
es           = require 'event-stream'
argv         = require('yargs').argv
del          = require 'del'
$            = require('gulp-load-plugins')()

gulp.task 'build', ->
  lib =
    gulp.src []

  js =
    gulp.src 'src/**/*.coffee'
    .pipe $.plumber()
    .pipe $.ngClassify(appName: 'ng-utils-paliari')
    .pipe $.concat('ng-utils-paliari.js')
    .pipe $.coffee(bare: no)

  es.merge(lib, js)
    .pipe $.concat('ng-utils-paliari.js')
    .pipe gulp.dest 'dist'
    .pipe($.uglify())
    .pipe($.concat('ng-utils-paliari.min.js'))
    .pipe(gulp.dest('dist'))

gulp.task 'examples', ->
  gulp.src 'examples/**/*.coffee'
  .pipe $.plumber()
  .pipe $.ngClassify(appName: 'ng-utils-paliari-examples')
  .pipe $.coffee(bare: no)
  .pipe(gulp.dest('examples'))

gulp.task 'server', ->
  $.connect.server(root: [__dirname], port: 8888)

gulp.task 'watch', ->
  gulp.watch 'src/**/*', ['build']
  gulp.watch 'examples/**/*.coffee', ['examples']

gulp.task 'default', ['build', 'examples']

gulp.task 'clear', ->
  del 'dist/'

# Sem parametro executa "bump patch"
# Ou passar o tipo desejado: "gulp bump --type minor"
# Opcoes permitidas: major|minor|patch|prerelease
gulp.task 'bump', ->
  gulp.src ['./bower.json', './package.json']
  .pipe $.bump type: argv.type
  .pipe gulp.dest './'
  .pipe $.git.commit 'bumps package version'
  .pipe $.filter 'bower.json'
  .pipe $.tagVersion(prefix: '')
