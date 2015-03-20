APIClient = require './APIClient'
Session = require './Models/Session'
TaskCollection = require './TaskCollection'
Task = require './Models/Task'
VMCollection = require './VMCollection'
VM = require './Models/VM'
xmlrpc = require 'xmlrpc'

module.exports = (options) ->
	apiClient = new APIClient xmlrpc, options
	session = new Session apiClient
	taskCollection = new TaskCollection session, Task
	vmCollection = new VMCollection session, VM

	return {
		session: session,
		taskCollection, taskCollection,
		vmCollection: vmCollection
	}
