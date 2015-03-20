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
		@allowed_operations = []

		_.each task.allowed_operations, (operation) =>
			_.each @ALLOWED_OPERATIONS, (allowed_operation) =>
				if operation == allowed_operation
					@allowed_operations.push allowed_operation

		if task.allowed_operations.length != @allowed_operations.length
			throw Error "Could not map all Allowed Operations."

		@status = ""

		_.each @STATUS, (status) =>
			if task.status == status
				@status = status

		if @status == ""
			throw Error "Could not map task Status"

		@created = task.created
		@finished = task.finished
		@progress = task.progress

module.exports = Task
