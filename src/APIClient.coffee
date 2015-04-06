debug = require('debug') 'APIClient'
Promise = require 'bluebird'

class APIClient
	###*
	* Construct APIClient
	* @class
	* @param      {Object}   xmlrpc
	* @param      {Object}   options - for connecting to the API
	* @param      {String}   options.host - The host the API is being served on
	* @param      {String}   options.port - The port the API is being served on
	###
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

	###*
	 * Make a request via the API
	 * @protected
	 * @param      {String}   method - The method to call on the API
	 * @param      {Array}   args - Array of arguments pass to the API
	 * @return     {Promise}
	###
	request: (method, args) =>
		debug "request(#{method}, #{args})"
		new Promise (resolve, reject) =>
			@client.methodCall method, args, (error, value) =>
				if error
					reject error
				else
					debug value
					if value.Status == "Failure"
						reject value.ErrorDescription
					else
						resolve value.Value

module.exports = APIClient
