debug = require('debug') 'XenAPI:Session'
Promise = require 'bluebird'

class module.exports
	constructor: (@apiClient) ->
		debug "constructor()"
		unless @apiClient
			throw Error "Must provide apiClient"

	logout: =>
		new Promise (resolve, reject) =>
			reject()
