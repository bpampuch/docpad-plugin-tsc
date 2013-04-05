class TscCompiler
	constructor: ->
		@files = {}

		@tsc = require('./node_modules/typescript/bin/ntsc');
		@tsc.IO.writeFile = ->
		@tsc.IO.createFile = (name) =>
			result = ''
			files = @files

			return {
				Write: (txt) ->
					result = result + txt
				WriteLine: (txt) ->
					result = result + txt + '\n'
				Close: () ->
					files[name] = result
			}
		@tsc.IO.quit = ->

		@tsc.IO.getExecutingFilePath = ->
            __dirname + '/out'

		@compiler = new @tsc.BatchCompiler(@tsc.IO)

	compile: (filename) ->
		filename = filename.trim()
		@tsc.IO.arguments = [filename]
		@compiler.batchCompile()

# Export Plugin
module.exports = (BasePlugin) ->
    # Define Plugin
    class tscPlugin extends BasePlugin
        name: 'tsc'

        #TODO: config: ES3/5 and other options, 
        #TODO: module compilation
        #TODO: multifile ts->one output file rendering

        render: (opts) ->
            {inExtension, outExtension, templateData, file} = opts

            if inExtension in ['ts'] and outExtension in ['js', null]
                @tsc = new TscCompiler();
                fullPath = file.get('fullPath')
                @tsc.compile(fullPath)
                name = fullPath.replace(/\.ts$/,'.js')
                opts.content = @tsc.files[name]
                delete @tsc.files[name]
            return
