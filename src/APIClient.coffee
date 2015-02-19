debug = require('debug') 'APIClient'
Promise = require 'bluebird'

class module.exports
	constructor: (xmlrpc, @options) ->
		debug "constructor()"

		unless xmlrpc
			throw Error "Must provide xmlrpc"

		unless @options
			throw Error "Must provide options"

		unless @options.host
			throw Error "Must provide `host` in options"

		unless @options.port
			throw Error "Must provide `port` in options"

		@client = xmlrpc.createClient @options

	request: (method, args) =>
		debug "request(#{method}, #{args})"
		new Promise (resolve, reject) =>
			@client.methodCall method, args, (error, value) =>
				if error
					reject error
				else
					resolve value.Value
