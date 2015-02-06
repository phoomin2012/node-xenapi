debug = require('debug') 'APIClient'

class module.exports
	constructor: (xmlrpc, @options) ->
		debug "constructor()"

		unless xmlrpc
			throw Error "Must provide xmlrpc"

		unless @options
			throw Error "Must provide options"
