# -----------------
# Variables

WINDOWS = process.platform.indexOf('win') is 0
NODE    = process.execPath
NPM     = if WINDOWS then process.execPath.replace('node.exe','npm.cmd') else 'npm'
EXT     = (if WINDOWS then '.cmd' else '')
APP     = process.cwd()
OUT     = "#{APP}/out"
OUTMOD	= "#{OUT}/node_modules"
BIN     = "#{APP}/node_modules/.bin"
CAKE    = "#{BIN}/cake#{EXT}"
COFFEE  = "#{BIN}/coffee#{EXT}"
SRC     = "#{APP}/src"
TEST    = "#{APP}/test"
TSCDIR	= "#{OUT}/node_modules/typescript/bin"
TSCSRC	= "#{TSCDIR}/tsc.js"
TSCOUT	= "#{OUT}/tsc.js"
TSCLIBSRC	= "#{TSCDIR}/lib.d.ts"
TSCLIBDST	= "#{OUT}/lib.d.ts"

# -----------------
# Requires

fs = require('fs')
{exec,spawn} = require('child_process')
safe = (next,fn) ->
	return (err) ->
		return next(err) if err
		return fn()

tscReplacement = """
exports = {
	IO: IO,
	BatchCompiler: BatchCompiler
}

module.exports = exports;

"""

# -----------------
# Actions

compile = (opts,next) ->
	(next = opts; opts = {})  unless next?
	spawn(COFFEE, ['-bco', OUT, SRC], {stdio:'inherit',cwd:APP}).on('exit',next)

typescript = (opts, next) ->
	(next = opts; opts = {}) unless next?
	spawn(NPM, ['install', 'typescript'], {stdio:'inherit', cwd:OUT}).on 'exit', safe next, ->
		fs.mkdirSync(OUT) if (!fs.existsSync(OUT))
		fs.mkdirSync(OUTMOD) if (!fs.existsSync(OUTMOD))
		tscContent = fs.readFileSync(TSCSRC, 'utf8')
		tscContent = tscContent.replace(/var batch = new BatchCompiler[\s\S]*/, tscReplacement);
		fs.writeFileSync(TSCOUT, tscContent)
		fs.createReadStream(TSCLIBSRC).pipe(fs.createWriteStream(TSCLIBDST));

install = (opts,next) ->
	(next = opts; opts = {})  unless next?
	spawn(NPM, ['install'], {stdio:'inherit',cwd:APP}).on 'exit', safe next, ->
		spawn(NPM, ['install'], {stdio:'inherit',cwd:TEST}).on('exit',next)

test = (opts,next) ->
	(next = opts; opts = {})  unless next?
	spawn(NPM, ['test'], {stdio:'inherit',cwd:APP}).on('exit',next)

finish = (err) ->
	throw err if err
	console.log('OK')

setup = (opts,next) ->
	(next = opts; opts = {})  unless next?
	install opts, safe next, ->
		compile opts, safe next, ->
			typescript opts, next

# -----------------
# Commands

task 'compile', 'compile our files', ->
	compile finish

task 'install', 'install dependencies', ->
	install finish

task 'typescript', 'install and patch typescript', ->
	typescript finish

task 'setup', 'setup for development', ->
	setup finish

task 'test', 'run our tests', ->
	test finish

task 'test-debug', 'run our tests in debug mode', ->
	test {debug:true}, finish

task 'test-prepare', 'prepare out tests', ->
	setup finish
