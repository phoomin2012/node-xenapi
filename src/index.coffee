APIClient = require './APIClient'
NetworkCollection = require './NetworkCollection'
Network = require './Models/Network'
PoolCollection = require './PoolCollection'
Pool = require './Models/Pool'
Session = require './Models/Session'
SRCollection = require './SRCollection'
SR = require './Models/SR'
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
	networkCollection = new NetworkCollection session, Network
	poolCollection = new PoolCollection session, Pool
	srCollection = new SRCollection session, SR
	taskCollection = new TaskCollection session, Task
	vifCollection = new VIFCollection session, VIF
	vmCollection = new VMCollection session, VM

	return {
		session: session,
		networkCollection: networkCollection,
		poolCollection: poolCollection,
		srCollection: srCollection,
		taskCollection: taskCollection,
		vifCollection: vifCollection,
		vmCollection: vmCollection
	}
