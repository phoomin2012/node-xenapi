APIClient = require './APIClient'
Session = require './Models/Session'
TaskCollection = require './TaskCollection'
Task = require './Models/Task'
VIFCollection = require './VIFCollection'
VIF = require './Models/VIF'
VMCollection = require './VMCollection'
VM = require './Models/VM'
xmlrpc = require 'xmlrpc'

module.exports = (options) ->
	apiClient = new APIClient xmlrpc, options
	session = new Session apiClient
	taskCollection = new TaskCollection session, Task
	vifCollection = new VIFCollection session, VIF
	vmCollection = new VMCollection session, VM

	return {
		session: session,
		taskCollection, taskCollection,
		vifCollection, vifCollection,
		vmCollection: vmCollection
	}
