debug = require('debug') 'XenAPI:Session'
Promise = require 'bluebird'

class module.exports
	constructor: (@apiClient) ->
		debug "constructor()"
		unless @apiClient
			throw Error "Must provide apiClient"

		@loggedIn = false

	login: (username, password) =>
		debug "login()"
		new Promise (resolve, reject) =>
			unless @loggedIn
				@apiClient.request("session.login_with_password", [username, password]).then (value) =>
					debug "login Completed"
					@loggedIn = true
					@sessionID = value
					resolve()
				.catch (e) =>
					debug "login Failed"
					reject e
			else
				debug "already logged in"
				reject()

	logout: =>
		debug "logout()"
		new Promise (resolve, reject) =>
			unless @loggedIn
				debug "not currently logged in"
				reject()
			else
				@apiClient.request("session.logout", [@sessionID]).then (value) =>
					debug "logout Completed"
					@loggedIn = false
					resolve()
				.catch =>
					debug "logout Failed"
					reject()

	request: (method, args) =>
		debug "request()"

		unless @loggedIn
			debug "not logged in"
			throw Error "Must be logged in to make API requests."

		unless args
			args = []

		new Promise (resolve, reject) =>
			args.unshift @sessionID
			@apiClient.request(method, args).then (value) =>
				resolve value
			.catch (e) =>
				reject e
