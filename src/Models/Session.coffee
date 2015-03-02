debug = require('debug') 'XenAPI:Session'
Promise = require 'bluebird'

class Session
	###*
	* Construct Session
	* @class
	* @param      {Object}   apiClient - An instance of APIClient
	###
	constructor: (@apiClient) ->
		debug "constructor()"
		unless @apiClient
			throw Error "Must provide apiClient"

		@loggedIn = false

	###*
	 * Login to the API
	 * @param      {String}   username - The Username to log in with
	 * @param      {String}   password - The Password to log in with
	 * @return     {Promise}
	###
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

	###*
	 * Logout from the API
	 * @return     {Promise}
	###
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

	###*
	 * Make a request via the API
	 * @protected
	 * @param      {String}   method - The method to call on the API
	 * @param      {Array}   args - Array of arguments pass to the API
	 * @return     {Promise}
	###
	request: (method, args) =>
		debug "request(#{method}, #{args})"

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

module.exports = Session
