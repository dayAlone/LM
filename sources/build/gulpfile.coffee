gulp         = require 'gulp'

autoprefixer = require 'gulp-autoprefixer'
cache        = require 'gulp-cached'
csscomb      = require 'gulp-csscomb'
coffee       = require 'gulp-coffee'
concat       = require 'gulp-concat'
cssmin       = require 'gulp-cssmin'
data         = require 'gulp-data'
gutil        = require 'gulp-util'
livereload   = require 'gulp-livereload'
less         = require 'gulp-less'
nib          = require 'nib'
jade         = require 'gulp-jade'
notify       = require 'gulp-notify'
uglify       = require 'gulp-uglify'
plumber      = require 'gulp-plumber'
svgmin       = require 'gulp-svgmin'
stylus       = require 'gulp-stylus'
sequence     = require 'run-sequence'
replace      = require 'gulp-replace'
watch        = require 'gulp-watch'
imageop      = require 'gulp-image-optimization'

plugins  = ['jquery', 'bootstrap', 'browser', 'fotorama', 'bem', 'hoverIntent' ]

layout   = 'public_html/layout'
layout2  = 'uncompressed_html/layout'
sources  = 'sources/'

path     =
	html: "#{sources}/html/"
	css:
		frontend : "#{layout}/css/"
		sources  : "#{sources}/css/"
	js:
		frontend : "#{layout}/js/"
		sources  : "#{sources}/js/"

isArray = Array.isArray || ( value ) -> return {}.toString.call( value ) is '[object Array]'

loadPlugins = (x, y)->
	data =
		css   : []
		js    : []
		files : []
	
	bower   = './bower_components'
	plugins = require('./plugins.json')
	for i in x
		elm = plugins[i]
		for key of elm
			if isArray elm[key]
				for z in elm[key]
					data[key].push bower+z
			else
				data[key].push bower+elm[key]
	return data[y]


# HTML

gulp.task 'html', ->
	gulp.src("#{path.html}*.jade")
	.pipe(cache('htmled'))
	.pipe plumber
		errorHandler: notify.onError("Error: <%= error.message %>")
	.pipe jade
		pretty: "\t"
	.pipe gulp.dest './public_html/'

gulp.task 'html2', ->
	str = ""
	list = loadPlugins plugins, 'js'
	
	list.push("/script.js")

	for s of list
		tmp = list[s].split('/')
		file = tmp[tmp.length-1]
		str += "<script type=\"text/javascript\" src=\"./layout/js/" +file+"\" async></script>\n\r\t"

	str2 = ""
	list = [ "bootstrap", "fotorama", "style"]

	for s of list
		str2 += "<link href=\"./layout/css/" + list[s] + ".css\" rel=\"stylesheet\">\n\r\t"

	gulp.src("#{path.html}*.jade")
	.pipe(cache('htmled'))
	.pipe plumber
		errorHandler: notify.onError("Error: <%= error.message %>")
	.pipe jade
		pretty: "\t"
	.pipe(replace('<script type="text/javascript" src="./layout/js/frontend.js" async></script>', str))
	.pipe(replace('<link href="./layout/css/frontend.css" rel="stylesheet">', str2))
	.pipe gulp.dest './uncompressed_html/'

# JavaScript functions

gulp.task 'js_plugins', ->
	gulp.src loadPlugins plugins, 'js'
	.pipe concat 'plugins.js'
	.pipe gulp.dest path.js.sources

gulp.task 'js_coffee', ->
	gulp.src [ "#{path.js.sources}/script.coffee" ]
	.pipe plumber
		errorHandler: notify.onError("Error: <%= error.message %>")
	.pipe coffee()
	.pipe gulp.dest path.js.sources

gulp.task 'js_front', ['js_coffee'], ->
	gulp.src [ "#{path.js.sources}/plugins.js", "#{path.js.sources}/script.js" ]
	.pipe concat 'frontend.js'
	.pipe gulp.dest path.js.frontend

gulp.task 'js_mini', ->
	gulp.src [ "#{path.js.frontend}/frontend.js"]
	.pipe uglify()
	.pipe gulp.dest path.js.frontend

# CSS functions

gulp.task 'css_bootstrap', ->
	gulp.src [ "#{path.css.sources}/bootstrap/bootstrap.less" ]
	.pipe less()
	.pipe gulp.dest path.css.sources

gulp.task 'css_plugins', ->
	gulp.src loadPlugins plugins, 'css'
	.pipe concat 'plugins.css'
	.pipe(replace("background: url(", 'background: url(/layout/images/plugins/'))
	.pipe(replace("background-image: url(", 'background-image: url(/layout/images/plugins/'))
	.pipe gulp.dest path.css.sources

gulp.task 'css_stylus', ->
	gulp.src [ "#{path.css.sources}/style.styl" ]
	.pipe plumber
		errorHandler: notify.onError("Error: <%= error.message %>")
	.pipe stylus 
		use: nib()
	.pipe gulp.dest path.css.sources

gulp.task 'css_stylus2', ->
	gulp.src [ "#{path.css.sources}/style.styl" ]
	.pipe plumber
		errorHandler: notify.onError("Error: <%= error.message %>")
	.pipe stylus 
		use: nib()
	.pipe gulp.dest 'uncompressed_html/layout/css/'

gulp.task 'css_front', ['css_stylus'], ->
	gulp.src [ "#{path.css.sources}/plugins.css", "#{path.css.sources}/style.css" ]
	.pipe concat 'frontend.css'
	.pipe gulp.dest path.css.frontend

gulp.task 'css_mini', ->
	gulp.src [ "#{path.css.frontend}/frontend.css"]
	.pipe csscomb()
	.pipe autoprefixer
        browsers: ['last 2 versions'],
        cascade: false
	.pipe cssmin()
	.pipe gulp.dest path.css.frontend


gulp.task 'copy', ->
	gulp.src loadPlugins plugins, 'files'
	.pipe gulp.dest "#{layout}/images/plugins/"

gulp.task 'copy_js', ->
	list = loadPlugins plugins, 'js'
	list.push("./sources/js/script.js")
	gulp.src list
	.pipe gulp.dest "#{layout2}/js/"

gulp.task 'copy_css', ->
	gulp.src loadPlugins plugins, 'css'
	.pipe gulp.dest "#{layout2}/css/"

# SVG functions

gulp.task 'svg_mini', ->
	gulp.src [ "#{sources}/images/svg/**/*.svg" ]
	.pipe svgmin([{ moveGroupAttrsToElems: false },
			{ removeUselessStrokeAndFill: false },
			{ cleanupIDs: false }, 
			{ removeComments: true }, 
			{ moveGroupAttrsToElems: false },
			{ convertPathData: { straightCurves: false} }
		])
	.pipe(replace(/<desc>(.*)<\/desc>/ig, ''))
	.pipe(replace(/<title>(.*)<\/title>/ig, ''))
	.pipe gulp.dest "#{layout}/images/svg/"

gulp.task 'img_mini', ->
	gulp.src [ "#{sources}/images/**/*.jpg", "#{sources}/images/**/*.png" ]
	.pipe imageop
        optimizationLevel: 1
        progressive: true
        interlaced: true
    .pipe gulp.dest "#{layout}/images/"


# System functions

gulp.task 'reload', ->
	livereload.changed()

gulp.task 'ready', ->
	sequence 'copy', 'html'
	sequence 'js_plugins', 'js_front', 'js_mini'
	sequence 'css_bootstrap', 'css_plugins', 'css_front', 'css_mini'

gulp.task 'ready2', ->
	sequence 'js_front', 'copy_js', 'html2'
	sequence 'copy_css', 'css_stylus2'


gulp.task 'svg', ->
	sequence 'svg_mini', 'html', 'reload'

gulp.task 'default', ->
	
	livereload.listen()

	gulp.watch "#{path.js.sources}/script.coffee", ->
		sequence 'js_front', 'reload'
	
	gulp.watch "#{path.css.sources}/**/*.styl", ->
		sequence 'css_front', 'reload'

	gulp.watch "#{sources}/images/svg/**/*.svg", ->
		sequence 'svg_mini'

	gulp.watch ["#{path.html}**/*.jade"], ->
		sequence 'html', 'reload'

	gulp.watch [ "#{sources}/images/**/*.jpg", "#{sources}/images/**/*.png" ], ->
		sequence 'img_mini'

	gulp.watch ["./public_html/**/*.php",'!./public_html/bitrix/**'], {'dot':true}, ->
		sequence 'reload'
	
	gulp.watch ["#{path.css.sources}/bootstrap/bootstrap.less", "./sources/build/plugins.json"], ->
		sequence 'css_bootstrap', 'css_plugins', 'copy', 'css_front', 'reload'
	
	gulp.watch ["./sources/build/gulpfile.coffee"], ->
		sequence 'js_plugins', 'js_front', 'css_bootstrap', 'css_plugins', 'copy', 'css_front', 'reload'

	gulp.watch ["./bower_components/**/*.js"], ->
		sequence 'js_plugins', 'js_front', 'reload'













