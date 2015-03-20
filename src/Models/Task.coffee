debug = require('debug') 'XenAPI:Task'
Promise = require 'bluebird'
_ = require 'lodash'

class Task
	key = undefined
	session = undefined
	task = undefined

	###*
	* Construct Task
	* @class
	* @param      {Object}   session - An instance of Session
	* @param      {Object}   task - A JSON object representing this Task
	* @param      {String}   key - The OpaqueRef handle to this Task
	###
	constructor: (_session, _task, _key) ->
		debug "constructor()"
		unless _session
			throw Error "Must provide `session`"
		
		session = _session

		unless _task
			throw Error "Must provide `task`"

		unless _key
			throw Error "Must provide `key`"
		
		key = _key

		unless _task.allowed_operations && _task.status
			throw Error "`task` does not describe a valid Task"
		
		task = _task

		@STATUS =
			PENDING: "pending",
			SUCCESS: "success",
			FAILURE: "failure",
			CANCELLING: "cancelling",
			CANCELLED: "cancelled"

		@ALLOWED_OPERATIONS =
			CANCEL: "cancel"

		@uuid = task.uuid
		@name = task.name_label
		@description = task.name_description
		@allowed_operations = task.allowed_operations
		@status = task.status
		@created = task.created
		@finished = task.finished
		@progress = task.progress

	cancel: =>
		debug "cancel()"

		new Promise (resolve, reject) =>
			unless _.contains @allowed_operations, @ALLOWED_OPERATIONS.CANCEL
				reject new Error "Operation is not allowed"
				return

			session.request("task.cancel", key).then (value) =>
				debug value
				resolve()
			.catch (e) ->
				debug e
				reject e

module.exports = Task
