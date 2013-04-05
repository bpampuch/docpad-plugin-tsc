module.exports = (testers) ->
	class TscTester extends testers.RendererTester
		docpadConfig:
			logLevel: 5
			enabledPlugins:
				'tsc': true

