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
				.catch =>
					debug "login Failed"
					reject()
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
